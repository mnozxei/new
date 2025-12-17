-- TAMAD HUB Row Level Security Policies
-- This file contains all RLS policies for secure data access

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE message_reads ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;
ALTER TABLE ad_interactions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- HELPER FUNCTIONS
-- ============================================

-- Check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is company admin
CREATE OR REPLACE FUNCTION is_company_admin(company_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM companies
        WHERE id = company_uuid AND owner_id = auth.uid()
    ) OR EXISTS (
        SELECT 1 FROM company_admins
        WHERE company_id = company_uuid AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is instructor
CREATE OR REPLACE FUNCTION is_instructor()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND role IN ('instructor', 'admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is enrolled in course
CREATE OR REPLACE FUNCTION is_enrolled(course_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM enrollments
        WHERE course_id = course_uuid AND user_id = auth.uid() AND status = 'active'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is conversation participant
CREATE OR REPLACE FUNCTION is_conversation_participant(conversation_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM conversation_participants
        WHERE conversation_id = conversation_uuid AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- PROFILES POLICIES
-- ============================================

-- Anyone can view public profiles
CREATE POLICY "profiles_select_public" ON profiles
    FOR SELECT USING (
        (privacy_settings->>'profile_visible')::boolean = true
        OR id = auth.uid()
        OR is_admin()
    );

-- Users can update their own profile
CREATE POLICY "profiles_update_own" ON profiles
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- Admins can update any profile
CREATE POLICY "profiles_update_admin" ON profiles
    FOR UPDATE USING (is_admin());

-- ============================================
-- COMPANIES POLICIES
-- ============================================

-- Anyone can view verified companies
CREATE POLICY "companies_select_public" ON companies
    FOR SELECT USING (
        status = 'verified'
        OR owner_id = auth.uid()
        OR is_company_admin(id)
        OR is_admin()
    );

-- Authenticated users can create companies
CREATE POLICY "companies_insert" ON companies
    FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- Company owners/admins can update
CREATE POLICY "companies_update" ON companies
    FOR UPDATE USING (
        owner_id = auth.uid()
        OR is_company_admin(id)
        OR is_admin()
    );

-- Only owners can delete companies
CREATE POLICY "companies_delete" ON companies
    FOR DELETE USING (owner_id = auth.uid() OR is_admin());

-- ============================================
-- COMPANY ADMINS POLICIES
-- ============================================

CREATE POLICY "company_admins_select" ON company_admins
    FOR SELECT USING (
        is_company_admin(company_id)
        OR user_id = auth.uid()
        OR is_admin()
    );

CREATE POLICY "company_admins_insert" ON company_admins
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid())
        OR is_admin()
    );

CREATE POLICY "company_admins_delete" ON company_admins
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM companies WHERE id = company_id AND owner_id = auth.uid())
        OR is_admin()
    );

-- ============================================
-- COMPANY FOLLOWERS POLICIES
-- ============================================

CREATE POLICY "company_followers_select" ON company_followers
    FOR SELECT USING (true);

CREATE POLICY "company_followers_insert" ON company_followers
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "company_followers_delete" ON company_followers
    FOR DELETE USING (user_id = auth.uid());

-- ============================================
-- JOBS POLICIES
-- ============================================

-- Anyone can view active jobs from verified companies
CREATE POLICY "jobs_select_public" ON jobs
    FOR SELECT USING (
        (is_active = true AND EXISTS (
            SELECT 1 FROM companies WHERE id = company_id AND status = 'verified'
        ))
        OR is_company_admin(company_id)
        OR is_admin()
    );

-- Company admins can create jobs
CREATE POLICY "jobs_insert" ON jobs
    FOR INSERT WITH CHECK (
        is_company_admin(company_id)
        AND EXISTS (SELECT 1 FROM companies WHERE id = company_id AND status = 'verified')
    );

-- Company admins can update jobs
CREATE POLICY "jobs_update" ON jobs
    FOR UPDATE USING (is_company_admin(company_id) OR is_admin());

-- Company admins can delete jobs
CREATE POLICY "jobs_delete" ON jobs
    FOR DELETE USING (is_company_admin(company_id) OR is_admin());

-- ============================================
-- JOB APPLICATIONS POLICIES
-- ============================================

-- Users can view their own applications, companies can view applications to their jobs
CREATE POLICY "applications_select" ON job_applications
    FOR SELECT USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM jobs j
            WHERE j.id = job_id AND is_company_admin(j.company_id)
        )
        OR is_admin()
    );

-- Users can create applications
CREATE POLICY "applications_insert" ON job_applications
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        AND EXISTS (
            SELECT 1 FROM jobs
            WHERE id = job_id
            AND is_active = true
            AND (application_deadline IS NULL OR application_deadline > NOW())
            AND vacancy_count > accepted_count
        )
    );

