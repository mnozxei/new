-- =====================================================
-- TAMAD HUB - Enterprise Profile System Migration
-- Adds work history, profile completion tracking, and stats
-- =====================================================

-- ===========================================
-- ENUMS
-- ===========================================
DO $$ BEGIN
    CREATE TYPE employment_type AS ENUM (
        'full_time',
        'part_time',
        'contract',
        'freelance',
        'internship',
        'volunteer',
        'self_employed'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ===========================================
-- UPDATE PROFILES TABLE
-- ===========================================

-- Add missing columns to profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS cover_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS github_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS industry TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS skills TEXT[] DEFAULT '{}';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS languages TEXT[] DEFAULT '{}';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_available_for_hire BOOLEAN DEFAULT TRUE;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profile_visibility TEXT DEFAULT 'public' CHECK (profile_visibility IN ('public', 'private'));

-- Stats fields (computed via triggers, not stored directly for realtime accuracy)
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS posts_count INTEGER DEFAULT 0;

-- ===========================================
-- PROFILE EXPERIENCES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS profile_experiences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- Job Info
    title TEXT NOT NULL,
    company_name TEXT NOT NULL,
    company_logo_url TEXT,
    employment_type employment_type NOT NULL DEFAULT 'full_time',

    -- Location
    city TEXT,
    country TEXT DEFAULT 'SA',
    is_remote BOOLEAN DEFAULT FALSE,

    -- Duration
    start_date DATE NOT NULL,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,

    -- Details
    description TEXT,
    skills_used TEXT[] DEFAULT '{}',

    -- Metadata
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraint: end_date required if not current
    CONSTRAINT valid_date_range CHECK (
        (is_current = TRUE AND end_date IS NULL) OR
        (is_current = FALSE AND (end_date IS NULL OR end_date >= start_date))
    )
);

-- ===========================================
-- PROFILE EDUCATIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS profile_educations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    -- School Info
    school_name TEXT NOT NULL,
    school_logo_url TEXT,
    degree TEXT,
    field_of_study TEXT,

    -- Duration
    start_date DATE,
    end_date DATE,
    is_current BOOLEAN DEFAULT FALSE,

    -- Details
    grade TEXT,
    description TEXT,
    activities TEXT,

    -- Metadata
    sort_order INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- USER FOLLOWS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS user_follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    -- Unique constraint
    CONSTRAINT unique_follow UNIQUE (follower_id, following_id),
    -- Cannot follow yourself
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

-- ===========================================
-- PROFILE SKILLS TABLE (normalized)
-- ===========================================
CREATE TABLE IF NOT EXISTS profile_skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    skill_name TEXT NOT NULL,
    proficiency_level INTEGER DEFAULT 3 CHECK (proficiency_level BETWEEN 1 AND 5),
    years_of_experience INTEGER,
    is_endorsed BOOLEAN DEFAULT FALSE,
    endorsements_count INTEGER DEFAULT 0,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),

    CONSTRAINT unique_user_skill UNIQUE (user_id, skill_name)
);

-- ===========================================
-- INDEXES
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_profile_experiences_user ON profile_experiences(user_id);
CREATE INDEX IF NOT EXISTS idx_profile_experiences_dates ON profile_experiences(user_id, start_date DESC);
CREATE INDEX IF NOT EXISTS idx_profile_experiences_current ON profile_experiences(user_id) WHERE is_current = TRUE;

CREATE INDEX IF NOT EXISTS idx_profile_educations_user ON profile_educations(user_id);

CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_following ON user_follows(following_id);

CREATE INDEX IF NOT EXISTS idx_profile_skills_user ON profile_skills(user_id);

CREATE INDEX IF NOT EXISTS idx_profiles_industry ON profiles(industry);
CREATE INDEX IF NOT EXISTS idx_profiles_skills ON profiles USING gin(skills);

-- ===========================================
-- FUNCTIONS
-- ===========================================

-- Update followers count when follow/unfollow
CREATE OR REPLACE FUNCTION update_follow_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE profiles SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE profiles SET following_count = following_count + 1 WHERE id = NEW.follower_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE profiles SET followers_count = GREATEST(followers_count - 1, 0) WHERE id = OLD.following_id;
        UPDATE profiles SET following_count = GREATEST(following_count - 1, 0) WHERE id = OLD.follower_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_follow_counts ON user_follows;
CREATE TRIGGER trigger_update_follow_counts
    AFTER INSERT OR DELETE ON user_follows
    FOR EACH ROW EXECUTE FUNCTION update_follow_counts();

-- Get user learning stats (enrolled, in_progress, completed)
CREATE OR REPLACE FUNCTION get_user_learning_stats(p_user_id UUID)
RETURNS TABLE (
    enrolled_count BIGINT,
    in_progress_count BIGINT,
    completed_count BIGINT,
    certificates_count BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*) FILTER (WHERE e.status IN ('active', 'completed')) AS enrolled_count,
        COUNT(*) FILTER (WHERE e.status = 'active' AND e.progress_percent < 100) AS in_progress_count,
        COUNT(*) FILTER (WHERE e.status = 'completed') AS completed_count,
        (SELECT COUNT(*) FROM certificates c WHERE c.user_id = p_user_id AND c.status = 'issued') AS certificates_count
    FROM enrollments e
    WHERE e.user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Get completed courses for user
