-- TAMAD HUB - Row Level Security Policies
-- Run this AFTER schema.sql

-- ===========================================
-- ENABLE RLS ON ALL TABLES
-- ===========================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
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
ALTER TABLE ads ENABLE ROW LEVEL SECURITY;
ALTER TABLE ad_impressions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ad_clicks ENABLE ROW LEVEL SECURITY;
ALTER TABLE ad_frequency_config ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- PROFILES POLICIES
-- ===========================================
CREATE POLICY "Public profiles are viewable by everyone"
    ON profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ===========================================
-- COMPANIES POLICIES
-- ===========================================
CREATE POLICY "Companies are viewable by everyone"
    ON companies FOR SELECT
    USING (true);

CREATE POLICY "Users can create companies"
    ON companies FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Company owners can update their companies"
    ON companies FOR UPDATE
    USING (auth.uid() = owner_id);

CREATE POLICY "Company owners can delete their companies"
    ON companies FOR DELETE
    USING (auth.uid() = owner_id);

-- ===========================================
-- COMPANY FOLLOWERS POLICIES
-- ===========================================
CREATE POLICY "Company followers are viewable by everyone"
    ON company_followers FOR SELECT
    USING (true);

CREATE POLICY "Users can follow companies"
    ON company_followers FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unfollow companies"
    ON company_followers FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- COMPANY ADMINS POLICIES
-- ===========================================
CREATE POLICY "Company admins are viewable by company members"
    ON company_admins FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id = company_admins.company_id
            AND companies.owner_id = auth.uid()
        )
        OR user_id = auth.uid()
    );

CREATE POLICY "Company owners can manage admins"
    ON company_admins FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id = company_admins.company_id
            AND companies.owner_id = auth.uid()
        )
    );

-- ===========================================
-- JOBS POLICIES
-- ===========================================
CREATE POLICY "Active jobs are viewable by everyone"
    ON jobs FOR SELECT
    USING (is_active = true OR posted_by = auth.uid());

CREATE POLICY "Company admins can create jobs"
    ON jobs FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id = jobs.company_id
            AND (companies.owner_id = auth.uid() OR EXISTS (
                SELECT 1 FROM company_admins
                WHERE company_admins.company_id = companies.id
                AND company_admins.user_id = auth.uid()
            ))
        )
    );

CREATE POLICY "Company admins can update jobs"
    ON jobs FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id = jobs.company_id
            AND (companies.owner_id = auth.uid() OR EXISTS (
                SELECT 1 FROM company_admins
                WHERE company_admins.company_id = companies.id
                AND company_admins.user_id = auth.uid()
            ))
        )
    );

CREATE POLICY "Company admins can delete jobs"
    ON jobs FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id = jobs.company_id
            AND (companies.owner_id = auth.uid() OR EXISTS (
                SELECT 1 FROM company_admins
                WHERE company_admins.company_id = companies.id
                AND company_admins.user_id = auth.uid()
            ))
        )
    );

-- ===========================================
-- JOB APPLICATIONS POLICIES
-- ===========================================
CREATE POLICY "Users can view own applications"
    ON job_applications FOR SELECT
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM jobs
            JOIN companies ON companies.id = jobs.company_id
            WHERE jobs.id = job_applications.job_id
            AND (companies.owner_id = auth.uid() OR EXISTS (
                SELECT 1 FROM company_admins
                WHERE company_admins.company_id = companies.id
                AND company_admins.user_id = auth.uid()
            ))
        )
    );

CREATE POLICY "Users can apply to jobs"
    ON job_applications FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own applications"
    ON job_applications FOR UPDATE
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM jobs
            JOIN companies ON companies.id = jobs.company_id
            WHERE jobs.id = job_applications.job_id
            AND (companies.owner_id = auth.uid() OR EXISTS (
                SELECT 1 FROM company_admins
                WHERE company_admins.company_id = companies.id
                AND company_admins.user_id = auth.uid()
            ))
        )
    );

-- ===========================================
-- COURSES POLICIES
-- ===========================================
CREATE POLICY "Published courses are viewable by everyone"
    ON courses FOR SELECT
    USING (is_published = true OR instructor_id = auth.uid());

