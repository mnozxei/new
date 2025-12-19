# TAMAD HUB - Production Implementation Plan

## 1. MISSING CHECKLIST

### Roles/Guards
- [ ] Visitor enforcement: block all write operations (likes, comments, applications, enrollments)
- [ ] User instructor verification gate: block instructor tools until verification APPROVED
- [ ] Company instructor verification gate: block company training tools until company verification APPROVED
- [ ] Permission matrix enforcement in route guards
- [ ] API-level role validation (not just frontend guards)

### Verification and Documents
- [ ] User instructor verification table and workflow
- [ ] User instructor document upload (ID, qualifications, portfolio)
- [ ] Company verification document upload integration (currently UI-only)
- [ ] Admin verification review queue
- [ ] Verification status notifications
- [ ] Document re-submission flow for rejected applications
- [ ] Storage bucket policies for secure document access

### Courses/Progress
- [ ] YouTube video player integration
- [ ] YouTube URL validator and ID extractor
- [ ] Lesson completion tracking linked to video watch time
- [ ] Quiz-locked lesson progression enforcement
- [ ] Course ownership model (USER vs COMPANY instructor)
- [ ] Course publish state machine (draft, pending_review, published, archived)
- [ ] Instructor type field on courses (user_instructor, company_instructor)

### Quizzes
- [ ] Quiz database tables (quizzes, questions, answers, attempts)
- [ ] Quiz builder UI for instructors
- [ ] Question bank management per course
- [ ] Final quiz composition from question bank
- [ ] Multiple attempt tracking with attempt limits
- [ ] Quiz passing threshold configuration
- [ ] Quiz result analytics for instructors
- [ ] Quiz-gate enforcement before next lesson

### Certificates
- [ ] Certificate database table with serial numbers
- [ ] PDF certificate generation (server-side Edge Function)
- [ ] QR code generation with verification URL
- [ ] Public certificate verification page
- [ ] Certificate template configuration
- [ ] Certificate issuance automation after course completion + final quiz pass
- [ ] Certificate revocation capability

### Jobs/Applications
- [ ] Application pipeline status tracking
- [ ] Employer application review workflow
- [ ] Interview scheduling integration
- [ ] Application withdrawal flow
- [ ] Job posting approval workflow for companies

### Posts/Moderation
- [ ] Content moderation queue for admin
- [ ] Report content functionality
- [ ] Post visibility controls (public, connections, private)
- [ ] Admin content removal with audit trail
- [ ] Banned words filter

### Chat/Notifications
- [ ] Real-time message delivery (Supabase Realtime)
- [ ] Push notification integration (FCM/APNs)
- [ ] Unread message counts
- [ ] Message read receipts
- [ ] Typing indicators

### Search
- [ ] Full-text search indexes on courses, jobs, users, companies
- [ ] Search result ranking algorithm
- [ ] Recent searches history
- [ ] Search suggestions/autocomplete

### Production Readiness
- [ ] Error boundary implementation
- [ ] Crash reporting (Sentry/Crashlytics)
- [ ] Analytics tracking (events, conversions)
- [ ] Rate limiting on API calls
- [ ] Input validation and sanitization
- [ ] CI/CD pipeline
- [ ] Automated testing (unit, widget, integration)
- [ ] Performance monitoring
- [ ] Audit logging for sensitive operations

---

## 2. CAPABILITY MATRIX

| Action | visitor | user | userInstructor | companyMember | companyInstructor | admin |
|--------|---------|------|----------------|---------------|-------------------|-------|
| **BROWSING** |
| View public posts | YES | YES | YES | YES | YES | YES |
| View job listings | YES | YES | YES | YES | YES | YES |
| View course catalog | YES | YES | YES | YES | YES | YES |
| View company profiles | YES | YES | YES | YES | YES | YES |
| View user profiles | YES | YES | YES | YES | YES | YES |
| **INTERACTIONS** |
| Like posts | NO | YES | YES | YES | YES | YES |
| Comment on posts | NO | YES | YES | YES | YES | YES |
| Create posts | NO | YES | YES | YES | YES | YES |
| Send messages | NO | YES | YES | YES | YES | YES |
| Follow users/companies | NO | YES | YES | YES | YES | YES |
| **JOBS** |
| Apply to jobs | NO | YES | YES | YES | YES | NO |
| Save jobs | NO | YES | YES | YES | YES | YES |
| Post jobs | NO | NO | NO | YES* | YES* | YES |
| Manage job applications | NO | NO | NO | YES* | YES* | YES |
| **COURSES - STUDENT** |
| Enroll in courses | NO | YES | YES | YES | YES | YES |
| Take quizzes | NO | YES | YES | YES | YES | YES |
| Earn certificates | NO | YES | YES | YES | YES | YES |
| Review courses | NO | YES | YES | YES | YES | YES |
| **COURSES - INSTRUCTOR** |
| Apply for instructor | NO | YES | NO | NO | NO | NO |
| Create courses (own) | NO | NO | YES** | NO | NO | YES |
| Create quizzes | NO | NO | YES** | NO | NO | YES |
| Issue certificates | NO | NO | YES** | NO | NO | YES |
| View course analytics | NO | NO | YES** | NO | NO | YES |
| **COURSES - COMPANY** |
| Create company courses | NO | NO | NO | NO | YES*** | YES |
| Manage company training | NO | NO | NO | YES*** | YES*** | YES |
| **COMPANIES** |
| Create company | NO | YES | YES | YES | YES | NO |
| Manage company | NO | NO | NO | YES* | YES* | YES |
| Submit verification | NO | NO | NO | YES* | YES* | YES |
| **ADMIN** |
| Review verifications | NO | NO | NO | NO | NO | YES |
| Moderate content | NO | NO | NO | NO | NO | YES |
| Manage users | NO | NO | NO | NO | NO | YES |
| View analytics | NO | NO | NO | NO | NO | YES |
| Audit logs | NO | NO | NO | NO | NO | YES |

