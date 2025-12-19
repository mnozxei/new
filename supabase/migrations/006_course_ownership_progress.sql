-- Migration: 006_course_ownership_progress.sql
-- Description: Add course ownership model and lesson progress tracking

-- Instructor type enum
DO $$ BEGIN
  CREATE TYPE instructor_type AS ENUM (
    'user_instructor',
    'company_instructor'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Course publish state enum
DO $$ BEGIN
  CREATE TYPE course_publish_state AS ENUM (
    'draft',
    'pending_review',
    'published',
    'archived',
    'rejected'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Add columns to courses table
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS instructor_type instructor_type DEFAULT 'user_instructor',
  ADD COLUMN IF NOT EXISTS company_id UUID REFERENCES companies(id) ON DELETE SET NULL,
  ADD COLUMN IF NOT EXISTS publish_state course_publish_state DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
  ADD COLUMN IF NOT EXISTS submitted_for_review_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS reviewed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS reviewed_by UUID REFERENCES profiles(id);

-- Add lesson lock tracking
ALTER TABLE lessons
  ADD COLUMN IF NOT EXISTS requires_quiz_pass BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS required_quiz_id UUID REFERENCES quizzes(id) ON DELETE SET NULL;

-- Enhance lesson progress
ALTER TABLE lesson_progress
  ADD COLUMN IF NOT EXISTS quiz_passed BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS quiz_attempt_id UUID REFERENCES quiz_attempts(id),
  ADD COLUMN IF NOT EXISTS unlocked_at TIMESTAMPTZ;

-- Lesson unlock tracking table
CREATE TABLE IF NOT EXISTS lesson_unlocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,

  unlocked_by TEXT NOT NULL CHECK (unlocked_by IN ('quiz_pass', 'admin_override', 'free_preview', 'first_lesson')),
  quiz_attempt_id UUID REFERENCES quiz_attempts(id),

  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_lesson_user_unlock UNIQUE (lesson_id, user_id)
);

-- Course progress summary view
CREATE OR REPLACE VIEW course_progress_summary AS
SELECT
  e.id AS enrollment_id,
  e.user_id,
  e.course_id,
  COUNT(DISTINCT l.id) AS total_lessons,
  COUNT(DISTINCT lp.lesson_id) FILTER (WHERE lp.is_completed = TRUE) AS completed_lessons,
  COUNT(DISTINCT lu.lesson_id) AS unlocked_lessons,
  ROUND(
    (COUNT(DISTINCT lp.lesson_id) FILTER (WHERE lp.is_completed = TRUE)::DECIMAL /
    NULLIF(COUNT(DISTINCT l.id), 0)) * 100,
    2
  ) AS progress_percentage,
  EXISTS (
    SELECT 1 FROM quiz_attempts qa
    JOIN quizzes q ON q.id = qa.quiz_id
    WHERE q.course_id = e.course_id
      AND q.is_final_quiz = TRUE
      AND qa.user_id = e.user_id
      AND qa.passed = TRUE
  ) AS final_quiz_passed
FROM enrollments e
JOIN courses c ON c.id = e.course_id
JOIN course_sections cs ON cs.course_id = c.id
JOIN lessons l ON l.section_id = cs.id
LEFT JOIN lesson_progress lp ON lp.lesson_id = l.id AND lp.user_id = e.user_id
LEFT JOIN lesson_unlocks lu ON lu.lesson_id = l.id AND lu.user_id = e.user_id
GROUP BY e.id, e.user_id, e.course_id;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_courses_instructor_type ON courses(instructor_type);
CREATE INDEX IF NOT EXISTS idx_courses_company ON courses(company_id);
CREATE INDEX IF NOT EXISTS idx_courses_publish_state ON courses(publish_state);
CREATE INDEX IF NOT EXISTS idx_lessons_required_quiz ON lessons(required_quiz_id);
CREATE INDEX IF NOT EXISTS idx_lesson_unlocks_lesson ON lesson_unlocks(lesson_id);
CREATE INDEX IF NOT EXISTS idx_lesson_unlocks_user ON lesson_unlocks(user_id);
CREATE INDEX IF NOT EXISTS idx_lesson_unlocks_enrollment ON lesson_unlocks(enrollment_id);

-- Function to check if lesson is accessible
CREATE OR REPLACE FUNCTION is_lesson_accessible(
  p_lesson_id UUID,
  p_user_id UUID,
  p_enrollment_id UUID
)
RETURNS BOOLEAN AS $$
DECLARE
  v_lesson RECORD;
  v_previous_lesson RECORD;
  v_previous_quiz_passed BOOLEAN;
BEGIN
  -- Get the lesson
  SELECT * INTO v_lesson FROM lessons WHERE id = p_lesson_id;

  IF v_lesson IS NULL THEN
    RETURN FALSE;
  END IF;

  -- First lesson of first section is always accessible
  IF v_lesson.order_index = 0 THEN
    SELECT * INTO v_previous_lesson
    FROM lessons l
    JOIN course_sections cs ON cs.id = l.section_id
    WHERE cs.course_id = (
      SELECT cs2.course_id FROM course_sections cs2 WHERE cs2.id = v_lesson.section_id
    )
    AND (cs.order_index < (SELECT order_index FROM course_sections WHERE id = v_lesson.section_id)
      OR (cs.order_index = (SELECT order_index FROM course_sections WHERE id = v_lesson.section_id)
          AND l.order_index < v_lesson.order_index))
    ORDER BY cs.order_index DESC, l.order_index DESC
    LIMIT 1;

    IF v_previous_lesson IS NULL THEN
      RETURN TRUE;
    END IF;
  END IF;

  -- Check if already unlocked
  IF EXISTS (SELECT 1 FROM lesson_unlocks WHERE lesson_id = p_lesson_id AND user_id = p_user_id) THEN
    RETURN TRUE;
  END IF;

  -- Check if free preview
  IF v_lesson.is_free_preview THEN
    RETURN TRUE;
  END IF;

  -- Get previous lesson
  SELECT l.* INTO v_previous_lesson
  FROM lessons l
  JOIN course_sections cs ON cs.id = l.section_id
  WHERE cs.course_id = (
    SELECT cs2.course_id FROM course_sections cs2 WHERE cs2.id = v_lesson.section_id
  )
  AND (cs.order_index < (SELECT order_index FROM course_sections WHERE id = v_lesson.section_id)
    OR (cs.order_index = (SELECT order_index FROM course_sections WHERE id = v_lesson.section_id)
        AND l.order_index < v_lesson.order_index))
  ORDER BY cs.order_index DESC, l.order_index DESC
  LIMIT 1;

  -- If no previous lesson, accessible
  IF v_previous_lesson IS NULL THEN
    RETURN TRUE;
  END IF;

  -- Check if previous lesson is completed
  IF NOT EXISTS (
    SELECT 1 FROM lesson_progress
    WHERE lesson_id = v_previous_lesson.id
      AND user_id = p_user_id
      AND is_completed = TRUE
  ) THEN
    RETURN FALSE;
  END IF;

  -- If previous lesson requires quiz, check if passed
  IF v_previous_lesson.requires_quiz_pass AND v_previous_lesson.required_quiz_id IS NOT NULL THEN
    SELECT EXISTS (
      SELECT 1 FROM quiz_attempts
      WHERE quiz_id = v_previous_lesson.required_quiz_id
        AND user_id = p_user_id
        AND passed = TRUE
    ) INTO v_previous_quiz_passed;

    IF NOT v_previous_quiz_passed THEN
      RETURN FALSE;
    END IF;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function to unlock lesson after quiz pass
CREATE OR REPLACE FUNCTION unlock_next_lesson_on_quiz_pass()
RETURNS TRIGGER AS $$
DECLARE
  v_quiz RECORD;
  v_lesson RECORD;
  v_next_lesson RECORD;
  v_enrollment RECORD;
BEGIN
  -- Only process if quiz was passed
  IF NOT NEW.passed THEN
    RETURN NEW;
  END IF;

  -- Get quiz info
  SELECT * INTO v_quiz FROM quizzes WHERE id = NEW.quiz_id;

  -- If quiz is tied to a lesson
  IF v_quiz.lesson_id IS NOT NULL THEN
    SELECT * INTO v_lesson FROM lessons WHERE id = v_quiz.lesson_id;

    -- Get enrollment
    SELECT * INTO v_enrollment FROM enrollments WHERE id = NEW.enrollment_id;

    -- Find and unlock next lesson
    SELECT l.* INTO v_next_lesson
    FROM lessons l
    JOIN course_sections cs ON cs.id = l.section_id
    WHERE cs.course_id = v_quiz.course_id
    AND (cs.order_index > (SELECT order_index FROM course_sections WHERE id = v_lesson.section_id)
      OR (cs.order_index = (SELECT order_index FROM course_sections WHERE id = v_lesson.section_id)
          AND l.order_index > v_lesson.order_index))
    ORDER BY cs.order_index, l.order_index
    LIMIT 1;

    IF v_next_lesson IS NOT NULL THEN
      INSERT INTO lesson_unlocks (lesson_id, user_id, enrollment_id, unlocked_by, quiz_attempt_id)
      VALUES (v_next_lesson.id, NEW.user_id, NEW.enrollment_id, 'quiz_pass', NEW.id)
      ON CONFLICT (lesson_id, user_id) DO NOTHING;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_unlock_on_quiz_pass ON quiz_attempts;
CREATE TRIGGER trigger_unlock_on_quiz_pass
  AFTER UPDATE ON quiz_attempts
  FOR EACH ROW
  WHEN (NEW.passed = TRUE AND OLD.passed IS DISTINCT FROM NEW.passed)
  EXECUTE FUNCTION unlock_next_lesson_on_quiz_pass();

-- Function to auto-complete enrollment when all lessons done + final quiz passed
CREATE OR REPLACE FUNCTION check_course_completion()
RETURNS TRIGGER AS $$
DECLARE
  v_enrollment RECORD;
  v_course RECORD;
  v_total_lessons INTEGER;
  v_completed_lessons INTEGER;
  v_has_final_quiz BOOLEAN;
  v_final_quiz_passed BOOLEAN;
BEGIN
  -- Get enrollment
  SELECT * INTO v_enrollment FROM enrollments WHERE id = NEW.enrollment_id;

  -- Get course
  SELECT * INTO v_course FROM courses WHERE id = v_enrollment.course_id;

  -- Count lessons
  SELECT COUNT(*) INTO v_total_lessons
  FROM lessons l
  JOIN course_sections cs ON cs.id = l.section_id
  WHERE cs.course_id = v_enrollment.course_id;

  SELECT COUNT(*) INTO v_completed_lessons
  FROM lesson_progress lp
  JOIN lessons l ON l.id = lp.lesson_id
  JOIN course_sections cs ON cs.id = l.section_id
  WHERE cs.course_id = v_enrollment.course_id
    AND lp.user_id = v_enrollment.user_id
    AND lp.is_completed = TRUE;

  -- Check final quiz
  SELECT EXISTS (
    SELECT 1 FROM quizzes WHERE course_id = v_enrollment.course_id AND is_final_quiz = TRUE
  ) INTO v_has_final_quiz;

  IF v_has_final_quiz THEN
    SELECT EXISTS (
      SELECT 1 FROM quiz_attempts qa
      JOIN quizzes q ON q.id = qa.quiz_id
      WHERE q.course_id = v_enrollment.course_id
        AND q.is_final_quiz = TRUE
        AND qa.user_id = v_enrollment.user_id
        AND qa.passed = TRUE
    ) INTO v_final_quiz_passed;
  ELSE
    v_final_quiz_passed := TRUE;
  END IF;

  -- Update enrollment if complete
  IF v_completed_lessons >= v_total_lessons AND v_final_quiz_passed THEN
    UPDATE enrollments
    SET status = 'completed',
        completed_at = NOW(),
        progress_percent = 100
    WHERE id = v_enrollment.id AND status != 'completed';
  ELSE
    -- Update progress percentage
    UPDATE enrollments
    SET progress_percent = ROUND((v_completed_lessons::DECIMAL / NULLIF(v_total_lessons, 0)) * 100)
    WHERE id = v_enrollment.id;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_completion_on_progress ON lesson_progress;
CREATE TRIGGER trigger_check_completion_on_progress
  AFTER INSERT OR UPDATE ON lesson_progress
  FOR EACH ROW
  WHEN (NEW.is_completed = TRUE)
  EXECUTE FUNCTION check_course_completion();

-- RLS for lesson_unlocks
ALTER TABLE lesson_unlocks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own unlocks" ON lesson_unlocks;
CREATE POLICY "Users can view own unlocks"
  ON lesson_unlocks FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admin can view all unlocks" ON lesson_unlocks;
CREATE POLICY "Admin can view all unlocks"
  ON lesson_unlocks FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "System can insert unlocks" ON lesson_unlocks;
CREATE POLICY "System can insert unlocks"
  ON lesson_unlocks FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Admin can manage unlocks" ON lesson_unlocks;
CREATE POLICY "Admin can manage unlocks"
  ON lesson_unlocks FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Update course policies for instructor type
DROP POLICY IF EXISTS "Approved instructors can create courses" ON courses;
CREATE POLICY "Approved instructors can create courses"
  ON courses FOR INSERT
  TO authenticated
  WITH CHECK (
    -- User instructor must be approved
    (
      instructor_type = 'user_instructor'
      AND instructor_id = auth.uid()
      AND EXISTS (
        SELECT 1 FROM instructor_verifications
        WHERE user_id = auth.uid() AND status = 'approved'
      )
    )
    OR
    -- Company instructor - company must be verified
    (
      instructor_type = 'company_instructor'
      AND company_id IS NOT NULL
      AND EXISTS (
        SELECT 1 FROM companies c
        JOIN company_admins ca ON ca.company_id = c.id
        WHERE c.id = courses.company_id
          AND c.status = 'verified'
          AND ca.user_id = auth.uid()
          AND ca.role IN ('owner', 'admin', 'instructor')
      )
    )
    OR
    -- Admin can always create
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
