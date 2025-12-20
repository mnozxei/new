-- =====================================================
-- TAMAD HUB - Comprehensive RLS Policies for Courses
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE lesson_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempt_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE instructor_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE instructor_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE impressions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_categories ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- HELPER FUNCTIONS
-- ===========================================

-- Check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role = 'admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is verified instructor
CREATE OR REPLACE FUNCTION is_verified_instructor()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM instructor_profiles
        WHERE user_id = auth.uid()
        AND verification_status = 'approved'
        AND is_active = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user owns the course (as user instructor)
CREATE OR REPLACE FUNCTION owns_course(course_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = course_id
        AND c.instructor_type = 'user'
        AND c.instructor_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is company instructor for the course
CREATE OR REPLACE FUNCTION is_company_instructor_for_course(course_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM courses c
        JOIN company_admins ca ON c.company_id = ca.company_id
        JOIN companies co ON c.company_id = co.id
        WHERE c.id = course_id
        AND c.instructor_type = 'company'
        AND ca.user_id = auth.uid()
        AND co.status = 'verified'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user can manage course
CREATE OR REPLACE FUNCTION can_manage_course(course_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN is_admin() OR owns_course(course_id) OR is_company_instructor_for_course(course_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user is enrolled in course
CREATE OR REPLACE FUNCTION is_enrolled_in_course(course_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM enrollments
        WHERE enrollments.course_id = course_id
        AND user_id = auth.uid()
        AND status IN ('active', 'completed')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if lesson is unlocked for user
CREATE OR REPLACE FUNCTION is_lesson_unlocked(lesson_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_course_id UUID;
    v_order_index INTEGER;
    v_unlock_after_lesson_id UUID;
    v_enrollment_id UUID;
BEGIN
    -- Get lesson details
    SELECT course_id, order_index, unlock_after_lesson_id
    INTO v_course_id, v_order_index, v_unlock_after_lesson_id
    FROM lessons WHERE id = lesson_id;

    -- Check enrollment
    SELECT id INTO v_enrollment_id
    FROM enrollments
    WHERE course_id = v_course_id AND user_id = auth.uid();

    IF v_enrollment_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- First lesson is always unlocked
    IF v_order_index = 0 AND v_unlock_after_lesson_id IS NULL THEN
        RETURN TRUE;
    END IF;

    -- Check if explicitly unlocked
    RETURN EXISTS (
        SELECT 1 FROM course_progress
        WHERE enrollment_id = v_enrollment_id
        AND lesson_id = lesson_id
        AND is_unlocked = TRUE
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- COURSES POLICIES
-- ===========================================

-- Drop existing policies
DROP POLICY IF EXISTS "Courses: Anyone can view published courses" ON courses;
DROP POLICY IF EXISTS "Courses: Instructors can create courses" ON courses;
DROP POLICY IF EXISTS "Courses: Course owners can update" ON courses;
DROP POLICY IF EXISTS "Courses: Course owners can delete" ON courses;
DROP POLICY IF EXISTS "Courses: Admins have full access" ON courses;

-- Anyone can view published courses
CREATE POLICY "Courses: Anyone can view published courses"
ON courses FOR SELECT
USING (
    is_published = TRUE
    OR can_manage_course(id)
    OR is_admin()
);

-- Verified instructors can create courses
CREATE POLICY "Courses: Verified instructors can create courses"
ON courses FOR INSERT
WITH CHECK (
    (is_verified_instructor() AND instructor_id = auth.uid())
    OR is_admin()
);

-- Course owners can update their courses
CREATE POLICY "Courses: Course owners can update"
ON courses FOR UPDATE
USING (can_manage_course(id))
WITH CHECK (can_manage_course(id));

-- Course owners can delete their courses
CREATE POLICY "Courses: Course owners can delete"
ON courses FOR DELETE
USING (can_manage_course(id));

-- ===========================================
-- COURSE SECTIONS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Sections: Anyone can view sections of published courses" ON course_sections;
DROP POLICY IF EXISTS "Sections: Course owners can manage sections" ON course_sections;

-- Anyone can view sections of published courses
CREATE POLICY "Sections: Anyone can view sections of published courses"
ON course_sections FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM courses
        WHERE courses.id = course_sections.course_id
        AND (is_published = TRUE OR can_manage_course(courses.id))
    )
);

-- Course owners can manage sections
CREATE POLICY "Sections: Course owners can manage sections"
ON course_sections FOR ALL
USING (can_manage_course(course_id))
WITH CHECK (can_manage_course(course_id));

-- ===========================================
-- LESSONS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Lessons: Public preview or enrolled access" ON lessons;
DROP POLICY IF EXISTS "Lessons: Course owners can manage lessons" ON lessons;

-- View lessons: Free preview OR enrolled AND unlocked OR course owner
CREATE POLICY "Lessons: Public preview or enrolled access"
ON lessons FOR SELECT
USING (
    is_free_preview = TRUE
    OR can_manage_course(course_id)
    OR (is_enrolled_in_course(course_id) AND is_lesson_unlocked(id))
    OR (
        -- Allow viewing locked lesson metadata but not content
        EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id = lessons.course_id
            AND is_published = TRUE
        )
    )
);

-- Course owners can manage lessons
CREATE POLICY "Lessons: Course owners can manage lessons"
ON lessons FOR ALL
USING (can_manage_course(course_id))
WITH CHECK (can_manage_course(course_id));

-- ===========================================
-- ENROLLMENTS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Enrollments: Users can view own enrollments" ON enrollments;
DROP POLICY IF EXISTS "Enrollments: Users can enroll in courses" ON enrollments;
DROP POLICY IF EXISTS "Enrollments: Course owners can view enrollments" ON enrollments;

-- Users can view their own enrollments
CREATE POLICY "Enrollments: Users can view own enrollments"
ON enrollments FOR SELECT
USING (
    user_id = auth.uid()
    OR can_manage_course(course_id)
    OR is_admin()
);

-- Authenticated users can enroll in published courses
CREATE POLICY "Enrollments: Users can enroll in courses"
ON enrollments FOR INSERT
WITH CHECK (
    user_id = auth.uid()
    AND EXISTS (
        SELECT 1 FROM courses
        WHERE courses.id = enrollments.course_id
        AND is_published = TRUE
    )
);

-- Users can update their own enrollments (for progress updates)
CREATE POLICY "Enrollments: Users can update own enrollments"
ON enrollments FOR UPDATE
USING (user_id = auth.uid() OR is_admin())
WITH CHECK (user_id = auth.uid() OR is_admin());

-- ===========================================
-- LESSON PROGRESS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Progress: Users can manage own progress" ON lesson_progress;

-- Users can view and update their own progress
CREATE POLICY "Progress: Users can manage own progress"
ON lesson_progress FOR ALL
USING (user_id = auth.uid() OR is_admin())
WITH CHECK (user_id = auth.uid() OR is_admin());

-- ===========================================
-- COURSE PROGRESS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Course Progress: Users manage own progress" ON course_progress;

CREATE POLICY "Course Progress: Users manage own progress"
ON course_progress FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM enrollments
        WHERE enrollments.id = course_progress.enrollment_id
        AND enrollments.user_id = auth.uid()
    )
    OR is_admin()
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM enrollments
        WHERE enrollments.id = course_progress.enrollment_id
        AND enrollments.user_id = auth.uid()
    )
    OR is_admin()
);

-- ===========================================
-- QUIZZES POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Quizzes: Enrolled users can view quizzes" ON quizzes;
DROP POLICY IF EXISTS "Quizzes: Course owners can manage quizzes" ON quizzes;

-- Enrolled users can view quizzes
CREATE POLICY "Quizzes: Enrolled users can view quizzes"
ON quizzes FOR SELECT
USING (
    is_enrolled_in_course(course_id)
    OR can_manage_course(course_id)
    OR is_admin()
);

-- Course owners can manage quizzes
CREATE POLICY "Quizzes: Course owners can manage quizzes"
ON quizzes FOR ALL
USING (can_manage_course(course_id))
WITH CHECK (can_manage_course(course_id));

-- ===========================================
-- QUIZ QUESTIONS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Questions: Enrolled users can view" ON quiz_questions;
DROP POLICY IF EXISTS "Questions: Course owners can manage" ON quiz_questions;

-- Enrolled users can view questions during quiz attempt
CREATE POLICY "Questions: Enrolled users can view"
ON quiz_questions FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM quizzes q
        WHERE q.id = quiz_questions.quiz_id
        AND (is_enrolled_in_course(q.course_id) OR can_manage_course(q.course_id))
    )
);