**Legend:**
- `*` = Only for companies where user is owner/admin
- `**` = Only if instructor verification is APPROVED
- `***` = Only if company verification is APPROVED

---

## 3. SUPABASE SCHEMA SQL MIGRATIONS

### Migration 003: Instructor Verification Tables

```sql
-- Migration: 003_instructor_verification.sql

-- Instructor verification status enum
CREATE TYPE instructor_verification_status AS ENUM (
  'not_submitted',
  'pending',
  'approved',
  'rejected',
  'suspended'
);

-- User instructor verifications
CREATE TABLE instructor_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status instructor_verification_status NOT NULL DEFAULT 'not_submitted',

  -- Documents
  id_document_url TEXT,
  qualification_document_url TEXT,
  portfolio_url TEXT,
  bio TEXT,
  specializations TEXT[],
  years_experience INTEGER,

  -- Review
  submitted_at TIMESTAMPTZ,
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES profiles(id),
  rejection_reason TEXT,
  admin_notes TEXT,

  -- Metadata
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_user_verification UNIQUE (user_id)
);

-- Verification history for audit
CREATE TABLE instructor_verification_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES instructor_verifications(id) ON DELETE CASCADE,
  previous_status instructor_verification_status NOT NULL,
  new_status instructor_verification_status NOT NULL,
  changed_by UUID REFERENCES profiles(id),
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_instructor_verifications_user ON instructor_verifications(user_id);
CREATE INDEX idx_instructor_verifications_status ON instructor_verifications(status);
CREATE INDEX idx_instructor_verification_history_verification ON instructor_verification_history(verification_id);

-- Trigger for updated_at
CREATE TRIGGER update_instructor_verifications_updated_at
  BEFORE UPDATE ON instructor_verifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 004: Quiz System Tables

```sql
-- Migration: 004_quiz_system.sql

-- Question types enum
CREATE TYPE quiz_question_type AS ENUM (
  'single_choice',
  'multiple_choice',
  'true_false',
  'short_answer'
);

-- Quizzes table
CREATE TABLE quizzes (
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
CREATE TABLE quiz_questions (
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
CREATE TABLE quiz_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,

  answer_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  order_index INTEGER NOT NULL DEFAULT 0,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz attempts table
CREATE TABLE quiz_attempts (
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
CREATE TABLE quiz_attempt_answers (
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
CREATE TABLE course_question_bank (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_course_question UNIQUE (course_id, question_id)
);

-- Indexes
CREATE INDEX idx_quizzes_course ON quizzes(course_id);
CREATE INDEX idx_quizzes_lesson ON quizzes(lesson_id);
CREATE INDEX idx_quiz_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX idx_quiz_answers_question ON quiz_answers(question_id);
CREATE INDEX idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_enrollment ON quiz_attempts(enrollment_id);
CREATE INDEX idx_quiz_attempt_answers_attempt ON quiz_attempt_answers(attempt_id);
CREATE INDEX idx_course_question_bank_course ON course_question_bank(course_id);

-- Triggers
CREATE TRIGGER update_quizzes_updated_at
  BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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
    UPDATE quizzes SET question_count = question_count - 1 WHERE id = OLD.quiz_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_quiz_question_count
  AFTER INSERT OR DELETE ON quiz_questions
  FOR EACH ROW EXECUTE FUNCTION update_quiz_question_count();
```

### Migration 005: Certificate System

```sql
-- Migration: 005_certificate_system.sql

-- Certificate status enum
CREATE TYPE certificate_status AS ENUM (
  'issued',
  'revoked',
  'expired'
);

-- Certificates table
CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- References
  enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  issued_by UUID NOT NULL REFERENCES profiles(id),

  -- Certificate details
  serial_number TEXT NOT NULL UNIQUE,
  verification_token TEXT NOT NULL UNIQUE,

  -- Content
  recipient_name TEXT NOT NULL,
  course_title TEXT NOT NULL,
  issuer_name TEXT NOT NULL,
  issuer_type TEXT NOT NULL CHECK (issuer_type IN ('user_instructor', 'company_instructor')),
  company_id UUID REFERENCES companies(id),
  company_name TEXT,

  -- Scores
  final_quiz_score DECIMAL(5,2),
  completion_percentage INTEGER DEFAULT 100,

  -- Files
  pdf_url TEXT,
  qr_code_url TEXT,

  -- Status
  status certificate_status NOT NULL DEFAULT 'issued',
  revoked_at TIMESTAMPTZ,
  revoked_by UUID REFERENCES profiles(id),
  revocation_reason TEXT,

  -- Dates
  issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_enrollment_certificate UNIQUE (enrollment_id)
);

-- Certificate verification logs
CREATE TABLE certificate_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id UUID NOT NULL REFERENCES certificates(id) ON DELETE CASCADE,
  verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

-- Indexes
CREATE INDEX idx_certificates_user ON certificates(user_id);
CREATE INDEX idx_certificates_course ON certificates(course_id);
CREATE INDEX idx_certificates_serial ON certificates(serial_number);
CREATE INDEX idx_certificates_token ON certificates(verification_token);
CREATE INDEX idx_certificate_verifications_cert ON certificate_verifications(certificate_id);

-- Trigger
CREATE TRIGGER update_certificates_updated_at
  BEFORE UPDATE ON certificates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate serial number
CREATE OR REPLACE FUNCTION generate_certificate_serial()
RETURNS TEXT AS $$
DECLARE
  year_part TEXT;
  random_part TEXT;
  counter_part TEXT;
  cert_count INTEGER;
BEGIN
  year_part := TO_CHAR(NOW(), 'YYYY');
  random_part := UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 4));

  SELECT COUNT(*) + 1 INTO cert_count FROM certificates
  WHERE EXTRACT(YEAR FROM created_at) = EXTRACT(YEAR FROM NOW());

  counter_part := LPAD(cert_count::TEXT, 6, '0');

  RETURN 'TMAD-' || year_part || '-' || random_part || '-' || counter_part;
END;
$$ LANGUAGE plpgsql;

-- Function to generate verification token
CREATE OR REPLACE FUNCTION generate_verification_token()
RETURNS TEXT AS $$
BEGIN
  RETURN ENCODE(GEN_RANDOM_BYTES(32), 'hex');
END;
$$ LANGUAGE plpgsql;
```

### Migration 006: Course Ownership and Progress

```sql
-- Migration: 006_course_ownership_progress.sql

-- Instructor type enum
CREATE TYPE instructor_type AS ENUM (
  'user_instructor',
  'company_instructor'
);

-- Course publish state enum
CREATE TYPE course_publish_state AS ENUM (
  'draft',
  'pending_review',
  'published',
  'archived',
  'rejected'
);

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
  ADD COLUMN IF NOT EXISTS required_quiz_id UUID REFERENCES quizzes(id);

-- Lesson progress enhancements
ALTER TABLE lesson_progress
  ADD COLUMN IF NOT EXISTS quiz_passed BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS quiz_attempt_id UUID REFERENCES quiz_attempts(id),
  ADD COLUMN IF NOT EXISTS unlocked_at TIMESTAMPTZ;

-- Create lesson unlock tracking
CREATE TABLE lesson_unlocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrollment_id UUID NOT NULL REFERENCES enrollments(id) ON DELETE CASCADE,

  unlocked_by TEXT NOT NULL CHECK (unlocked_by IN ('quiz_pass', 'admin_override', 'free_preview')),
  quiz_attempt_id UUID REFERENCES quiz_attempts(id),

  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  CONSTRAINT unique_lesson_user_unlock UNIQUE (lesson_id, user_id)
);