-- Users can update their own applications (withdraw)
CREATE POLICY "applications_update_user" ON job_applications
    FOR UPDATE USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Company admins can update applications (status changes)
CREATE POLICY "applications_update_company" ON job_applications
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM jobs j
            WHERE j.id = job_id AND is_company_admin(j.company_id)
        )
    );

-- ============================================
-- SAVED JOBS POLICIES
-- ============================================

CREATE POLICY "saved_jobs_select" ON saved_jobs
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "saved_jobs_insert" ON saved_jobs
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "saved_jobs_delete" ON saved_jobs
    FOR DELETE USING (user_id = auth.uid());

-- ============================================
-- COURSES POLICIES
-- ============================================

-- Anyone can view published courses
CREATE POLICY "courses_select_public" ON courses
    FOR SELECT USING (
        is_published = true
        OR instructor_id = auth.uid()
        OR is_admin()
    );

-- Instructors can create courses
CREATE POLICY "courses_insert" ON courses
    FOR INSERT WITH CHECK (
        instructor_id = auth.uid()
        AND is_instructor()
    );

-- Instructors can update their own courses
CREATE POLICY "courses_update" ON courses
    FOR UPDATE USING (instructor_id = auth.uid() OR is_admin());

-- Instructors can delete their own courses
CREATE POLICY "courses_delete" ON courses
    FOR DELETE USING (instructor_id = auth.uid() OR is_admin());

-- ============================================
-- COURSE SECTIONS POLICIES
-- ============================================

CREATE POLICY "sections_select" ON course_sections
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM courses
            WHERE id = course_id AND (is_published = true OR instructor_id = auth.uid())
        )
        OR is_admin()
    );

CREATE POLICY "sections_insert" ON course_sections
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
    );

CREATE POLICY "sections_update" ON course_sections
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
        OR is_admin()
    );

CREATE POLICY "sections_delete" ON course_sections
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
        OR is_admin()
    );

-- ============================================
-- COURSE LESSONS POLICIES
-- ============================================

CREATE POLICY "lessons_select" ON course_lessons
    FOR SELECT USING (
        is_free_preview = true
        OR is_enrolled(course_id)
        OR EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
        OR is_admin()
    );

CREATE POLICY "lessons_insert" ON course_lessons
    FOR INSERT WITH CHECK (
        EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
    );

CREATE POLICY "lessons_update" ON course_lessons
    FOR UPDATE USING (
        EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
        OR is_admin()
    );

CREATE POLICY "lessons_delete" ON course_lessons
    FOR DELETE USING (
        EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
        OR is_admin()
    );

-- ============================================
-- ENROLLMENTS POLICIES
-- ============================================

CREATE POLICY "enrollments_select" ON enrollments
    FOR SELECT USING (
        user_id = auth.uid()
        OR EXISTS (SELECT 1 FROM courses WHERE id = course_id AND instructor_id = auth.uid())
        OR is_admin()
    );

CREATE POLICY "enrollments_insert" ON enrollments
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "enrollments_update" ON enrollments
    FOR UPDATE USING (user_id = auth.uid() OR is_admin());

-- ============================================
-- LESSON PROGRESS POLICIES
-- ============================================

CREATE POLICY "progress_select" ON lesson_progress
    FOR SELECT USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "progress_insert" ON lesson_progress
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "progress_update" ON lesson_progress
    FOR UPDATE USING (user_id = auth.uid());

-- ============================================
-- COURSE REVIEWS POLICIES
-- ============================================

CREATE POLICY "reviews_select" ON course_reviews
    FOR SELECT USING (is_visible = true OR user_id = auth.uid() OR is_admin());

CREATE POLICY "reviews_insert" ON course_reviews
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        AND is_enrolled(course_id)
    );

CREATE POLICY "reviews_update" ON course_reviews
    FOR UPDATE USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "reviews_delete" ON course_reviews
    FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- ============================================
-- POSTS POLICIES
-- ============================================