-- Course owners can manage questions
CREATE POLICY "Questions: Course owners can manage"
ON quiz_questions FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM quizzes q
        WHERE q.id = quiz_questions.quiz_id
        AND can_manage_course(q.course_id)
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM quizzes q
        WHERE q.id = quiz_questions.quiz_id
        AND can_manage_course(q.course_id)
    )
);

-- ===========================================
-- QUIZ ANSWERS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Answers: Enrolled users can view" ON quiz_answers;
DROP POLICY IF EXISTS "Answers: Course owners can manage" ON quiz_answers;

-- Enrolled users can view answers (correct answers hidden in app logic)
CREATE POLICY "Answers: Enrolled users can view"
ON quiz_answers FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM quiz_questions qq
        JOIN quizzes q ON q.id = qq.quiz_id
        WHERE qq.id = quiz_answers.question_id
        AND (is_enrolled_in_course(q.course_id) OR can_manage_course(q.course_id))
    )
);

-- Course owners can manage answers
CREATE POLICY "Answers: Course owners can manage"
ON quiz_answers FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM quiz_questions qq
        JOIN quizzes q ON q.id = qq.quiz_id
        WHERE qq.id = quiz_answers.question_id
        AND can_manage_course(q.course_id)
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM quiz_questions qq
        JOIN quizzes q ON q.id = qq.quiz_id
        WHERE qq.id = quiz_answers.question_id
        AND can_manage_course(q.course_id)
    )
);