-- Indexes
CREATE INDEX idx_courses_instructor_type ON courses(instructor_type);
CREATE INDEX idx_courses_company ON courses(company_id);
CREATE INDEX idx_courses_publish_state ON courses(publish_state);
CREATE INDEX idx_lesson_unlocks_lesson ON lesson_unlocks(lesson_id);
CREATE INDEX idx_lesson_unlocks_user ON lesson_unlocks(user_id);
CREATE INDEX idx_lesson_unlocks_enrollment ON lesson_unlocks(enrollment_id);
```

### Migration 007: Moderation and Audit

```sql
-- Migration: 007_moderation_audit.sql

-- Report reason enum
CREATE TYPE report_reason AS ENUM (
  'spam',
  'harassment',
  'inappropriate_content',
  'misinformation',
  'copyright_violation',
  'other'
);

-- Report status enum
CREATE TYPE report_status AS ENUM (
  'pending',
  'under_review',
  'resolved_removed',
  'resolved_warned',
  'resolved_dismissed'
);

-- Content reports table
CREATE TABLE content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Reporter
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Content reference (polymorphic)
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'comment', 'job', 'course', 'message', 'profile')),
  content_id UUID NOT NULL,

  -- Report details
  reason report_reason NOT NULL,
  description TEXT,

  -- Status
  status report_status NOT NULL DEFAULT 'pending',

  -- Resolution
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES profiles(id),
  resolution_notes TEXT,
  action_taken TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Admin actions log
CREATE TABLE admin_actions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_id UUID NOT NULL REFERENCES profiles(id),

  action_type TEXT NOT NULL,
  target_type TEXT NOT NULL,
  target_id UUID NOT NULL,

  details JSONB,
  reason TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Audit logs table
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Actor
  user_id UUID REFERENCES profiles(id),
  user_role TEXT,
  ip_address INET,
  user_agent TEXT,

  -- Action
  action TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id UUID,

  -- Changes
  old_values JSONB,
  new_values JSONB,

  -- Metadata
  request_id TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Banned words table
CREATE TABLE banned_words (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word TEXT NOT NULL UNIQUE,
  severity TEXT NOT NULL DEFAULT 'warn' CHECK (severity IN ('warn', 'block', 'ban')),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User warnings/bans
CREATE TABLE user_moderation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  action_type TEXT NOT NULL CHECK (action_type IN ('warning', 'temporary_ban', 'permanent_ban')),
  reason TEXT NOT NULL,

  issued_by UUID NOT NULL REFERENCES profiles(id),

  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ,

  is_active BOOLEAN DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_content_reports_status ON content_reports(status);
CREATE INDEX idx_content_reports_content ON content_reports(content_type, content_id);
CREATE INDEX idx_admin_actions_admin ON admin_actions(admin_id);
CREATE INDEX idx_admin_actions_target ON admin_actions(target_type, target_id);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);
CREATE INDEX idx_user_moderation_user ON user_moderation(user_id);
CREATE INDEX idx_user_moderation_active ON user_moderation(is_active);

-- Triggers
CREATE TRIGGER update_content_reports_updated_at
  BEFORE UPDATE ON content_reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 008: Search Indexes

