-- TAMAD HUB Database Schema
-- Initial Migration

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- ENUM TYPES
-- ============================================

CREATE TYPE user_role AS ENUM ('user', 'instructor', 'admin');
CREATE TYPE company_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');
CREATE TYPE job_type AS ENUM ('full_time', 'part_time', 'contract', 'remote', 'internship');
CREATE TYPE application_status AS ENUM ('pending', 'reviewing', 'shortlisted', 'interview', 'offered', 'accepted', 'rejected', 'withdrawn');
CREATE TYPE course_level AS ENUM ('beginner', 'intermediate', 'advanced');
CREATE TYPE enrollment_status AS ENUM ('active', 'completed', 'paused', 'refunded');
CREATE TYPE notification_type AS ENUM ('job', 'message', 'course', 'company', 'like', 'comment', 'follow', 'system');

-- ============================================
-- USERS TABLE
-- ============================================

CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    bio TEXT,
    headline TEXT,
    location TEXT,
    website TEXT,
    role user_role DEFAULT 'user' NOT NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    skills TEXT[] DEFAULT '{}',
    experience JSONB DEFAULT '[]',
    education JSONB DEFAULT '[]',
    certifications JSONB DEFAULT '[]',
    languages TEXT[] DEFAULT '{}',
    social_links JSONB DEFAULT '{}',
    notification_settings JSONB DEFAULT '{"email": true, "push": true, "sms": false}',
    privacy_settings JSONB DEFAULT '{"profile_visible": true, "show_email": false, "show_phone": false}',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================
-- COMPANIES TABLE
-- ============================================

CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    name_en TEXT,
    description TEXT,
    logo_url TEXT,
    cover_url TEXT,
    industry TEXT,
    company_size TEXT,
    website TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    city TEXT,
    country TEXT DEFAULT 'SA',
    founded_year INTEGER,
    status company_status DEFAULT 'unverified' NOT NULL,
    is_featured BOOLEAN DEFAULT FALSE,
    social_links JSONB DEFAULT '{}',
    -- Legal documents for verification
    commercial_register_number TEXT,
    commercial_register_url TEXT,
    tax_certificate_number TEXT,
    tax_certificate_url TEXT,
    authorization_letter_url TEXT,
    verification_submitted_at TIMESTAMPTZ,
    verification_reviewed_at TIMESTAMPTZ,
    verification_reviewed_by UUID REFERENCES profiles(id),
    verification_notes TEXT,
    follower_count INTEGER DEFAULT 0,
    employee_count INTEGER DEFAULT 0,
    job_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Company admins (users who can manage the company)
CREATE TABLE company_admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    role TEXT DEFAULT 'admin' NOT NULL, -- admin, editor, viewer
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(company_id, user_id)
);

-- Company followers
CREATE TABLE company_followers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(company_id, user_id)
);

-- ============================================
-- JOBS TABLE
-- ============================================

CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    posted_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    requirements TEXT,
    responsibilities TEXT,
    job_type job_type NOT NULL,
    location TEXT,
    is_remote BOOLEAN DEFAULT FALSE,
    salary_min DECIMAL(12, 2),
    salary_max DECIMAL(12, 2),
    salary_currency TEXT DEFAULT 'SAR',
    show_salary BOOLEAN DEFAULT TRUE,
    experience_years_min INTEGER DEFAULT 0,
    experience_years_max INTEGER,
    education_level TEXT,
    skills_required TEXT[] DEFAULT '{}',
    benefits TEXT[] DEFAULT '{}',
    vacancy_count INTEGER DEFAULT 1 NOT NULL,
    accepted_count INTEGER DEFAULT 0 NOT NULL,
    application_deadline TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INTEGER DEFAULT 0,
    application_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    -- Ensure vacancy integrity
    CONSTRAINT valid_vacancy_count CHECK (vacancy_count >= accepted_count)
);

-- Job applications
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    status application_status DEFAULT 'pending' NOT NULL,
    cover_letter TEXT,
    resume_url TEXT,
    expected_salary DECIMAL(12, 2),
    availability_date DATE,
    answers JSONB DEFAULT '{}', -- Custom question answers
    notes TEXT, -- Internal notes from company
    rejection_reason TEXT,
    interview_date TIMESTAMPTZ,
    interview_location TEXT,
    interview_notes TEXT,
    offered_salary DECIMAL(12, 2),
    offer_date TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    rejected_at TIMESTAMPTZ,
    withdrawn_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(job_id, user_id)
);

-- Saved jobs
CREATE TABLE saved_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(job_id, user_id)
);

-- ============================================
-- COURSES TABLE
-- ============================================