-- ===========================================
-- QUIZ ATTEMPTS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Attempts: Users manage own attempts" ON quiz_attempts;
DROP POLICY IF EXISTS "Attempts: Course owners can view" ON quiz_attempts;

-- Users can manage their own attempts
CREATE POLICY "Attempts: Users manage own attempts"
ON quiz_attempts FOR ALL
USING (user_id = auth.uid() OR is_admin())
WITH CHECK (user_id = auth.uid() OR is_admin());

-- Course owners can view attempts for their courses
CREATE POLICY "Attempts: Course owners can view"
ON quiz_attempts FOR SELECT
USING (can_manage_course(course_id));

-- ===========================================
-- QUIZ ATTEMPT ANSWERS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Attempt Answers: Users manage own" ON quiz_attempt_answers;

CREATE POLICY "Attempt Answers: Users manage own"
ON quiz_attempt_answers FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM quiz_attempts
        WHERE quiz_attempts.id = quiz_attempt_answers.attempt_id
        AND quiz_attempts.user_id = auth.uid()
    )
    OR is_admin()
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM quiz_attempts
        WHERE quiz_attempts.id = quiz_attempt_answers.attempt_id
        AND quiz_attempts.user_id = auth.uid()
    )
    OR is_admin()
);

-- ===========================================
-- CERTIFICATES POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Certificates: Users view own" ON certificates;
DROP POLICY IF EXISTS "Certificates: Public verify by serial" ON certificates;
DROP POLICY IF EXISTS "Certificates: Course owners can manage" ON certificates;

-- Users can view their own certificates
CREATE POLICY "Certificates: Users view own"
ON certificates FOR SELECT
USING (user_id = auth.uid() OR is_admin());

-- Anyone can verify certificate by serial (read only specific fields)
CREATE POLICY "Certificates: Public verify by serial"
ON certificates FOR SELECT
USING (
    status = 'issued'
);

-- Course owners and admins can manage certificates
CREATE POLICY "Certificates: Course owners can manage"
ON certificates FOR ALL
USING (can_manage_course(course_id) OR is_admin())
WITH CHECK (can_manage_course(course_id) OR is_admin());

