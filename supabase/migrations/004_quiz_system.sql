-- Migration: 004_quiz_system.sql
-- Description: Add quiz system tables for course assessments

-- Question types enum
DO $$ BEGIN
  CREATE TYPE quiz_question_type AS ENUM (
    'single_choice',
    'multiple_choice',
    'true_false',
    'short_answer'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Quizzes table
CREATE TABLE IF NOT EXISTS quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES lessons(id) ON DELETE SET NULL,

  title TEXT NOT NULL,
  description TEXT,

  -- Settings
  time_limit_minutes INTEGER DEFAULT 30,
  passing_score INTEGER NOT NULL DEFAULT 70,
  max_attempts INTEGER DEFAULT 3,
  shuffle_questions BOOLEAN DEFAULT TRUE,
  shuffle_answers BOOLEAN DEFAULT TRUE,
  show_correct_answers BOOLEAN DEFAULT FALSE,
  is_final_quiz BOOLEAN DEFAULT FALSE,

  -- Status
  is_published BOOLEAN DEFAULT FALSE,
  question_count INTEGER DEFAULT 0,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz questions table
CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,

  question_type quiz_question_type NOT NULL DEFAULT 'single_choice',
  question_text TEXT NOT NULL,
  explanation TEXT,
  points INTEGER NOT NULL DEFAULT 1,
  order_index INTEGER NOT NULL DEFAULT 0,

  -- For short answer
  correct_answer_text TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz answers table (for choice-based questions)
CREATE TABLE IF NOT EXISTS quiz_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,

  answer_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  order_index INTEGER NOT NULL DEFAULT 0,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz attempts table
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,

  attempt_number INTEGER NOT NULL DEFAULT 1,
  score DECIMAL(5,2) NOT NULL DEFAULT 0,
  max_score DECIMAL(5,2) NOT NULL DEFAULT 0,
  percentage DECIMAL(5,2) NOT NULL DEFAULT 0,
  passed BOOLEAN NOT NULL DEFAULT FALSE,

  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  time_spent_seconds INTEGER,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz attempt answers (individual responses)
CREATE TABLE IF NOT EXISTS quiz_attempt_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,

  selected_answer_ids UUID[],
  text_answer TEXT,
  is_correct BOOLEAN,
  points_earned DECIMAL(5,2) DEFAULT 0,

  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Question bank for final quiz composition
CREATE TABLE IF NOT EXISTS course_question_bank (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_course_question UNIQUE (course_id, question_id)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_quizzes_course ON quizzes(course_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_lesson ON quizzes(lesson_id);
CREATE INDEX IF NOT EXISTS idx_quizzes_final ON quizzes(is_final_quiz) WHERE is_final_quiz = TRUE;
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_order ON quiz_questions(quiz_id, order_index);
CREATE INDEX IF NOT EXISTS idx_quiz_answers_question ON quiz_answers(question_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_enrollment ON quiz_attempts(enrollment_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_passed ON quiz_attempts(quiz_id, user_id) WHERE passed = TRUE;
CREATE INDEX IF NOT EXISTS idx_quiz_attempt_answers_attempt ON quiz_attempt_answers(attempt_id);
CREATE INDEX IF NOT EXISTS idx_course_question_bank_course ON course_question_bank(course_id);

-- Triggers
DROP TRIGGER IF EXISTS update_quizzes_updated_at ON quizzes;
CREATE TRIGGER update_quizzes_updated_at
  BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_quiz_questions_updated_at ON quiz_questions;
CREATE TRIGGER update_quiz_questions_updated_at
  BEFORE UPDATE ON quiz_questions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to update quiz question count
CREATE OR REPLACE FUNCTION update_quiz_question_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE quizzes SET question_count = question_count + 1 WHERE id = NEW.quiz_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE quizzes SET question_count = GREATEST(question_count - 1, 0) WHERE id = OLD.quiz_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_quiz_question_count ON quiz_questions;
CREATE TRIGGER trigger_update_quiz_question_count
  AFTER INSERT OR DELETE ON quiz_questions
  FOR EACH ROW EXECUTE FUNCTION update_quiz_question_count();

-- Function to calculate attempt number
CREATE OR REPLACE FUNCTION calculate_attempt_number()
RETURNS TRIGGER AS $$
BEGIN
  SELECT COALESCE(MAX(attempt_number), 0) + 1
  INTO NEW.attempt_number
  FROM quiz_attempts
  WHERE quiz_id = NEW.quiz_id AND user_id = NEW.user_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_calculate_attempt_number ON quiz_attempts;
CREATE TRIGGER trigger_calculate_attempt_number
  BEFORE INSERT ON quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION calculate_attempt_number();

-- Function to check max attempts
CREATE OR REPLACE FUNCTION check_max_attempts()
RETURNS TRIGGER AS $$
DECLARE
  max_allowed INTEGER;
  current_count INTEGER;
BEGIN
  SELECT max_attempts INTO max_allowed FROM quizzes WHERE id = NEW.quiz_id;

  SELECT COUNT(*) INTO current_count
  FROM quiz_attempts
  WHERE quiz_id = NEW.quiz_id AND user_id = NEW.user_id;

  IF current_count >= max_allowed THEN
    RAISE EXCEPTION 'Maximum attempts reached for this quiz';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_check_max_attempts ON quiz_attempts;
CREATE TRIGGER trigger_check_max_attempts
  BEFORE INSERT ON quiz_attempts
  FOR EACH ROW EXECUTE FUNCTION check_max_attempts();

-- RLS Policies
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempt_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE course_question_bank ENABLE ROW LEVEL SECURITY;

-- Quiz policies
DROP POLICY IF EXISTS "Public can view published quizzes" ON quizzes;
CREATE POLICY "Public can view published quizzes"
  ON quizzes FOR SELECT
  USING (
    is_published = TRUE AND
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = quizzes.course_id AND c.is_published = TRUE
    )
  );

DROP POLICY IF EXISTS "Instructors can manage own quizzes" ON quizzes;
CREATE POLICY "Instructors can manage own quizzes"
  ON quizzes FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = quizzes.course_id AND c.instructor_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Question policies
DROP POLICY IF EXISTS "Questions follow quiz access" ON quiz_questions;
CREATE POLICY "Questions follow quiz access"
  ON quiz_questions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id
        AND (q.is_published = TRUE OR c.instructor_id = auth.uid())
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Instructors can manage questions" ON quiz_questions;
CREATE POLICY "Instructors can manage questions"
  ON quiz_questions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id AND c.instructor_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Answer policies
DROP POLICY IF EXISTS "Answers follow question access" ON quiz_answers;
CREATE POLICY "Answers follow question access"
  ON quiz_answers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM quiz_questions qq
      JOIN quizzes q ON q.id = qq.quiz_id
      JOIN courses c ON c.id = q.course_id
      WHERE qq.id = quiz_answers.question_id
        AND (q.is_published = TRUE OR c.instructor_id = auth.uid())
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Instructors can manage answers" ON quiz_answers;
CREATE POLICY "Instructors can manage answers"
  ON quiz_answers FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quiz_questions qq
      JOIN quizzes q ON q.id = qq.quiz_id
      JOIN courses c ON c.id = q.course_id
      WHERE qq.id = quiz_answers.question_id AND c.instructor_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Attempt policies
DROP POLICY IF EXISTS "Users can view own attempts" ON quiz_attempts;
CREATE POLICY "Users can view own attempts"
  ON quiz_attempts FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Instructors can view course attempts" ON quiz_attempts;
CREATE POLICY "Instructors can view course attempts"
  ON quiz_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_attempts.quiz_id AND c.instructor_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Enrolled users can create attempts" ON quiz_attempts;
CREATE POLICY "Enrolled users can create attempts"
  ON quiz_attempts FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM enrollments e
      WHERE e.id = quiz_attempts.enrollment_id
        AND e.user_id = auth.uid()
        AND e.status = 'active'
    )
  );

DROP POLICY IF EXISTS "Users can update own attempts" ON quiz_attempts;
CREATE POLICY "Users can update own attempts"
  ON quiz_attempts FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() AND completed_at IS NULL);

-- Attempt answer policies
DROP POLICY IF EXISTS "Users can view own attempt answers" ON quiz_attempt_answers;
CREATE POLICY "Users can view own attempt answers"
  ON quiz_attempt_answers FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quiz_attempts qa
      WHERE qa.id = attempt_id AND qa.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can create attempt answers" ON quiz_attempt_answers;
CREATE POLICY "Users can create attempt answers"
  ON quiz_attempt_answers FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM quiz_attempts qa
      WHERE qa.id = attempt_id AND qa.user_id = auth.uid() AND qa.completed_at IS NULL
    )
  );

-- Question bank policies
DROP POLICY IF EXISTS "Instructors can manage question bank" ON course_question_bank;
CREATE POLICY "Instructors can manage question bank"
  ON course_question_bank FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = course_question_bank.course_id AND c.instructor_id = auth.uid()
    ) OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