CREATE TABLE courses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    instructor_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    short_description TEXT,
    thumbnail_url TEXT,
    preview_video_url TEXT,
    level course_level DEFAULT 'beginner',
    category TEXT,
    subcategory TEXT,
    language TEXT DEFAULT 'ar',
    price DECIMAL(10, 2) DEFAULT 0,
    currency TEXT DEFAULT 'SAR',
    is_free BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    duration_minutes INTEGER DEFAULT 0,
    lesson_count INTEGER DEFAULT 0,
    enrollment_count INTEGER DEFAULT 0,
    rating_average DECIMAL(2, 1) DEFAULT 0,
    rating_count INTEGER DEFAULT 0,
    requirements TEXT[] DEFAULT '{}',
    objectives TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Course sections
CREATE TABLE course_sections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    order_index INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Course lessons
CREATE TABLE course_lessons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    section_id UUID REFERENCES course_sections(id) ON DELETE CASCADE NOT NULL,
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    content_type TEXT DEFAULT 'video' NOT NULL, -- video, text, quiz, assignment
    video_url TEXT,
    duration_seconds INTEGER DEFAULT 0,
    content TEXT, -- For text lessons
    is_free_preview BOOLEAN DEFAULT FALSE,
    order_index INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Course enrollments
CREATE TABLE enrollments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    status enrollment_status DEFAULT 'active' NOT NULL,
    progress_percent INTEGER DEFAULT 0,
    completed_lessons UUID[] DEFAULT '{}',
    current_lesson_id UUID REFERENCES course_lessons(id),
    enrolled_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    completed_at TIMESTAMPTZ,
    certificate_url TEXT,
    payment_id TEXT,
    amount_paid DECIMAL(10, 2) DEFAULT 0,
    UNIQUE(course_id, user_id)
);

-- Lesson progress
CREATE TABLE lesson_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE NOT NULL,
    lesson_id UUID REFERENCES course_lessons(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    watch_time_seconds INTEGER DEFAULT 0,
    last_position_seconds INTEGER DEFAULT 0,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(enrollment_id, lesson_id)
);

-- Course reviews
CREATE TABLE course_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    course_id UUID REFERENCES courses(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(course_id, user_id)
);

-- ============================================
-- POSTS TABLE
-- ============================================

CREATE TABLE posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    media_urls TEXT[] DEFAULT '{}',
    media_types TEXT[] DEFAULT '{}', -- image, video, document
    visibility TEXT DEFAULT 'public', -- public, connections, private
    is_pinned BOOLEAN DEFAULT FALSE,
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    share_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    -- Either author_id or company_id must be set
    CONSTRAINT post_author_check CHECK (author_id IS NOT NULL OR company_id IS NOT NULL)
);

-- Post likes
CREATE TABLE post_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(post_id, user_id)
);

-- Post comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    parent_id UUID REFERENCES post_comments(id) ON DELETE CASCADE, -- For replies
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Comment likes
CREATE TABLE comment_likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(comment_id, user_id)
);

-- ============================================
-- CHAT TABLE
-- ============================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type TEXT DEFAULT 'direct' NOT NULL, -- direct, group
    name TEXT, -- For group chats
    avatar_url TEXT,
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    last_message_at TIMESTAMPTZ,
    last_message_preview TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    role TEXT DEFAULT 'member', -- admin, member
    last_read_at TIMESTAMPTZ,
    is_muted BOOLEAN DEFAULT FALSE,
    joined_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(conversation_id, user_id)
);

CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID REFERENCES conversations(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    content TEXT,
    message_type TEXT DEFAULT 'text', -- text, image, file, system
    media_url TEXT,
    media_name TEXT,
    media_size INTEGER,
    is_edited BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    reply_to_id UUID REFERENCES messages(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Message read receipts
CREATE TABLE message_reads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    message_id UUID REFERENCES messages(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    read_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(message_id, user_id)
);

-- ============================================
-- NOTIFICATIONS TABLE
-- ============================================

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    type notification_type NOT NULL,
    title TEXT NOT NULL,
    message TEXT,
    data JSONB DEFAULT '{}',
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================
-- USER CONNECTIONS (Following)
-- ============================================

CREATE TABLE user_connections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    following_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(follower_id, following_id),
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

-- ============================================
-- ADS TABLE
-- ============================================

CREATE TABLE ads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    cta_text TEXT DEFAULT 'اعرف المزيد',
    placement TEXT DEFAULT 'feed', -- feed, sidebar, banner
    target_audience JSONB DEFAULT '{}',
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    impression_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    budget DECIMAL(10, 2),
    spent DECIMAL(10, 2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Ad interactions for tracking
CREATE TABLE ad_interactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ad_id UUID REFERENCES ads(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    interaction_type TEXT NOT NULL, -- impression, click, dismiss
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- ============================================
-- INDEXES
-- ============================================

-- Profiles indexes
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_email ON profiles(email);

-- Companies indexes
CREATE INDEX idx_companies_owner ON companies(owner_id);
CREATE INDEX idx_companies_status ON companies(status);
CREATE INDEX idx_companies_industry ON companies(industry);

-- Jobs indexes
CREATE INDEX idx_jobs_company ON jobs(company_id);
CREATE INDEX idx_jobs_active ON jobs(is_active);
CREATE INDEX idx_jobs_type ON jobs(job_type);
CREATE INDEX idx_jobs_location ON jobs(location);
CREATE INDEX idx_jobs_created ON jobs(created_at DESC);

-- Applications indexes
CREATE INDEX idx_applications_job ON job_applications(job_id);
CREATE INDEX idx_applications_user ON job_applications(user_id);
CREATE INDEX idx_applications_status ON job_applications(status);

-- Courses indexes
CREATE INDEX idx_courses_instructor ON courses(instructor_id);
CREATE INDEX idx_courses_published ON courses(is_published);
CREATE INDEX idx_courses_category ON courses(category);
CREATE INDEX idx_courses_level ON courses(level);

-- Enrollments indexes
CREATE INDEX idx_enrollments_user ON enrollments(user_id);
CREATE INDEX idx_enrollments_course ON enrollments(course_id);

-- Posts indexes
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_company ON posts(company_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);

-- Messages indexes
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_created ON messages(created_at DESC);

-- Notifications indexes
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read) WHERE NOT is_read;

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to handle job acceptance atomically
CREATE OR REPLACE FUNCTION accept_job_application(
    p_application_id UUID,
    p_offered_salary DECIMAL DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_job_id UUID;
    v_vacancy_count INTEGER;
    v_accepted_count INTEGER;
BEGIN
    -- Get job details
    SELECT j.id, j.vacancy_count, j.accepted_count
    INTO v_job_id, v_vacancy_count, v_accepted_count
    FROM job_applications a
    JOIN jobs j ON j.id = a.job_id
    WHERE a.id = p_application_id
    FOR UPDATE OF j;

    -- Check if vacancy available
    IF v_accepted_count >= v_vacancy_count THEN
        RETURN FALSE;
    END IF;

    -- Update application
    UPDATE job_applications
    SET status = 'accepted',
        accepted_at = NOW(),
        offered_salary = COALESCE(p_offered_salary, offered_salary),
        updated_at = NOW()
    WHERE id = p_application_id;

    -- Increment accepted count
    UPDATE jobs
    SET accepted_count = accepted_count + 1,
        updated_at = NOW()
    WHERE id = v_job_id;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to update course statistics
CREATE OR REPLACE FUNCTION update_course_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE courses
        SET enrollment_count = enrollment_count + 1
        WHERE id = NEW.course_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE courses
        SET enrollment_count = enrollment_count - 1
        WHERE id = OLD.course_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update post like count
CREATE OR REPLACE FUNCTION update_post_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET like_count = like_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET like_count = like_count - 1 WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update comment count
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE posts SET comment_count = comment_count + 1 WHERE id = NEW.post_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE posts SET comment_count = comment_count - 1 WHERE id = OLD.post_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to update company follower count
CREATE OR REPLACE FUNCTION update_company_follower_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE companies SET follower_count = follower_count + 1 WHERE id = NEW.company_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE companies SET follower_count = follower_count - 1 WHERE id = OLD.company_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- TRIGGERS
-- ============================================

-- Updated_at triggers
CREATE TRIGGER tr_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_job_applications_updated_at BEFORE UPDATE ON job_applications FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_courses_updated_at BEFORE UPDATE ON courses FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_posts_updated_at BEFORE UPDATE ON posts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER tr_messages_updated_at BEFORE UPDATE ON messages FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Statistics triggers
CREATE TRIGGER tr_enrollment_stats AFTER INSERT OR DELETE ON enrollments FOR EACH ROW EXECUTE FUNCTION update_course_stats();
CREATE TRIGGER tr_post_like_stats AFTER INSERT OR DELETE ON post_likes FOR EACH ROW EXECUTE FUNCTION update_post_like_count();
CREATE TRIGGER tr_post_comment_stats AFTER INSERT OR DELETE ON post_comments FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();
CREATE TRIGGER tr_company_follower_stats AFTER INSERT OR DELETE ON company_followers FOR EACH ROW EXECUTE FUNCTION update_company_follower_count();

-- ============================================
-- CREATE PROFILE ON USER SIGNUP
-- ============================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, email, full_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