-- ===========================================
-- COURSE REVIEWS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Reviews: Anyone can view visible reviews" ON course_reviews;
DROP POLICY IF EXISTS "Reviews: Enrolled users can add reviews" ON course_reviews;
DROP POLICY IF EXISTS "Reviews: Users can update own reviews" ON course_reviews;

-- Anyone can view visible reviews
CREATE POLICY "Reviews: Anyone can view visible reviews"
ON course_reviews FOR SELECT
USING (is_visible = TRUE OR user_id = auth.uid() OR is_admin());

-- Enrolled users can add reviews
CREATE POLICY "Reviews: Enrolled users can add reviews"
ON course_reviews FOR INSERT
WITH CHECK (
    user_id = auth.uid()
    AND is_enrolled_in_course(course_id)
);

-- Users can update/delete their own reviews
CREATE POLICY "Reviews: Users can update own reviews"
ON course_reviews FOR UPDATE
USING (user_id = auth.uid() OR is_admin())
WITH CHECK (user_id = auth.uid() OR is_admin());

CREATE POLICY "Reviews: Users can delete own reviews"
ON course_reviews FOR DELETE
USING (user_id = auth.uid() OR is_admin());

-- ===========================================
-- INSTRUCTOR PROFILES POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Instructors: Public view approved" ON instructor_profiles;
DROP POLICY IF EXISTS "Instructors: Users manage own profile" ON instructor_profiles;
DROP POLICY IF EXISTS "Instructors: Admins have full access" ON instructor_profiles;

-- Anyone can view approved instructor profiles
CREATE POLICY "Instructors: Public view approved"
ON instructor_profiles FOR SELECT
USING (
    verification_status = 'approved'
    OR user_id = auth.uid()
    OR is_admin()
);

-- Users can manage their own profile
CREATE POLICY "Instructors: Users manage own profile"
ON instructor_profiles FOR ALL
USING (user_id = auth.uid() OR is_admin())
WITH CHECK (user_id = auth.uid() OR is_admin());

-- ===========================================
-- INSTRUCTOR DOCUMENTS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Documents: Users manage own" ON instructor_documents;
DROP POLICY IF EXISTS "Documents: Admins can view all" ON instructor_documents;

-- Users can manage their own documents
CREATE POLICY "Documents: Users manage own"
ON instructor_documents FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM instructor_profiles
        WHERE instructor_profiles.id = instructor_documents.instructor_profile_id
        AND instructor_profiles.user_id = auth.uid()
    )
    OR is_admin()
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM instructor_profiles
        WHERE instructor_profiles.id = instructor_documents.instructor_profile_id
        AND instructor_profiles.user_id = auth.uid()
    )
    OR is_admin()
);

-- ===========================================
-- IMPRESSIONS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Impressions: Anyone can insert" ON impressions;
DROP POLICY IF EXISTS "Impressions: Course owners can view" ON impressions;

-- Anyone can record impressions
CREATE POLICY "Impressions: Anyone can insert"
ON impressions FOR INSERT
WITH CHECK (TRUE);

-- Course owners can view their course impressions
CREATE POLICY "Impressions: Course owners can view"
ON impressions FOR SELECT
USING (
    entity_type = 'course' AND can_manage_course(entity_id)
    OR is_admin()
);

-- ===========================================
-- AUDIT LOGS POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Audit: Admins only" ON audit_logs;

-- Only admins can view audit logs
CREATE POLICY "Audit: Admins only"
ON audit_logs FOR SELECT
USING (is_admin());

-- System can insert audit logs
CREATE POLICY "Audit: System can insert"
ON audit_logs FOR INSERT
WITH CHECK (TRUE);

-- ===========================================
-- SAVED COURSES POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Saved: Users manage own" ON saved_courses;

CREATE POLICY "Saved: Users manage own"
ON saved_courses FOR ALL
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ===========================================
-- COURSE CATEGORIES POLICIES
-- ===========================================

DROP POLICY IF EXISTS "Categories: Anyone can view" ON course_categories;

CREATE POLICY "Categories: Anyone can view"
ON course_categories FOR SELECT
USING (is_active = TRUE);

CREATE POLICY "Categories: Admins can manage"
ON course_categories FOR ALL
USING (is_admin())
WITH CHECK (is_admin());

COMMIT;