```sql
-- Migration: 008_search_indexes.sql

-- Add full-text search vectors
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS search_vector tsvector;

ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS search_vector tsvector;

ALTER TABLE jobs
  ADD COLUMN IF NOT EXISTS search_vector tsvector;

ALTER TABLE companies
  ADD COLUMN IF NOT EXISTS search_vector tsvector;

ALTER TABLE posts
  ADD COLUMN IF NOT EXISTS search_vector tsvector;

-- Create GIN indexes for fast full-text search
CREATE INDEX idx_profiles_search ON profiles USING GIN(search_vector);
CREATE INDEX idx_courses_search ON courses USING GIN(search_vector);
CREATE INDEX idx_jobs_search ON jobs USING GIN(search_vector);
CREATE INDEX idx_companies_search ON companies USING GIN(search_vector);
CREATE INDEX idx_posts_search ON posts USING GIN(search_vector);

-- Function to update profile search vector
CREATE OR REPLACE FUNCTION update_profile_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', COALESCE(NEW.full_name, '')), 'A') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.headline, '')), 'B') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.bio, '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(NEW.full_name, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.headline, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update course search vector
CREATE OR REPLACE FUNCTION update_course_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.short_description, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update job search vector
CREATE OR REPLACE FUNCTION update_job_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.requirements, '')), 'C') ||
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update company search vector
CREATE OR REPLACE FUNCTION update_company_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('arabic', COALESCE(NEW.industry, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.name, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update post search vector
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', COALESCE(NEW.content, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER trigger_update_profile_search
  BEFORE INSERT OR UPDATE OF full_name, headline, bio ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_profile_search_vector();

CREATE TRIGGER trigger_update_course_search
  BEFORE INSERT OR UPDATE OF title, description, short_description ON courses
  FOR EACH ROW EXECUTE FUNCTION update_course_search_vector();

CREATE TRIGGER trigger_update_job_search
  BEFORE INSERT OR UPDATE OF title, description, requirements ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_job_search_vector();

CREATE TRIGGER trigger_update_company_search
  BEFORE INSERT OR UPDATE OF name, description, industry ON companies
  FOR EACH ROW EXECUTE FUNCTION update_company_search_vector();

CREATE TRIGGER trigger_update_post_search
  BEFORE INSERT OR UPDATE OF content ON posts
  FOR EACH ROW EXECUTE FUNCTION update_post_search_vector();

-- Search function
CREATE OR REPLACE FUNCTION search_all(query TEXT, search_limit INTEGER DEFAULT 10)
RETURNS TABLE (
  result_type TEXT,
  result_id UUID,
  title TEXT,
  subtitle TEXT,
  image_url TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY

  SELECT 'profile'::TEXT, p.id, p.full_name, p.headline, p.avatar_url, ts_rank(p.search_vector, plainto_tsquery(query)) as rank
  FROM profiles p
  WHERE p.search_vector @@ plainto_tsquery(query)

  UNION ALL

  SELECT 'course'::TEXT, c.id, c.title, c.short_description, c.thumbnail_url, ts_rank(c.search_vector, plainto_tsquery(query)) as rank
  FROM courses c
  WHERE c.search_vector @@ plainto_tsquery(query) AND c.is_published = TRUE

  UNION ALL

  SELECT 'job'::TEXT, j.id, j.title, j.location, NULL, ts_rank(j.search_vector, plainto_tsquery(query)) as rank
  FROM jobs j
  WHERE j.search_vector @@ plainto_tsquery(query) AND j.is_active = TRUE

  UNION ALL

  SELECT 'company'::TEXT, co.id, co.name, co.industry, co.logo_url, ts_rank(co.search_vector, plainto_tsquery(query)) as rank
  FROM companies co
  WHERE co.search_vector @@ plainto_tsquery(query)

  ORDER BY rank DESC
  LIMIT search_limit;
END;
$$ LANGUAGE plpgsql;
```

---

## 4. RLS POLICIES

