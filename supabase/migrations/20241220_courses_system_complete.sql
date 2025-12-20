-- =====================================================
-- TAMAD HUB - Complete Courses System Migration
-- This migration adds all missing tables and updates
-- for the comprehensive courses system
-- =====================================================

-- ===========================================
-- NEW ENUMS
-- ===========================================
DO $$ BEGIN
    CREATE TYPE instructor_type AS ENUM ('user', 'company');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE quiz_type AS ENUM ('lesson', 'final');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE question_type AS ENUM ('single', 'multiple', 'true_false');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE certificate_status AS ENUM ('issued', 'revoked');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'approved', 'rejected');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ===========================================
-- INSTRUCTOR PROFILES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS instructor_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    instructor_type instructor_type NOT NULL DEFAULT 'user',

    -- Profile info
    headline TEXT,
    biography TEXT,
    specializations TEXT[] DEFAULT '{}',
    qualifications TEXT[] DEFAULT '{}',
    portfolio_url TEXT,
    video_intro_url TEXT,

    -- Verification
    verification_status verification_status DEFAULT 'unverified',
    verification_submitted_at TIMESTAMPTZ,
    verification_reviewed_at TIMESTAMPTZ,
    verification_reviewed_by UUID REFERENCES profiles(id),
    verification_notes TEXT,
    rejection_reason TEXT,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,

    -- Stats
    total_students INTEGER DEFAULT 0,
    total_courses INTEGER DEFAULT 0,
    total_revenue DECIMAL DEFAULT 0,
    average_rating DECIMAL DEFAULT 0,
    rating_count INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Constraints
    UNIQUE(user_id),
    UNIQUE(company_id),
    CHECK (
        (instructor_type = 'user' AND user_id IS NOT NULL AND company_id IS NULL) OR
        (instructor_type = 'company' AND company_id IS NOT NULL)
    )
);

-- ===========================================
-- INSTRUCTOR VERIFICATION DOCUMENTS
-- ===========================================
CREATE TABLE IF NOT EXISTS instructor_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instructor_profile_id UUID NOT NULL REFERENCES instructor_profiles(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL,
    document_url TEXT NOT NULL,
    file_name TEXT,
    file_size INTEGER,
    status verification_status DEFAULT 'pending',
    review_notes TEXT,
    uploaded_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,
    reviewed_by UUID REFERENCES profiles(id)
);

-- ===========================================
-- UPDATE COURSES TABLE - Add instructor type support
-- ===========================================
ALTER TABLE courses ADD COLUMN IF NOT EXISTS instructor_type instructor_type DEFAULT 'user';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS company_id UUID REFERENCES companies(id) ON DELETE SET NULL;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS publish_state TEXT DEFAULT 'draft';
ALTER TABLE courses ADD COLUMN IF NOT EXISTS rejection_reason TEXT;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS has_final_quiz BOOLEAN DEFAULT FALSE;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS final_quiz_id UUID;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS completion_count INTEGER DEFAULT 0;
ALTER TABLE courses ADD COLUMN IF NOT EXISTS certificate_count INTEGER DEFAULT 0;

-- ===========================================
-- UPDATE LESSONS TABLE - Add quiz requirements
-- ===========================================
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS requires_quiz_pass BOOLEAN DEFAULT FALSE;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS unlock_after_lesson_id UUID REFERENCES lessons(id);
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS has_quiz BOOLEAN DEFAULT FALSE;
ALTER TABLE lessons ADD COLUMN IF NOT EXISTS quiz_id UUID;

-- ===========================================
-- QUIZZES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS quizzes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    lesson_id UUID REFERENCES lessons(id) ON DELETE CASCADE,

    title TEXT NOT NULL,
    description TEXT,
    type quiz_type NOT NULL DEFAULT 'lesson',

    -- Settings
    passing_score INTEGER DEFAULT 70,
    time_limit_minutes INTEGER,
    max_attempts INTEGER DEFAULT 3,
    shuffle_questions BOOLEAN DEFAULT TRUE,
    shuffle_answers BOOLEAN DEFAULT TRUE,
    show_correct_answers BOOLEAN DEFAULT FALSE,
    show_explanation BOOLEAN DEFAULT TRUE,

    is_required BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    -- Ensure final quiz has no lesson_id
    CHECK (
        (type = 'lesson' AND lesson_id IS NOT NULL) OR
        (type = 'final' AND lesson_id IS NULL)
    )
);