CREATE OR REPLACE FUNCTION get_user_completed_courses(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    course_id UUID,
    course_title TEXT,
    course_thumbnail TEXT,
    instructor_name TEXT,
    completed_at TIMESTAMPTZ,
    certificate_id UUID,
    certificate_serial TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id AS course_id,
        c.title AS course_title,
        c.thumbnail_url AS course_thumbnail,
        COALESCE(p.full_name, p.email) AS instructor_name,
        e.completed_at,
        cert.id AS certificate_id,
        cert.serial_number AS certificate_serial
    FROM enrollments e
    JOIN courses c ON e.course_id = c.id
    LEFT JOIN profiles p ON c.instructor_id = p.id
    LEFT JOIN certificates cert ON cert.enrollment_id = e.id AND cert.status = 'issued'
    WHERE e.user_id = p_user_id
      AND e.status = 'completed'
    ORDER BY e.completed_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Get user certificates
CREATE OR REPLACE FUNCTION get_user_certificates(
    p_user_id UUID,
    p_limit INTEGER DEFAULT 10,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    certificate_id UUID,
    serial_number TEXT,
    course_name TEXT,
    issuer_name TEXT,
    issued_at TIMESTAMPTZ,
    pdf_url TEXT,
    verify_url TEXT,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id AS certificate_id,
        c.serial_number,
        c.course_name,
        COALESCE(c.instructor_name, c.company_name) AS issuer_name,
        c.issued_at,
        c.pdf_url,
        '/verify/' || c.serial_number AS verify_url,
        c.status::TEXT
    FROM certificates c
    WHERE c.user_id = p_user_id
    ORDER BY c.issued_at DESC
    LIMIT p_limit OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Verify certificate by serial (public safe)
CREATE OR REPLACE FUNCTION verify_certificate_public(p_serial TEXT)
RETURNS TABLE (
    is_valid BOOLEAN,
    student_name TEXT,
    course_name TEXT,
    issuer_name TEXT,
    issued_at TIMESTAMPTZ,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.status = 'issued' AS is_valid,
        c.student_name,
        c.course_name,
        COALESCE(c.instructor_name, c.company_name) AS issuer_name,
        c.issued_at,
        c.status::TEXT
    FROM certificates c
    WHERE c.serial_number = p_serial;
END;
$$ LANGUAGE plpgsql;

-- Update profile updated_at trigger
CREATE OR REPLACE FUNCTION update_profile_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_profile_updated_at ON profiles;
CREATE TRIGGER trigger_profile_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_profile_updated_at();

DROP TRIGGER IF EXISTS trigger_experience_updated_at ON profile_experiences;
CREATE TRIGGER trigger_experience_updated_at
    BEFORE UPDATE ON profile_experiences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS trigger_education_updated_at ON profile_educations;
CREATE TRIGGER trigger_education_updated_at
    BEFORE UPDATE ON profile_educations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ===========================================
-- RLS POLICIES
-- ===========================================

-- Enable RLS
ALTER TABLE profile_experiences ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_educations ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE profile_skills ENABLE ROW LEVEL SECURITY;

-- Profile Experiences Policies
DROP POLICY IF EXISTS "experiences_select_public" ON profile_experiences;
CREATE POLICY "experiences_select_public" ON profile_experiences
    FOR SELECT USING (
        is_visible = TRUE
        OR user_id = auth.uid()
        OR EXISTS (SELECT 1 FROM profiles WHERE id = profile_experiences.user_id AND profile_visibility = 'public')
    );

DROP POLICY IF EXISTS "experiences_insert_own" ON profile_experiences;
CREATE POLICY "experiences_insert_own" ON profile_experiences
    FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "experiences_update_own" ON profile_experiences;
CREATE POLICY "experiences_update_own" ON profile_experiences
    FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "experiences_delete_own" ON profile_experiences;
CREATE POLICY "experiences_delete_own" ON profile_experiences
    FOR DELETE USING (user_id = auth.uid());

-- Profile Educations Policies
DROP POLICY IF EXISTS "educations_select_public" ON profile_educations;
CREATE POLICY "educations_select_public" ON profile_educations
    FOR SELECT USING (
        is_visible = TRUE
        OR user_id = auth.uid()
    );

DROP POLICY IF EXISTS "educations_insert_own" ON profile_educations;
CREATE POLICY "educations_insert_own" ON profile_educations
    FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "educations_update_own" ON profile_educations;
CREATE POLICY "educations_update_own" ON profile_educations
    FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "educations_delete_own" ON profile_educations;
CREATE POLICY "educations_delete_own" ON profile_educations
    FOR DELETE USING (user_id = auth.uid());

-- User Follows Policies
DROP POLICY IF EXISTS "follows_select_all" ON user_follows;
CREATE POLICY "follows_select_all" ON user_follows
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "follows_insert_own" ON user_follows;
CREATE POLICY "follows_insert_own" ON user_follows
    FOR INSERT WITH CHECK (follower_id = auth.uid());

DROP POLICY IF EXISTS "follows_delete_own" ON user_follows;
CREATE POLICY "follows_delete_own" ON user_follows
    FOR DELETE USING (follower_id = auth.uid());

-- Profile Skills Policies
DROP POLICY IF EXISTS "skills_select_public" ON profile_skills;
CREATE POLICY "skills_select_public" ON profile_skills
    FOR SELECT USING (TRUE);

DROP POLICY IF EXISTS "skills_insert_own" ON profile_skills;
CREATE POLICY "skills_insert_own" ON profile_skills
    FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "skills_update_own" ON profile_skills;
CREATE POLICY "skills_update_own" ON profile_skills
    FOR UPDATE USING (user_id = auth.uid());

DROP POLICY IF EXISTS "skills_delete_own" ON profile_skills;
CREATE POLICY "skills_delete_own" ON profile_skills
    FOR DELETE USING (user_id = auth.uid());

COMMIT;