```sql
-- RLS Policies for TAMAD HUB
-- Organized by table

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

-- Check if user is approved instructor
CREATE OR REPLACE FUNCTION is_approved_instructor()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM instructor_verifications
    WHERE user_id = auth.uid() AND status = 'approved'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if user can access company (owner or admin)
CREATE OR REPLACE FUNCTION can_access_company(company_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM company_admins
    WHERE company_id = company_uuid
      AND user_id = auth.uid()
      AND (role = 'owner' OR role = 'admin')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check if company is verified
CREATE OR REPLACE FUNCTION is_company_verified(company_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM companies
    WHERE id = company_uuid AND status = 'verified'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- INSTRUCTOR VERIFICATIONS
-- ============================================

ALTER TABLE instructor_verifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own verification
CREATE POLICY "Users can view own verification"
  ON instructor_verifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin());

-- Users can insert their own verification
CREATE POLICY "Users can create own verification"
  ON instructor_verifications FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can update own verification if not approved
CREATE POLICY "Users can update own pending verification"
  ON instructor_verifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() AND status IN ('not_submitted', 'rejected'))
  WITH CHECK (user_id = auth.uid());

-- Admins can update any verification
CREATE POLICY "Admins can update any verification"
  ON instructor_verifications FOR UPDATE
  TO authenticated
  USING (is_admin());

-- ============================================
-- QUIZZES
-- ============================================

ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

-- Anyone can view published quizzes for published courses
CREATE POLICY "Public can view published quizzes"
  ON quizzes FOR SELECT
  USING (
    is_published = TRUE AND
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = quizzes.course_id AND c.is_published = TRUE
    )
  );

-- Course instructors can manage quizzes
CREATE POLICY "Instructors can manage own course quizzes"
  ON quizzes FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = quizzes.course_id AND c.instructor_id = auth.uid()
    ) OR is_admin()
  );

-- Company instructors can manage company course quizzes
CREATE POLICY "Company instructors can manage company quizzes"
  ON quizzes FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      JOIN company_admins ca ON ca.company_id = c.company_id
      WHERE c.id = quizzes.course_id
        AND ca.user_id = auth.uid()
        AND ca.role IN ('owner', 'admin', 'instructor')
    )
  );

-- ============================================
-- QUIZ QUESTIONS
-- ============================================

ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;

-- Same policies as quizzes (through quiz ownership)
CREATE POLICY "Quiz questions inherit quiz access"
  ON quiz_questions FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      WHERE q.id = quiz_questions.quiz_id
    )
  );

CREATE POLICY "Quiz owners can manage questions"
  ON quiz_questions FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_questions.quiz_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
  );

-- ============================================
-- QUIZ ANSWERS
-- ============================================

ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Quiz answers inherit question access"
  ON quiz_answers FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM quiz_questions qq
      WHERE qq.id = quiz_answers.question_id
    )
  );

CREATE POLICY "Question owners can manage answers"
  ON quiz_answers FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quiz_questions qq
      JOIN quizzes q ON q.id = qq.quiz_id
      JOIN courses c ON c.id = q.course_id
      WHERE qq.id = quiz_answers.question_id
        AND (c.instructor_id = auth.uid() OR is_admin())
    )
  );

-- ============================================
-- QUIZ ATTEMPTS
-- ============================================

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

-- Users can view their own attempts
CREATE POLICY "Users can view own attempts"
  ON quiz_attempts FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin());

-- Users can create attempts for enrolled courses
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

-- Users can update their own in-progress attempts
CREATE POLICY "Users can update own attempts"
  ON quiz_attempts FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() AND completed_at IS NULL);

-- Course instructors can view all attempts
CREATE POLICY "Instructors can view course attempts"
  ON quiz_attempts FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM quizzes q
      JOIN courses c ON c.id = q.course_id
      WHERE q.id = quiz_attempts.quiz_id
        AND c.instructor_id = auth.uid()
    )
  );

-- ============================================
-- CERTIFICATES
-- ============================================

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- Public can view valid certificates (for verification)
CREATE POLICY "Public can view issued certificates"
  ON certificates FOR SELECT
  USING (status = 'issued');

-- Users can view their own certificates
CREATE POLICY "Users can view own certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Only system/admin can insert certificates
CREATE POLICY "System can issue certificates"
  ON certificates FOR INSERT
  TO authenticated
  WITH CHECK (is_admin() OR issued_by = auth.uid());

-- Only admin can update certificates (revoke)
CREATE POLICY "Admin can update certificates"
  ON certificates FOR UPDATE
  TO authenticated
  USING (is_admin());

-- ============================================
-- COURSES (Enhanced)
-- ============================================

-- Drop existing policies if any conflict
DROP POLICY IF EXISTS "instructor_courses_policy" ON courses;

-- Visitors/public can view published courses
CREATE POLICY "Public can view published courses"
  ON courses FOR SELECT
  USING (is_published = TRUE AND publish_state = 'published');

-- Authenticated users can view all published + their drafts
CREATE POLICY "Auth users view published and own courses"
  ON courses FOR SELECT
  TO authenticated
  USING (
    (is_published = TRUE AND publish_state = 'published') OR
    instructor_id = auth.uid() OR
    (company_id IS NOT NULL AND can_access_company(company_id)) OR
    is_admin()
  );

-- Only approved instructors can create courses
CREATE POLICY "Approved instructors can create courses"
  ON courses FOR INSERT
  TO authenticated
  WITH CHECK (
    (instructor_type = 'user_instructor' AND is_approved_instructor()) OR
    (instructor_type = 'company_instructor' AND is_company_verified(company_id) AND can_access_company(company_id)) OR
    is_admin()
  );

-- Instructors can update own courses
CREATE POLICY "Instructors can update own courses"
  ON courses FOR UPDATE
  TO authenticated
  USING (
    instructor_id = auth.uid() OR
    (company_id IS NOT NULL AND can_access_company(company_id)) OR
    is_admin()
  );

-- ============================================
-- CONTENT REPORTS
-- ============================================

ALTER TABLE content_reports ENABLE ROW LEVEL SECURITY;

-- Users can create reports
CREATE POLICY "Users can create reports"
  ON content_reports FOR INSERT
  TO authenticated
  WITH CHECK (reporter_id = auth.uid());

-- Users can view own reports
CREATE POLICY "Users can view own reports"
  ON content_reports FOR SELECT
  TO authenticated
  USING (reporter_id = auth.uid() OR is_admin());

-- Only admin can update reports
CREATE POLICY "Admin can manage reports"
  ON content_reports FOR UPDATE
  TO authenticated
  USING (is_admin());

-- ============================================
-- AUDIT LOGS
-- ============================================

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Only admin can view audit logs
CREATE POLICY "Admin can view audit logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (is_admin());

-- System can insert audit logs
CREATE POLICY "System can insert audit logs"
  ON audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (TRUE);

-- ============================================
-- LESSON UNLOCKS
-- ============================================

ALTER TABLE lesson_unlocks ENABLE ROW LEVEL SECURITY;

-- Users can view their own unlocks
CREATE POLICY "Users can view own unlocks"
  ON lesson_unlocks FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR is_admin());

-- System inserts unlocks (via triggers/functions)
CREATE POLICY "System can manage unlocks"
  ON lesson_unlocks FOR ALL
  TO authenticated
  WITH CHECK (user_id = auth.uid() OR is_admin());
```

---

## 5. FLUTTER ROUTING/GUARDS PLAN

### Updated Route Guards Structure

**File: `lib/core/auth/route_guard.dart`**

```dart
// Add new permission types
enum Permission {
  // Existing
  viewPosts,
  createPost,
  viewJobs,
  applyToJob,
  viewCourses,
  enrollInCourse,

  // New instructor permissions
  accessInstructorDashboard,
  createCourse,
  manageOwnCourses,
  createQuiz,
  issueCertificate,

  // New company permissions
  accessCompanyDashboard,
  manageCompanyCourses,
  postCompanyJob,

  // Admin permissions
  accessAdminDashboard,
  reviewVerifications,
  moderateContent,
  manageUsers,
}

// Verification gate helper
class VerificationGate {
  static Future<bool> isUserInstructorApproved(String userId) async {
    // Check instructor_verifications table
  }

  static Future<bool> isCompanyVerified(String companyId) async {
    // Check companies.status = 'verified'
  }
}
```

### New Route Definitions