-- ===========================================
-- QUIZ QUESTIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS quiz_questions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,

    question_type question_type NOT NULL DEFAULT 'single',
    question_text TEXT NOT NULL,
    question_image_url TEXT,
    explanation TEXT,
    points INTEGER DEFAULT 1,
    sort_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- QUIZ ANSWERS (OPTIONS) TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS quiz_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,

    answer_text TEXT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- QUIZ ATTEMPTS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    attempt_number INTEGER DEFAULT 1,
    score DECIMAL DEFAULT 0,
    passed BOOLEAN DEFAULT FALSE,
    time_taken_seconds INTEGER,

    answers JSONB DEFAULT '{}',

    started_at TIMESTAMPTZ NOT NULL,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- QUIZ ATTEMPT ANSWERS TABLE (Detailed log)
-- ===========================================
CREATE TABLE IF NOT EXISTS quiz_attempt_answers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,

    selected_answer_ids UUID[] DEFAULT '{}',
    is_correct BOOLEAN DEFAULT FALSE,
    points_earned DECIMAL DEFAULT 0,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- UPDATE ENROLLMENTS TABLE
-- ===========================================
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS final_quiz_passed BOOLEAN DEFAULT FALSE;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS final_quiz_attempt_id UUID;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS certificate_id UUID;
ALTER TABLE enrollments ADD COLUMN IF NOT EXISTS certificate_issued_at TIMESTAMPTZ;

-- ===========================================
-- COURSE PROGRESS TABLE (Enhanced)
-- ===========================================
CREATE TABLE IF NOT EXISTS course_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,

    is_unlocked BOOLEAN DEFAULT FALSE,
    is_completed BOOLEAN DEFAULT FALSE,
    quiz_passed BOOLEAN,
    quiz_attempt_id UUID REFERENCES quiz_attempts(id),

    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(enrollment_id, lesson_id)
);

-- ===========================================
-- CERTIFICATES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS certificates (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

    serial_number TEXT NOT NULL UNIQUE,
    status certificate_status DEFAULT 'issued',

    -- Cached info for faster display and verification
    course_name TEXT,
    student_name TEXT,
    instructor_name TEXT,
    company_name TEXT,

    -- URLs
    pdf_url TEXT,
    verification_url TEXT,
    qr_code_data TEXT,

    -- Dates
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    revoked_at TIMESTAMPTZ,
    revoked_reason TEXT,
    revoked_by UUID REFERENCES profiles(id),

    created_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(enrollment_id)
);

-- ===========================================
-- IMPRESSIONS TABLE (for courses)
-- ===========================================
CREATE TABLE IF NOT EXISTS impressions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type TEXT NOT NULL,
    entity_id UUID NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    session_id TEXT,
    source TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- AUDIT LOGS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id),
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address TEXT,
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- SAVED COURSES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS saved_courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, course_id)
);

-- ===========================================
-- COURSE CATEGORIES TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS course_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    name_en TEXT,
    slug TEXT UNIQUE NOT NULL,
    icon TEXT,
    color TEXT,
    parent_id UUID REFERENCES course_categories(id),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insert default categories
INSERT INTO course_categories (name, name_en, slug, icon, sort_order) VALUES
('البرمجة والتقنية', 'Programming & Technology', 'programming', 'code', 1),
('التصميم', 'Design', 'design', 'palette', 2),
('الأعمال والإدارة', 'Business & Management', 'business', 'briefcase', 3),
('التسويق', 'Marketing', 'marketing', 'trending_up', 4),
('التطوير الشخصي', 'Personal Development', 'personal-development', 'person', 5),
('اللغات', 'Languages', 'languages', 'translate', 6),
('الصحة واللياقة', 'Health & Fitness', 'health', 'fitness_center', 7),
('التصوير والفيديو', 'Photography & Video', 'photography', 'camera', 8)
ON CONFLICT (slug) DO NOTHING;

-- ===========================================
-- INDEXES
-- ===========================================
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_user ON instructor_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_company ON instructor_profiles(company_id);
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_status ON instructor_profiles(verification_status);
CREATE INDEX IF NOT EXISTS idx_instructor_profiles_active ON instructor_profiles(is_active) WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_instructor_documents_profile ON instructor_documents(instructor_profile_id);
CREATE INDEX IF NOT EXISTS idx_instructor_documents_status ON instructor_documents(status);

CREATE INDEX IF NOT EXISTS idx_courses_company ON courses(company_id);
CREATE INDEX IF NOT EXISTS idx_courses_publish_state ON courses(publish_state);