-- Anyone can view public posts
CREATE POLICY "posts_select_public" ON posts
    FOR SELECT USING (
        visibility = 'public'
        OR author_id = auth.uid()
        OR (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

-- Users can create posts
CREATE POLICY "posts_insert" ON posts
    FOR INSERT WITH CHECK (
        author_id = auth.uid()
        OR (company_id IS NOT NULL AND is_company_admin(company_id))
    );

-- Authors can update their posts
CREATE POLICY "posts_update" ON posts
    FOR UPDATE USING (
        author_id = auth.uid()
        OR (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

-- Authors can delete their posts
CREATE POLICY "posts_delete" ON posts
    FOR DELETE USING (
        author_id = auth.uid()
        OR (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

-- ============================================
-- POST LIKES POLICIES
-- ============================================

CREATE POLICY "post_likes_select" ON post_likes
    FOR SELECT USING (true);

CREATE POLICY "post_likes_insert" ON post_likes
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "post_likes_delete" ON post_likes
    FOR DELETE USING (user_id = auth.uid());

-- ============================================
-- POST COMMENTS POLICIES
-- ============================================

CREATE POLICY "comments_select" ON post_comments
    FOR SELECT USING (true);

CREATE POLICY "comments_insert" ON post_comments
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "comments_update" ON post_comments
    FOR UPDATE USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "comments_delete" ON post_comments
    FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- ============================================
-- COMMENT LIKES POLICIES
-- ============================================

CREATE POLICY "comment_likes_select" ON comment_likes
    FOR SELECT USING (true);

CREATE POLICY "comment_likes_insert" ON comment_likes
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "comment_likes_delete" ON comment_likes
    FOR DELETE USING (user_id = auth.uid());

-- ============================================
-- CONVERSATIONS POLICIES
-- ============================================

CREATE POLICY "conversations_select" ON conversations
    FOR SELECT USING (
        is_conversation_participant(id)
        OR is_admin()
    );

CREATE POLICY "conversations_insert" ON conversations
    FOR INSERT WITH CHECK (created_by = auth.uid());

CREATE POLICY "conversations_update" ON conversations
    FOR UPDATE USING (
        is_conversation_participant(id)
        OR is_admin()
    );

-- ============================================
-- CONVERSATION PARTICIPANTS POLICIES
-- ============================================

CREATE POLICY "participants_select" ON conversation_participants
    FOR SELECT USING (
        is_conversation_participant(conversation_id)
        OR is_admin()
    );

CREATE POLICY "participants_insert" ON conversation_participants
    FOR INSERT WITH CHECK (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_id = NEW.conversation_id
            AND user_id = auth.uid()
            AND role = 'admin'
        )
    );

CREATE POLICY "participants_update" ON conversation_participants
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "participants_delete" ON conversation_participants
    FOR DELETE USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM conversations
            WHERE id = conversation_id AND created_by = auth.uid()
        )
    );

-- ============================================
-- MESSAGES POLICIES
-- ============================================

CREATE POLICY "messages_select" ON messages
    FOR SELECT USING (
        is_conversation_participant(conversation_id)
        OR is_admin()
    );

CREATE POLICY "messages_insert" ON messages
    FOR INSERT WITH CHECK (
        sender_id = auth.uid()
        AND is_conversation_participant(conversation_id)
    );

CREATE POLICY "messages_update" ON messages
    FOR UPDATE USING (sender_id = auth.uid());

CREATE POLICY "messages_delete" ON messages
    FOR DELETE USING (sender_id = auth.uid() OR is_admin());

-- ============================================
-- MESSAGE READS POLICIES
-- ============================================

CREATE POLICY "message_reads_select" ON message_reads
    FOR SELECT USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "message_reads_insert" ON message_reads
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- ============================================
-- NOTIFICATIONS POLICIES
-- ============================================

CREATE POLICY "notifications_select" ON notifications
    FOR SELECT USING (user_id = auth.uid() OR is_admin());

CREATE POLICY "notifications_insert" ON notifications
    FOR INSERT WITH CHECK (is_admin() OR auth.uid() IS NOT NULL);

CREATE POLICY "notifications_update" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "notifications_delete" ON notifications
    FOR DELETE USING (user_id = auth.uid() OR is_admin());

-- ============================================
-- USER CONNECTIONS POLICIES
-- ============================================

CREATE POLICY "connections_select" ON user_connections
    FOR SELECT USING (
        follower_id = auth.uid()
        OR following_id = auth.uid()
        OR is_admin()
    );

CREATE POLICY "connections_insert" ON user_connections
    FOR INSERT WITH CHECK (follower_id = auth.uid());

CREATE POLICY "connections_delete" ON user_connections
    FOR DELETE USING (follower_id = auth.uid());

-- ============================================
-- ADS POLICIES
-- ============================================

-- Anyone can view active ads
CREATE POLICY "ads_select_public" ON ads
    FOR SELECT USING (
        (is_active = true AND (start_date IS NULL OR start_date <= NOW()) AND (end_date IS NULL OR end_date >= NOW()))
        OR (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

CREATE POLICY "ads_insert" ON ads
    FOR INSERT WITH CHECK (
        (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

CREATE POLICY "ads_update" ON ads
    FOR UPDATE USING (
        (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

CREATE POLICY "ads_delete" ON ads
    FOR DELETE USING (
        (company_id IS NOT NULL AND is_company_admin(company_id))
        OR is_admin()
    );

-- ============================================
-- AD INTERACTIONS POLICIES
-- ============================================

CREATE POLICY "ad_interactions_select" ON ad_interactions
    FOR SELECT USING (
        user_id = auth.uid()
        OR EXISTS (SELECT 1 FROM ads WHERE id = ad_id AND is_company_admin(company_id))
        OR is_admin()
    );

CREATE POLICY "ad_interactions_insert" ON ad_interactions
    FOR INSERT WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