```dart
// Add to app_router.dart

// Instructor verification application
GoRoute(
  path: RouteNames.instructorVerification,
  name: RouteNames.instructorVerification,
  builder: (context, state) => const InstructorVerificationPage(),
),

// Instructor dashboard with verification gate
GoRoute(
  path: RouteNames.instructorDashboard,
  name: RouteNames.instructorDashboard,
  redirect: (context, state) async {
    final isApproved = await VerificationGate.isUserInstructorApproved(
      getIt<AuthService>().currentUserId!
    );
    if (!isApproved) {
      return RouteNames.instructorVerification;
    }
    return null;
  },
  builder: (context, state) => const InstructorDashboardPage(),
  routes: [
    // Quiz builder
    GoRoute(
      path: '${RouteNames.quizBuilder}/:courseId',
      name: RouteNames.quizBuilder,
      builder: (context, state) {
        final courseId = state.pathParameters['courseId']!;
        return QuizBuilderPage(courseId: courseId);
      },
    ),
  ],
),

// Company training dashboard with verification gate
GoRoute(
  path: '${RouteNames.companyTraining}/:companyId',
  name: RouteNames.companyTraining,
  redirect: (context, state) async {
    final companyId = state.pathParameters['companyId']!;
    final isVerified = await VerificationGate.isCompanyVerified(companyId);
    if (!isVerified) {
      return '${RouteNames.companies}/$companyId/${RouteNames.companyVerification}';
    }
    return null;
  },
  builder: (context, state) {
    final companyId = state.pathParameters['companyId']!;
    return CompanyTrainingDashboardPage(companyId: companyId);
  },
),

// Certificate verification (public)
GoRoute(
  path: '${RouteNames.verifyCertificate}/:token',
  name: RouteNames.verifyCertificate,
  builder: (context, state) {
    final token = state.pathParameters['token']!;
    return CertificateVerificationPage(token: token);
  },
),

// Admin verification review
GoRoute(
  path: '${RouteNames.adminDashboard}/${RouteNames.adminVerifications}',
  name: RouteNames.adminVerifications,
  builder: (context, state) => const AdminVerificationReviewPage(),
),

// Admin moderation queue
GoRoute(
  path: '${RouteNames.adminDashboard}/${RouteNames.adminModeration}',
  name: RouteNames.adminModeration,
  builder: (context, state) => const AdminModerationPage(),
),
```

### Route Names Additions

```dart
// Add to route_names.dart

// Instructor
static const String instructorVerification = '/become-instructor/verify';
static const String quizBuilder = 'quiz-builder';

// Company
static const String companyTraining = '/company-training';

// Certificates
static const String verifyCertificate = '/verify';

// Admin
static const String adminVerifications = 'verifications';
static const String adminModeration = 'moderation';
```

---

## 6. FLUTTER FEATURE IMPLEMENTATION BREAKDOWN

### New Files to Create

```
lib/
├── features/
│   ├── verification/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── verification_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── instructor_verification_model.dart
│   │   │   └── repositories/
│   │   │       └── verification_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── instructor_verification_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── verification_repository.dart
│   │   │   └── usecases/
│   │   │       ├── submit_verification.dart
│   │   │       ├── get_verification_status.dart
│   │   │       └── resubmit_verification.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── verification_bloc.dart
│   │       │   ├── verification_event.dart
│   │       │   └── verification_state.dart
│   │       ├── pages/
│   │       │   └── instructor_verification_page.dart
│   │       └── widgets/
│   │           ├── document_upload_card.dart
│   │           └── verification_status_card.dart
│   │
│   ├── courses/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── quiz_builder_bloc.dart
│   │       │   ├── quiz_builder_event.dart
│   │       │   └── quiz_builder_state.dart
│   │       ├── pages/
│   │       │   ├── quiz_builder_page.dart
│   │       │   ├── question_editor_page.dart
│   │       │   └── company_training_dashboard_page.dart
│   │       └── widgets/
│   │           ├── youtube_player_widget.dart
│   │           ├── lesson_lock_indicator.dart
│   │           └── question_form_widget.dart
│   │
│   ├── certificates/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── certificate_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── certificate_model.dart
│   │   │   └── repositories/
│   │   │       └── certificate_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── certificate_entity.dart
│   │   │   ├── repositories/
│   │   │   │   └── certificate_repository.dart
│   │   │   └── usecases/
│   │   │       ├── generate_certificate.dart
│   │   │       ├── verify_certificate.dart
│   │   │       └── revoke_certificate.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── certificate_bloc.dart
│   │       │   ├── certificate_event.dart
│   │       │   └── certificate_state.dart
│   │       ├── pages/
│   │       │   └── certificate_verification_page.dart
│   │       └── widgets/
│   │           └── certificate_card.dart
│   │
│   ├── admin/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── admin_verification_bloc.dart
│   │       │   └── admin_moderation_bloc.dart
│   │       └── pages/
│   │           ├── admin_verification_review_page.dart
│   │           └── admin_moderation_page.dart
│   │
│   └── moderation/
│       ├── data/
│       │   └── repositories/
│       │       └── moderation_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── content_report_entity.dart
│       │   └── repositories/
│       │       └── moderation_repository.dart
│       └── presentation/
│           ├── bloc/
│           │   ├── report_bloc.dart
│           │   ├── report_event.dart
│           │   └── report_state.dart
│           └── widgets/
│               └── report_dialog.dart
│
├── core/
│   └── utils/
│       ├── youtube_utils.dart
│       └── certificate_utils.dart
│
└── supabase/
    └── functions/
        ├── generate-certificate/
        │   └── index.ts
        └── verify-certificate/
            └── index.ts
```

### Files to Modify