CREATE INDEX IF NOT EXISTS idx_quizzes_course ON quizzes(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_lesson ON quizzes(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_type ON quizzes(type);

CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_answers_question ON quiz_answers(question_id);

CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_course ON quiz_attempts(course_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_passed ON quiz_attempts(passed) WHERE passed = TRUE;

CREATE INDEX IF NOT EXISTS idx_course_progress_enrollment ON course_progress(enrollment_id);
CREATE INDEX IF NOT EXISTS idx_course_progress_lesson ON course_progress(lesson_id);

CREATE INDEX IF NOT EXISTS idx_certificates_user ON certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course ON certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_serial ON certificates(serial_number);
CREATE INDEX IF NOT EXISTS idx_certificates_status ON certificates(status);

CREATE INDEX IF NOT EXISTS idx_impressions_entity ON impressions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_impressions_user ON impressions(user_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_saved_courses_user ON saved_courses(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_courses_course ON saved_courses(course_id);

-- ===========================================
-- FUNCTIONS
-- ===========================================

-- Function to unlock next lesson after quiz pass
CREATE OR REPLACE FUNCTION unlock_next_lesson_after_quiz()
RETURNS TRIGGER AS $$
DECLARE
    v_lesson_id UUID;
    v_next_lesson_id UUID;
    v_enrollment_id UUID;
BEGIN
    -- Only process if quiz passed
    IF NEW.passed = TRUE AND (OLD IS NULL OR OLD.passed = FALSE) THEN
        -- Get the lesson associated with this quiz
        SELECT lesson_id INTO v_lesson_id
        FROM quizzes
        WHERE id = NEW.quiz_id AND type = 'lesson';

        IF v_lesson_id IS NOT NULL THEN
            -- Get enrollment for this user/course
            SELECT id INTO v_enrollment_id
            FROM enrollments
            WHERE course_id = NEW.course_id AND user_id = NEW.user_id;

            IF v_enrollment_id IS NOT NULL THEN
                -- Update current lesson progress
                INSERT INTO course_progress (enrollment_id, lesson_id, is_unlocked, quiz_passed, quiz_attempt_id)
                VALUES (v_enrollment_id, v_lesson_id, TRUE, TRUE, NEW.id)
                ON CONFLICT (enrollment_id, lesson_id)
                DO UPDATE SET quiz_passed = TRUE, quiz_attempt_id = NEW.id, updated_at = NOW();

                -- Find and unlock the next lesson
                SELECT id INTO v_next_lesson_id
                FROM lessons
                WHERE unlock_after_lesson_id = v_lesson_id
                LIMIT 1;

                IF v_next_lesson_id IS NOT NULL THEN
                    INSERT INTO course_progress (enrollment_id, lesson_id, is_unlocked)
                    VALUES (v_enrollment_id, v_next_lesson_id, TRUE)
                    ON CONFLICT (enrollment_id, lesson_id)
                    DO UPDATE SET is_unlocked = TRUE, updated_at = NOW();
                END IF;
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for quiz unlock
DROP TRIGGER IF EXISTS trigger_unlock_next_lesson ON quiz_attempts;
CREATE TRIGGER trigger_unlock_next_lesson
    AFTER INSERT OR UPDATE ON quiz_attempts
    FOR EACH ROW EXECUTE FUNCTION unlock_next_lesson_after_quiz();

-- Function to update course stats
CREATE OR REPLACE FUNCTION update_course_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.status = 'completed' THEN
        UPDATE courses SET completion_count = completion_count + 1 WHERE id = NEW.course_id;
    ELSIF TG_OP = 'UPDATE' AND NEW.status = 'completed' AND OLD.status != 'completed' THEN
        UPDATE courses SET completion_count = completion_count + 1 WHERE id = NEW.course_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_course_completion ON enrollments;
CREATE TRIGGER trigger_update_course_completion
    AFTER INSERT OR UPDATE ON enrollments
    FOR EACH ROW EXECUTE FUNCTION update_course_stats();

-- Function to update instructor stats
CREATE OR REPLACE FUNCTION update_instructor_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_instructor_id UUID;
BEGIN
    -- Get instructor profile id
    SELECT ip.id INTO v_instructor_id
    FROM instructor_profiles ip
    JOIN courses c ON (
        (c.instructor_type = 'user' AND ip.user_id = c.instructor_id) OR
        (c.instructor_type = 'company' AND ip.company_id = c.company_id)
    )
    WHERE c.id = NEW.course_id;

    IF v_instructor_id IS NOT NULL THEN
        UPDATE instructor_profiles
        SET
            total_students = (
                SELECT COUNT(DISTINCT user_id)
                FROM enrollments e
                JOIN courses c ON e.course_id = c.id
                WHERE (c.instructor_type = 'user' AND instructor_profiles.user_id = c.instructor_id)
                   OR (c.instructor_type = 'company' AND instructor_profiles.company_id = c.company_id)
            ),
            updated_at = NOW()
        WHERE id = v_instructor_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_instructor_stats ON enrollments;
CREATE TRIGGER trigger_update_instructor_stats
    AFTER INSERT ON enrollments
    FOR EACH ROW EXECUTE FUNCTION update_instructor_stats();

-- Function to issue certificate after course completion
CREATE OR REPLACE FUNCTION check_and_issue_certificate()
RETURNS TRIGGER AS $$
DECLARE
    v_has_final_quiz BOOLEAN;
    v_final_quiz_passed BOOLEAN;
    v_certificate_exists BOOLEAN;
BEGIN
    -- Only process completed enrollments
    IF NEW.status = 'completed' AND NEW.certificate_id IS NULL THEN
        -- Check if final quiz is required
        SELECT has_final_quiz INTO v_has_final_quiz
        FROM courses WHERE id = NEW.course_id;

        IF v_has_final_quiz = TRUE THEN
            -- Check if final quiz is passed
            SELECT EXISTS(
                SELECT 1 FROM quiz_attempts qa
                JOIN quizzes q ON qa.quiz_id = q.id
                WHERE q.course_id = NEW.course_id
                AND q.type = 'final'
                AND qa.user_id = NEW.user_id
                AND qa.passed = TRUE
            ) INTO v_final_quiz_passed;

            IF NOT v_final_quiz_passed THEN
                -- Don't issue certificate without final quiz pass
                RETURN NEW;
            END IF;
        END IF;

        -- Update enrollment to mark final quiz passed
        NEW.final_quiz_passed := TRUE;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_certificate ON enrollments;
CREATE TRIGGER trigger_check_certificate
    BEFORE UPDATE ON enrollments
    FOR EACH ROW EXECUTE FUNCTION check_and_issue_certificate();

-- Function to record impression
CREATE OR REPLACE FUNCTION record_impression(
    p_entity_type TEXT,
    p_entity_id UUID,
    p_user_id UUID DEFAULT NULL,
    p_session_id TEXT DEFAULT NULL,
    p_source TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_impression_id UUID;
BEGIN
    INSERT INTO impressions (entity_type, entity_id, user_id, session_id, source)
    VALUES (p_entity_type, p_entity_id, p_user_id, p_session_id, p_source)
    RETURNING id INTO v_impression_id;

    RETURN v_impression_id;
END;
$$ LANGUAGE plpgsql;

-- Function to update lesson duration in course
CREATE OR REPLACE FUNCTION update_course_duration()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE courses
    SET
        duration_minutes = (
            SELECT COALESCE(SUM(duration_seconds) / 60, 0)
            FROM lessons
            WHERE course_id = COALESCE(NEW.course_id, OLD.course_id)
        ),
        lesson_count = (
            SELECT COUNT(*)
            FROM lessons
            WHERE course_id = COALESCE(NEW.course_id, OLD.course_id)
        ),
        updated_at = NOW()
    WHERE id = COALESCE(NEW.course_id, OLD.course_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_course_duration ON lessons;
CREATE TRIGGER trigger_update_course_duration
    AFTER INSERT OR UPDATE OR DELETE ON lessons
    FOR EACH ROW EXECUTE FUNCTION update_course_duration();

-- Update quizzes updated_at
CREATE TRIGGER IF NOT EXISTS update_quizzes_updated_at
    BEFORE UPDATE ON quizzes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER IF NOT EXISTS update_quiz_questions_updated_at
    BEFORE UPDATE ON quiz_questions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER IF NOT EXISTS update_course_progress_updated_at
    BEFORE UPDATE ON course_progress
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER IF NOT EXISTS update_instructor_profiles_updated_at
    BEFORE UPDATE ON instructor_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ===========================================
-- CONSTRAINTS
-- ===========================================

-- Ensure video lessons have YouTube URL
-- Note: This is enforced at application level for flexibility
-- ALTER TABLE lessons ADD CONSTRAINT check_video_url
--     CHECK (content_type != 'video' OR video_url IS NOT NULL);

-- Ensure certificates have unique serial numbers (already defined in table)

-- Ensure enrollment uniqueness (already defined in table)

-- ===========================================
-- INITIAL DATA MIGRATION
-- ===========================================

-- Create instructor profiles for existing course instructors
INSERT INTO instructor_profiles (user_id, instructor_type, verification_status, is_active)
SELECT DISTINCT instructor_id, 'user', 'approved', TRUE
FROM courses
WHERE instructor_id IS NOT NULL
ON CONFLICT (user_id) DO NOTHING;

-- Set first lesson of each section as unlocked by default
-- This is handled in application logic

COMMIT;