CREATE POLICY "Instructors can create courses"
    ON courses FOR INSERT
    WITH CHECK (auth.uid() = instructor_id);

CREATE POLICY "Instructors can update own courses"
    ON courses FOR UPDATE
    USING (auth.uid() = instructor_id);

CREATE POLICY "Instructors can delete own courses"
    ON courses FOR DELETE
    USING (auth.uid() = instructor_id);

-- ===========================================
-- COURSE SECTIONS POLICIES
-- ===========================================
CREATE POLICY "Sections of published courses are viewable"
    ON course_sections FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id = course_sections.course_id
            AND (courses.is_published = true OR courses.instructor_id = auth.uid())
        )
    );

CREATE POLICY "Instructors can manage course sections"
    ON course_sections FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id = course_sections.course_id
            AND courses.instructor_id = auth.uid()
        )
    );

-- ===========================================
-- LESSONS POLICIES
-- ===========================================
CREATE POLICY "Free preview lessons are viewable by everyone"
    ON lessons FOR SELECT
    USING (
        is_free_preview = true
        OR EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id = lessons.course_id
            AND courses.instructor_id = auth.uid()
        )
        OR EXISTS (
            SELECT 1 FROM enrollments
            WHERE enrollments.course_id = lessons.course_id
            AND enrollments.user_id = auth.uid()
            AND enrollments.status IN ('active', 'completed')
        )
    );

CREATE POLICY "Instructors can manage lessons"
    ON lessons FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id = lessons.course_id
            AND courses.instructor_id = auth.uid()
        )
    );

-- ===========================================
-- ENROLLMENTS POLICIES
-- ===========================================
CREATE POLICY "Users can view own enrollments"
    ON enrollments FOR SELECT
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id = enrollments.course_id
            AND courses.instructor_id = auth.uid()
        )
    );

CREATE POLICY "Users can enroll in courses"
    ON enrollments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own enrollments"
    ON enrollments FOR UPDATE
    USING (user_id = auth.uid());

-- ===========================================
-- LESSON PROGRESS POLICIES
-- ===========================================
CREATE POLICY "Users can view own lesson progress"
    ON lesson_progress FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can track lesson progress"
    ON lesson_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lesson progress"
    ON lesson_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- ===========================================
-- COURSE REVIEWS POLICIES
-- ===========================================
CREATE POLICY "Visible reviews are viewable by everyone"
    ON course_reviews FOR SELECT
    USING (is_visible = true OR user_id = auth.uid());

CREATE POLICY "Enrolled users can review courses"
    ON course_reviews FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
        AND EXISTS (
            SELECT 1 FROM enrollments
            WHERE enrollments.course_id = course_reviews.course_id
            AND enrollments.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own reviews"
    ON course_reviews FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews"
    ON course_reviews FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- POSTS POLICIES
-- ===========================================
CREATE POLICY "Public posts are viewable by everyone"
    ON posts FOR SELECT
    USING (visibility = 'public' OR author_id = auth.uid());

CREATE POLICY "Users can create posts"
    ON posts FOR INSERT
    WITH CHECK (auth.uid() = author_id OR EXISTS (
        SELECT 1 FROM companies
        WHERE companies.id = posts.company_id
        AND (companies.owner_id = auth.uid() OR EXISTS (
            SELECT 1 FROM company_admins
            WHERE company_admins.company_id = companies.id
            AND company_admins.user_id = auth.uid()
        ))
    ));

CREATE POLICY "Users can update own posts"
    ON posts FOR UPDATE
    USING (auth.uid() = author_id);

CREATE POLICY "Users can delete own posts"
    ON posts FOR DELETE
    USING (auth.uid() = author_id);

-- ===========================================
-- POST LIKES POLICIES
-- ===========================================
CREATE POLICY "Post likes are viewable by everyone"
    ON post_likes FOR SELECT
    USING (true);

CREATE POLICY "Users can like posts"
    ON post_likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts"
    ON post_likes FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- POST COMMENTS POLICIES
-- ===========================================
CREATE POLICY "Comments are viewable by everyone"
    ON post_comments FOR SELECT
    USING (true);

CREATE POLICY "Users can create comments"
    ON post_comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
    ON post_comments FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
    ON post_comments FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- COMMENT LIKES POLICIES
-- ===========================================
CREATE POLICY "Comment likes are viewable by everyone"
    ON comment_likes FOR SELECT
    USING (true);

CREATE POLICY "Users can like comments"
    ON comment_likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike comments"
    ON comment_likes FOR DELETE
    USING (auth.uid() = user_id);

-- ===========================================
-- CONVERSATIONS POLICIES
-- ===========================================
CREATE POLICY "Users can view own conversations"
    ON conversations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_participants.conversation_id = conversations.id
            AND conversation_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create conversations"
    ON conversations FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Participants can update conversations"
    ON conversations FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_participants.conversation_id = conversations.id
            AND conversation_participants.user_id = auth.uid()
        )
    );