```
lib/config/routes/
├── app_router.dart          # Add new routes, verification gates
└── route_names.dart         # Add new route names

lib/core/auth/
├── route_guard.dart         # Add verification gate logic
├── permissions.dart         # Add new permissions
└── user_role.dart           # Update role capabilities

lib/features/courses/
├── presentation/
│   ├── pages/
│   │   ├── lesson_page.dart           # Add YouTube player, quiz gate
│   │   ├── course_details_page.dart   # Add progress lock indicators
│   │   └── instructor_dashboard_page.dart  # Add quiz builder link
│   └── bloc/
│       ├── student_bloc.dart          # Connect to real quiz API
│       └── instructor_bloc.dart       # Add quiz management
├── data/
│   └── repositories/
│       └── course_repository_impl.dart  # Implement quiz methods
└── domain/
    └── repositories/
        └── course_repository.dart       # Add quiz method signatures

lib/features/companies/
├── presentation/
│   └── pages/
│       └── company_verification_page.dart  # Connect to real upload
└── data/
    └── repositories/
        └── company_repository_impl.dart    # Add document upload

lib/features/profile/
└── presentation/
    └── pages/
        └── settings_page.dart           # Add notification preferences

pubspec.yaml                             # Add youtube_player_flutter, pdf packages
```

---

## 7. PHASED IMPLEMENTATION PLAN

### Phase 0: Capability Matrix and Guard Cleanup
**Duration: Foundation**

**DB Migrations:**
- None (cleanup only)

**Flutter Modules:**
- `lib/core/auth/route_guard.dart` - Refactor
- `lib/core/auth/permissions.dart` - Update
- `lib/core/auth/user_role.dart` - Update

**BLoC/Repositories:**
- None

**Tasks:**
1. Implement visitor read-only enforcement at API level
2. Block all write operations for visitors in route guards
3. Add capability matrix validation function
4. Update UserRole enum with complete permission mapping
5. Add integration tests for role-based access

**Acceptance Criteria:**
- [ ] Visitor cannot like, comment, apply, or enroll via UI
- [ ] Visitor cannot access protected routes (redirects to login)
- [ ] API returns 403 for visitor write attempts
- [ ] All roles have correctly mapped permissions
- [ ] Unit tests pass for permission checks

---

### Phase 1: Supabase Schema and Document Storage
**Duration: Database Foundation**

**DB Migrations:**
- `003_instructor_verification.sql`
- `004_quiz_system.sql`
- `005_certificate_system.sql`
- `006_course_ownership_progress.sql`
- `007_moderation_audit.sql`
- `008_search_indexes.sql`

**Flutter Modules:**
- None (backend only)

**BLoC/Repositories:**
- None

**Tasks:**
1. Run all migrations on Supabase
2. Configure storage buckets for documents
3. Set up storage policies for secure access
4. Apply all RLS policies
5. Create database functions and triggers
6. Test RLS policies with different roles
7. Seed test data for verification

**Acceptance Criteria:**
- [ ] All tables created successfully
- [ ] RLS policies block unauthorized access
- [ ] Storage buckets accept document uploads
- [ ] Triggers update search vectors
- [ ] Certificate serial generation works
- [ ] Quiz question count updates automatically

---

### Phase 2: Instructor/Company Verification Flows
**Duration: Verification System**

**DB Migrations:**
- None (use Phase 1)

**Flutter Modules:**
- `lib/features/verification/` - Full feature
- `lib/features/companies/presentation/pages/company_verification_page.dart` - Update

**BLoC/Repositories:**
- `VerificationBloc`
- `VerificationRepository`

**Tasks:**
1. Create instructor verification entity and model
2. Implement verification repository with Supabase
3. Create VerificationBloc with events:
   - LoadVerificationStatus
   - SubmitVerification
   - UploadDocument
   - ResubmitVerification
4. Build instructor verification page with:
   - Document upload cards
   - Status display
   - Resubmission flow
5. Update company verification page:
   - Connect to real file upload
   - Show actual status from DB
6. Add verification gate to instructor routes
7. Add verification gate to company training routes

**Acceptance Criteria:**
- [ ] User can upload ID and qualification documents
- [ ] Documents stored in Supabase storage
- [ ] Verification status persists in database
- [ ] Rejected users can resubmit
- [ ] Unverified instructors cannot access instructor dashboard
- [ ] Unverified companies cannot access training dashboard
- [ ] Status shows correctly on dashboard

---

### Phase 3: Progress Lock, Quizzes, Final Quiz
**Duration: Course Progression**

**DB Migrations:**
- None (use Phase 1)

**Flutter Modules:**
- `lib/features/courses/presentation/pages/quiz_builder_page.dart`
- `lib/features/courses/presentation/pages/question_editor_page.dart`
- `lib/features/courses/presentation/widgets/youtube_player_widget.dart`
- `lib/features/courses/presentation/widgets/lesson_lock_indicator.dart`
- `lib/features/courses/presentation/pages/lesson_page.dart` - Update

**BLoC/Repositories:**
- `QuizBuilderBloc`
- `ProgressBloc` (or extend StudentBloc)
- Update `CourseRepository` quiz methods

**Tasks:**
1. Add youtube_player_flutter package
2. Create YouTube URL validator utility
3. Implement YouTube player widget with:
   - URL parsing
   - Fullscreen support
   - Progress tracking
4. Implement quiz builder page:
   - Create/edit quizzes
   - Add questions (4 types)
   - Set correct answers
   - Configure settings (time, attempts, passing score)
5. Implement quiz API integration:
   - Start attempt
   - Submit answers
   - Calculate score
   - Record attempt
6. Implement lesson locking:
   - Check previous lesson quiz status
   - Show lock indicator
   - Block access until quiz passed
7. Implement final quiz composition:
   - Pull from question bank
   - Random selection
   - Unique per attempt

**Acceptance Criteria:**
- [ ] YouTube videos play in lesson page
- [ ] Video progress tracked in database
- [ ] Instructor can create quizzes with all question types
- [ ] Students can take quizzes with timer
- [ ] Quiz attempts logged with scores
- [ ] Locked lessons show lock indicator
- [ ] Cannot access locked lesson (API enforced)
- [ ] Final quiz pulls random questions from bank
- [ ] Multiple attempts tracked correctly

---

### Phase 4: Certificates and Public Verification
**Duration: Certification System**

**DB Migrations:**
- None (use Phase 1)

**Flutter Modules:**
- `lib/features/certificates/` - Full feature
- `lib/features/courses/presentation/pages/certificate_page.dart` - Update
- `supabase/functions/generate-certificate/`
- `supabase/functions/verify-certificate/`

**BLoC/Repositories:**
- `CertificateBloc`
- `CertificateRepository`

**Tasks:**
1. Create certificate entity and model
2. Implement certificate repository
3. Create Supabase Edge Function for PDF generation:
   - Accept enrollment data
   - Generate PDF with template
   - Add QR code with verification URL
   - Upload to storage
   - Return URL
4. Create certificate verification page:
   - Accept token from URL
   - Display certificate details
   - Show validity status
5. Implement automatic certificate issuance:
   - Trigger on course completion + final quiz pass
   - Generate serial number
   - Create certificate record
   - Call PDF generation function
6. Add certificate download in Flutter:
   - Fetch PDF URL
   - Download/share
7. Implement certificate revocation (admin)

**Acceptance Criteria:**
- [ ] Certificate auto-issued on completion + quiz pass
- [ ] PDF generated with correct data
- [ ] QR code links to verification page
- [ ] Serial number unique and formatted correctly
- [ ] Public can verify certificate via URL
- [ ] Revoked certificates show as invalid
- [ ] Certificate download works
- [ ] LinkedIn share works

---

### Phase 5: Admin Tools, Moderation, Audit
**Duration: Administration**

**DB Migrations:**
- None (use Phase 1)

**Flutter Modules:**
- `lib/features/admin/presentation/pages/admin_verification_review_page.dart`
- `lib/features/admin/presentation/pages/admin_moderation_page.dart`
- `lib/features/admin/presentation/bloc/admin_verification_bloc.dart`
- `lib/features/admin/presentation/bloc/admin_moderation_bloc.dart`
- `lib/features/moderation/` - Full feature

**BLoC/Repositories:**
- `AdminVerificationBloc`
- `AdminModerationBloc`
- `ReportBloc`
- `ModerationRepository`

**Tasks:**
1. Create verification review page:
   - List pending verifications
   - View documents
   - Approve/reject with notes
   - History view
2. Create moderation queue page:
   - List reported content
   - View content details
   - Take action (remove, warn, dismiss)
   - Resolution tracking
3. Implement report content feature:
   - Report button on posts, comments, etc.
   - Reason selection dialog
   - Submit to database
4. Implement user warnings/bans:
   - Issue warning
   - Temporary ban
   - Permanent ban
   - Ban check on login
5. Create audit log viewer:
   - Filter by action type
   - Filter by user
   - Date range
   - Export capability
6. Implement audit logging:
   - Log sensitive operations
   - Include old/new values
   - Track actor and IP

**Acceptance Criteria:**
- [ ] Admin can view pending instructor verifications
- [ ] Admin can approve/reject with reason
- [ ] Verification history recorded
- [ ] Users can report content
- [ ] Admin sees moderation queue
- [ ] Admin can take action on reports
- [ ] Banned users cannot login
- [ ] Audit logs capture sensitive operations
- [ ] Admin can search/filter audit logs

---

### Phase 6: Search Implementation
**Duration: Discovery**

**DB Migrations:**
- None (use Phase 1, triggers already created)

**Flutter Modules:**
- `lib/features/search/presentation/pages/global_search_page.dart` - Update
- `lib/features/search/data/repositories/search_repository_impl.dart`

**BLoC/Repositories:**
- Update `SearchBloc`
- `SearchRepository`

**Tasks:**
1. Update existing search vectors in database
2. Implement search repository with full-text search
3. Update search page to use new backend
4. Add search suggestions/autocomplete
5. Implement recent searches history
6. Add search analytics tracking
7. Optimize search performance with indexes

**Acceptance Criteria:**
- [ ] Search returns relevant results across all types
- [ ] Arabic and English search works
- [ ] Results ranked by relevance
- [ ] Recent searches saved
- [ ] Autocomplete suggestions appear
- [ ] Search performance under 500ms

---

### Phase 7: Production Readiness
**Duration: Launch Preparation**

**DB Migrations:**
- Performance indexes if needed

**Flutter Modules:**
- Error boundaries
- Analytics integration
- Crash reporting

**BLoC/Repositories:**
- None (testing and optimization)

**Tasks:**
1. Implement error boundary widgets
2. Add Sentry/Crashlytics integration
3. Add analytics event tracking
4. Implement rate limiting middleware
5. Add input validation throughout
6. Set up CI/CD pipeline:
   - Lint checks
   - Unit tests
   - Widget tests
   - Integration tests
7. Create deployment scripts
8. Set up monitoring dashboards
9. Performance testing and optimization
10. Security audit
11. Documentation

**Acceptance Criteria:**
- [ ] Crashes reported to Sentry
- [ ] Analytics events tracked
- [ ] Rate limiting prevents abuse
- [ ] All inputs validated
- [ ] CI/CD pipeline runs on PR
- [ ] Test coverage above 70%
- [ ] No critical security vulnerabilities
- [ ] Performance meets targets (TTI < 3s)
- [ ] Documentation complete

---

## Summary

This implementation plan provides a complete roadmap for transforming TAMAD HUB from a partially-implemented prototype to a production-ready platform. The phased approach ensures each component is properly built and tested before moving to dependent features.

**Total New Tables:** 15
**Total New Files:** ~50
**Total Modified Files:** ~25
**Estimated Migrations:** 6

Key dependencies between phases:
- Phase 1 (Schema) blocks all subsequent phases
- Phase 2 (Verification) blocks Phase 3-4 instructor features
- Phase 3 (Quizzes) blocks Phase 4 (Certificates)
- Phases 5-7 can partially run in parallel