-- ===========================================
-- CONVERSATION PARTICIPANTS POLICIES
-- ===========================================
CREATE POLICY "Users can view conversation participants"
    ON conversation_participants FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants AS cp
            WHERE cp.conversation_id = conversation_participants.conversation_id
            AND cp.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can add participants to own conversations"
    ON conversation_participants FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM conversations
            WHERE conversations.id = conversation_participants.conversation_id
            AND conversations.created_by = auth.uid()
        )
        OR conversation_participants.user_id = auth.uid()
    );

CREATE POLICY "Users can update own participation"
    ON conversation_participants FOR UPDATE
    USING (user_id = auth.uid());

-- ===========================================
-- MESSAGES POLICIES
-- ===========================================
CREATE POLICY "Users can view messages in own conversations"
    ON messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_participants.conversation_id = messages.conversation_id
            AND conversation_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can send messages to own conversations"
    ON messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id
        AND EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_participants.conversation_id = messages.conversation_id
            AND conversation_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own messages"
    ON messages FOR UPDATE
    USING (auth.uid() = sender_id);

CREATE POLICY "Users can delete own messages"
    ON messages FOR DELETE
    USING (auth.uid() = sender_id);

-- ===========================================
-- MESSAGE READS POLICIES
-- ===========================================
CREATE POLICY "Users can view own message reads"
    ON message_reads FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "Users can mark messages as read"
    ON message_reads FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ===========================================
-- NOTIFICATIONS POLICIES
-- ===========================================
CREATE POLICY "Users can view own notifications"
    ON notifications FOR SELECT
    USING (user_id = auth.uid());

CREATE POLICY "System can create notifications"
    ON notifications FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Users can update own notifications"
    ON notifications FOR UPDATE
    USING (user_id = auth.uid());

CREATE POLICY "Users can delete own notifications"
    ON notifications FOR DELETE
    USING (user_id = auth.uid());

-- ===========================================
-- ADS POLICIES
-- ===========================================
CREATE POLICY "Active ads are viewable by everyone"
    ON ads FOR SELECT
    USING (status = 'active' OR advertiser_id = auth.uid());

CREATE POLICY "Users can create ads"
    ON ads FOR INSERT
    WITH CHECK (auth.uid() = advertiser_id);

CREATE POLICY "Advertisers can update own ads"
    ON ads FOR UPDATE
    USING (auth.uid() = advertiser_id);

CREATE POLICY "Advertisers can delete own ads"
    ON ads FOR DELETE
    USING (auth.uid() = advertiser_id);

-- ===========================================
-- AD IMPRESSIONS POLICIES
-- ===========================================
CREATE POLICY "Advertisers can view own ad impressions"
    ON ad_impressions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM ads
            WHERE ads.id = ad_impressions.ad_id
            AND ads.advertiser_id = auth.uid()
        )
    );

CREATE POLICY "System can log impressions"
    ON ad_impressions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ===========================================
-- AD CLICKS POLICIES
-- ===========================================
CREATE POLICY "Advertisers can view own ad clicks"
    ON ad_clicks FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM ads
            WHERE ads.id = ad_clicks.ad_id
            AND ads.advertiser_id = auth.uid()
        )
    );

CREATE POLICY "System can log clicks"
    ON ad_clicks FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ===========================================
-- AD FREQUENCY CONFIG POLICIES
-- ===========================================
CREATE POLICY "Everyone can read ad frequency config"
    ON ad_frequency_config FOR SELECT
    USING (true);
