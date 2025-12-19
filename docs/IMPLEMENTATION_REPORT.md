# TAMAD HUB - Implementation Report

## Task 1: Missing Items Checklist

### A) Visitor Enforcement (UI + Routing + Backend)

- [x] Visitor role defined in UserRole enum
- [x] Visitor-accessible routes defined in RouteGuards
- [ ] Reusable LoginRequiredPrompt widget for restricted actions
- [ ] Visitor action interceptor for like/comment/share/save/apply/enroll/chat/follow
- [ ] Backend RLS policies enforcing read-only for visitors
- [ ] Hide action buttons (like, comment, share) for visitors in UI
- [ ] Visitor mode persistence across sessions

### B) Instructor Flows (User + Company) and Dashboard Separation

- [x] UserInstructor and CompanyInstructor roles defined
- [x] Instructor verification status enum
- [ ] UserInstructorDashboardPage (separate from company)
- [ ] CompanyTrainingDashboardPage (inside company context)
- [ ] Course issuer type display (User vs Company badge)
- [ ] Issuer profile link on course cards and details
- [ ] Instructor application workflow completion
- [ ] Company instructor assignment workflow

### C) Verification Workflows and Document Management

- [x] VerificationStatus enum defined
- [x] VerificationGate widget implemented
- [ ] VerificationDocumentsPage (upload, replace, expiry, history)
- [ ] VerificationRequirementsPage (checklist and rules)
- [ ] Resubmission flow UI (when rejected)
- [ ] Document expiry tracking and notifications
- [ ] Admin verification queues (instructor + company)
- [ ] Rejection reason handling and display

### D) Courses Publishing Lifecycle (Draft/Publish/Archive) + Preview

- [ ] Course status enum (DRAFT, PUBLISHED, ARCHIVED)
- [ ] CoursePublishPage (status transitions)
- [ ] CoursePreviewPage (preview as learner)
- [ ] Draft save and auto-save functionality
- [ ] Publish validation (required lessons, quiz, etc.)
- [ ] Archive workflow with student notification
- [ ] Course status filtering in listings

### E) Quizzes Authoring Tools + Question Bank + Attempt History + Lock Screens

- [x] Quiz entity defined
- [x] Quiz BLoC events/states defined
- [ ] QuizBuilderPage (create quiz metadata + pass score + randomization)
- [ ] QuestionBankPage (CRUD questions/options, link to lesson/final)
- [ ] QuizAttemptsPage (learner view: attempts history, best score)
- [ ] LockedLessonPage (if not passed quiz)
- [ ] FinalQuizGatePage (before certificate)
- [ ] Question types: MCQ, True/False, Multiple Select
- [ ] Randomization settings per quiz
- [ ] Time limits per quiz
- [ ] Attempt limit configuration

### F) Certificates Ecosystem (PDF Generation + Public Verification + Revocation)

- [x] Certificate entity with serial number
- [x] CertificateSerialGenerator implemented
- [ ] CertificateVerifyPublicPage route: /certificates/verify/:code
- [ ] CertificateRevokePage (issuer/admin)
- [ ] PDF generation (Edge Function or client-side)
- [ ] QR code generation for verification
- [ ] Certificate template customization
- [ ] Revocation workflow with reason
- [ ] Public verification API endpoint

### G) Jobs Pipeline Enhancements (Statuses, Notes, Duplicate Application Rules)

- [ ] ApplicationPipelinePage (company side status board + notes)
- [ ] ApplicantReviewPage (resume, answers, actions)
- [ ] Application status workflow (new, reviewing, shortlisted, interview, offered, rejected, withdrawn)
- [ ] Internal notes per application
- [ ] Duplicate application prevention
- [ ] Application reapply rules (after rejection timeout)
- [ ] Bulk actions for applications
- [ ] Application timeline/history

### H) Moderation and Safety (Reports Queue, Block/Mute, Admin Actions)

- [x] Admin entity with ContentReport class
- [ ] AdminReportsPage (posts/comments/users/companies)
- [ ] AdminAuditLogsPage (filterable audit trail)
- [ ] ReportDialog/ReportPage (reason selection + submit)
- [ ] BlockedUsersPage
- [ ] PrivacySettingsPage
- [ ] Mute functionality
- [ ] Report resolution workflow
- [ ] Automatic content hiding on report threshold

### I) Search Infrastructure (FTS/Trigram Indexes, Filters, Pagination)

- [x] SearchBloc implemented
- [x] Search entities defined
- [ ] Full-text search indexes on jobs, courses, users, companies
- [ ] Trigram indexes for fuzzy matching
- [ ] Advanced filters UI
- [ ] Infinite scroll pagination
- [ ] Search result caching
- [ ] Recent searches persistence
- [ ] Popular searches tracking

### J) Production Readiness (Audit Logs, Error/Empty States, CI/Testing Hooks)

- [ ] UnauthorizedPage (403)
- [ ] NotFoundPage (404)
- [ ] NetworkErrorPage
- [ ] Empty state components for all lists
- [ ] Error boundary wrapper
- [ ] Audit log table and queries
- [ ] CI/CD pipeline configuration
- [ ] Unit test scaffolding
- [ ] Integration test setup
- [ ] Error tracking integration (Sentry)

---

## Task 2: New Pages and Routes

### Admin Verification Queues

| Page | File Path | BLoC |
|------|-----------|------|
| AdminInstructorVerificationsPage | `lib/features/admin/presentation/pages/admin_instructor_verifications_page.dart` | AdminBloc |
| AdminCompanyVerificationsPage | `lib/features/admin/presentation/pages/admin_company_verifications_page.dart` | AdminBloc |

### Moderation Queues

| Page | File Path | BLoC |
|------|-----------|------|
| AdminReportsPage | `lib/features/admin/presentation/pages/admin_reports_page.dart` | AdminBloc |
| AdminAuditLogsPage | `lib/features/admin/presentation/pages/admin_audit_logs_page.dart` | AdminBloc |

### Instructor Tooling Separation

| Page | File Path | BLoC |
|------|-----------|------|
| UserInstructorDashboardPage | `lib/features/courses/presentation/pages/user_instructor_dashboard_page.dart` | InstructorBloc |
| CompanyTrainingDashboardPage | `lib/features/companies/presentation/pages/company_training_dashboard_page.dart` | CompanyBloc, InstructorBloc |

### Verification Document Management

| Page | File Path | BLoC |
|------|-----------|------|
| VerificationDocumentsPage | `lib/features/verification/presentation/pages/verification_documents_page.dart` | VerificationBloc |
| VerificationRequirementsPage | `lib/features/verification/presentation/pages/verification_requirements_page.dart` | VerificationBloc |

### Courses Publishing Workflow

| Page | File Path | BLoC |
|------|-----------|------|
| CoursePublishPage | `lib/features/courses/presentation/pages/course_publish_page.dart` | InstructorBloc |
| CoursePreviewPage | `lib/features/courses/presentation/pages/course_preview_page.dart` | CourseBloc |

### Quizzes Authoring

| Page | File Path | BLoC |
|------|-----------|------|
| QuizBuilderPage | `lib/features/courses/presentation/pages/quiz_builder_page.dart` | QuizBuilderBloc |
| QuestionBankPage | `lib/features/courses/presentation/pages/question_bank_page.dart` | QuestionBankBloc |
| QuizAttemptsPage | `lib/features/courses/presentation/pages/quiz_attempts_page.dart` | StudentBloc |
| LockedLessonPage | `lib/features/courses/presentation/pages/locked_lesson_page.dart` | StudentBloc |
| FinalQuizGatePage | `lib/features/courses/presentation/pages/final_quiz_gate_page.dart` | StudentBloc |

### Certificates

| Page | File Path | BLoC |
|------|-----------|------|
| CertificateVerifyPublicPage | `lib/features/courses/presentation/pages/certificate_verify_public_page.dart` | CertificateBloc |
| CertificateRevokePage | `lib/features/courses/presentation/pages/certificate_revoke_page.dart` | CertificateBloc |

### Jobs Pipeline

| Page | File Path | BLoC |
|------|-----------|------|
| ApplicationPipelinePage | `lib/features/jobs/presentation/pages/application_pipeline_page.dart` | JobPipelineBloc |
| ApplicantReviewPage | `lib/features/jobs/presentation/pages/applicant_review_page.dart` | JobPipelineBloc |

### Social Safety

| Page | File Path | BLoC |
|------|-----------|------|
| ReportPage | `lib/features/moderation/presentation/pages/report_page.dart` | ModerationBloc |
| BlockedUsersPage | `lib/features/profile/presentation/pages/blocked_users_page.dart` | PrivacyBloc |
| PrivacySettingsPage | `lib/features/profile/presentation/pages/privacy_settings_page.dart` | PrivacyBloc |

### System Reliability

| Page | File Path | BLoC |
|------|-----------|------|
| UnauthorizedPage | `lib/core/presentation/pages/unauthorized_page.dart` | None |
| NotFoundPage | `lib/core/presentation/pages/not_found_page.dart` | None |
| NetworkErrorPage | `lib/core/presentation/pages/network_error_page.dart` | None |

### New Routes to Add to route_names.dart

```dart
// Verification
static const String verificationDocuments = '/verification/documents';
static const String verificationRequirements = '/verification/requirements';

// Admin Verification Queues
static const String adminInstructorVerifications = '/admin/verifications/instructors';
static const String adminCompanyVerifications = '/admin/verifications/companies';

// Course Publishing
static const String coursePublish = '/instructor/courses/:courseId/publish';
static const String coursePreview = '/courses/:courseId/preview';

// Quiz Authoring
static const String quizBuilder = '/instructor/courses/:courseId/quizzes/:quizId/build';
static const String questionBank = '/instructor/courses/:courseId/questions';
static const String quizAttempts = '/courses/:courseId/quiz/:quizId/attempts';
static const String lockedLesson = '/courses/:courseId/lessons/:lessonId/locked';
static const String finalQuizGate = '/courses/:courseId/final-quiz';

// Certificate
static const String certificateVerifyPublic = '/verify/:code';
static const String certificateRevoke = '/instructor/certificates/:certificateId/revoke';

// Jobs Pipeline
static const String applicationPipeline = '/companies/:companyId/jobs/:jobId/pipeline';
static const String applicantReview = '/companies/:companyId/jobs/:jobId/applications/:applicationId';

// Social Safety
static const String reportContent = '/report';
static const String blockedUsers = '/settings/blocked';
static const String privacySettings = '/settings/privacy';

// System
static const String unauthorized = '/403';
static const String notFound = '/404';
static const String networkError = '/error';
```

---

## Task 3: Supabase Schema Migrations

### Migration 001: Verification Tables

```sql
-- Migration: 001_verification_tables
-- Description: User instructor applications and company verification

-- Enum for verification status
CREATE TYPE verification_status AS ENUM (
  'not_submitted',
  'pending',
  'approved',
  'rejected',
  'suspended'
);

-- Enum for document type
CREATE TYPE verification_document_type AS ENUM (
  'identity_card',
  'passport',
  'degree_certificate',
  'professional_license',
  'commercial_registration',
  'tax_certificate',
  'company_logo',
  'authorization_letter',
  'other'
);

-- User Instructor Applications
CREATE TABLE user_instructor_applications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  status verification_status NOT NULL DEFAULT 'pending',
  bio TEXT,
  expertise_areas TEXT[],
  years_of_experience INTEGER,
  portfolio_url TEXT,
  linkedin_url TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewer_id UUID REFERENCES profiles(id),
  rejection_reason TEXT,
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id)
);

-- User Instructor Documents
CREATE TABLE user_instructor_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES user_instructor_applications(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  document_type verification_document_type NOT NULL,
  storage_path TEXT NOT NULL,
  original_filename TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  file_hash TEXT,
  version INTEGER NOT NULL DEFAULT 1,
  expiry_date DATE,
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  verified_by UUID REFERENCES profiles(id),
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Company Verification Requests
CREATE TABLE company_verification_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  submitted_by UUID NOT NULL REFERENCES profiles(id),
  status verification_status NOT NULL DEFAULT 'pending',
  company_type TEXT,
  employee_count_range TEXT,
  industry TEXT,
  website_url TEXT,
  submitted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewer_id UUID REFERENCES profiles(id),
  rejection_reason TEXT,
  admin_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(company_id)
);

-- Company Documents
CREATE TABLE company_documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES company_verification_requests(id) ON DELETE CASCADE,
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  document_type verification_document_type NOT NULL,
  storage_path TEXT NOT NULL,
  original_filename TEXT NOT NULL,
  file_size INTEGER,
  mime_type TEXT,
  file_hash TEXT,
  version INTEGER NOT NULL DEFAULT 1,
  expiry_date DATE,
  is_verified BOOLEAN DEFAULT FALSE,
  verified_at TIMESTAMPTZ,
  verified_by UUID REFERENCES profiles(id),
  uploaded_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_instructor_apps_user ON user_instructor_applications(user_id);
CREATE INDEX idx_instructor_apps_status ON user_instructor_applications(status);
CREATE INDEX idx_instructor_docs_app ON user_instructor_documents(application_id);
CREATE INDEX idx_company_verif_company ON company_verification_requests(company_id);
CREATE INDEX idx_company_verif_status ON company_verification_requests(status);
CREATE INDEX idx_company_docs_verif ON company_documents(verification_id);

-- Triggers for updated_at
CREATE TRIGGER update_instructor_apps_updated_at
  BEFORE UPDATE ON user_instructor_applications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_company_verif_updated_at
  BEFORE UPDATE ON company_verification_requests
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 002: Course Ownership and Lifecycle

```sql
-- Migration: 002_course_ownership_lifecycle
-- Description: Course instructor type, ownership, and lifecycle status

-- Enum for instructor type
CREATE TYPE instructor_type AS ENUM ('USER', 'COMPANY');

-- Enum for course status
CREATE TYPE course_status AS ENUM ('DRAFT', 'PENDING_REVIEW', 'PUBLISHED', 'ARCHIVED');

-- Alter courses table
ALTER TABLE courses
  ADD COLUMN IF NOT EXISTS instructor_type instructor_type NOT NULL DEFAULT 'USER',
  ADD COLUMN IF NOT EXISTS instructor_user_id UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS instructor_company_id UUID REFERENCES companies(id),
  ADD COLUMN IF NOT EXISTS status course_status NOT NULL DEFAULT 'DRAFT',
  ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS archived_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS archive_reason TEXT;

-- Add constraint for instructor ownership
ALTER TABLE courses ADD CONSTRAINT check_instructor_ownership CHECK (
  (instructor_type = 'USER' AND instructor_user_id IS NOT NULL AND instructor_company_id IS NULL) OR
  (instructor_type = 'COMPANY' AND instructor_company_id IS NOT NULL)
);

-- Course Sections (ordered)
CREATE TABLE IF NOT EXISTS course_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_published BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Alter course_lessons for YouTube-only
ALTER TABLE course_lessons
  ADD COLUMN IF NOT EXISTS section_id UUID REFERENCES course_sections(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS youtube_url TEXT,
  ADD COLUMN IF NOT EXISTS youtube_video_id TEXT,
  ADD COLUMN IF NOT EXISTS order_index INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS requires_quiz_pass BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS required_quiz_id UUID;

-- Add YouTube URL validation function
CREATE OR REPLACE FUNCTION validate_youtube_url(url TEXT) RETURNS BOOLEAN AS $$
BEGIN
  IF url IS NULL THEN
    RETURN TRUE;
  END IF;
  RETURN url ~ '^(https?://)?(www\.)?(youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)[a-zA-Z0-9_-]{11}';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Add constraint for YouTube URL
ALTER TABLE course_lessons ADD CONSTRAINT check_youtube_url
  CHECK (youtube_url IS NULL OR validate_youtube_url(youtube_url));

-- Course Enrollments enhancements
ALTER TABLE course_enrollments
  ADD COLUMN IF NOT EXISTS current_section_id UUID REFERENCES course_sections(id),
  ADD COLUMN IF NOT EXISTS current_lesson_id UUID REFERENCES course_lessons(id),
  ADD COLUMN IF NOT EXISTS is_locked BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS lock_reason TEXT;

-- Course Progress tracking
CREATE TABLE IF NOT EXISTS course_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_id UUID NOT NULL REFERENCES course_enrollments(id) ON DELETE CASCADE,
  lesson_id UUID NOT NULL REFERENCES course_lessons(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  watch_time_seconds INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(enrollment_id, lesson_id)
);

-- Indexes
CREATE INDEX idx_courses_instructor_user ON courses(instructor_user_id) WHERE instructor_type = 'USER';
CREATE INDEX idx_courses_instructor_company ON courses(instructor_company_id) WHERE instructor_type = 'COMPANY';
CREATE INDEX idx_courses_status ON courses(status);
CREATE INDEX idx_sections_course ON course_sections(course_id);
CREATE INDEX idx_lessons_section ON course_lessons(section_id);
CREATE INDEX idx_progress_enrollment ON course_progress(enrollment_id);
CREATE INDEX idx_progress_user ON course_progress(user_id);
```

### Migration 003: Quizzes System

```sql
-- Migration: 003_quizzes_system
-- Description: Complete quiz system with attempts and locking

-- Enum for quiz type
CREATE TYPE quiz_type AS ENUM ('LESSON', 'SECTION', 'FINAL');

-- Enum for question type
CREATE TYPE question_type AS ENUM ('SINGLE_CHOICE', 'MULTIPLE_CHOICE', 'TRUE_FALSE');

-- Quizzes table
CREATE TABLE quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  lesson_id UUID REFERENCES course_lessons(id) ON DELETE SET NULL,
  section_id UUID REFERENCES course_sections(id) ON DELETE SET NULL,
  quiz_type quiz_type NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  pass_score INTEGER NOT NULL DEFAULT 70,
  time_limit_minutes INTEGER,
  max_attempts INTEGER,
  shuffle_questions BOOLEAN DEFAULT FALSE,
  shuffle_options BOOLEAN DEFAULT FALSE,
  show_correct_answers BOOLEAN DEFAULT TRUE,
  is_required BOOLEAN DEFAULT TRUE,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz Questions
CREATE TABLE quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  question_type question_type NOT NULL DEFAULT 'SINGLE_CHOICE',
  question_text TEXT NOT NULL,
  question_image_url TEXT,
  explanation TEXT,
  points INTEGER NOT NULL DEFAULT 1,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz Options (answers)
CREATE TABLE quiz_options (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  option_image_url TEXT,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  order_index INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz Attempts
CREATE TABLE quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  enrollment_id UUID REFERENCES course_enrollments(id) ON DELETE SET NULL,
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at TIMESTAMPTZ,
  time_spent_seconds INTEGER,
  score INTEGER,
  total_points INTEGER,
  percentage DECIMAL(5,2),
  passed BOOLEAN,
  attempt_number INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz Attempt Answers
CREATE TABLE quiz_attempt_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  selected_option_ids UUID[] NOT NULL DEFAULT '{}',
  is_correct BOOLEAN,
  points_earned INTEGER DEFAULT 0,
  answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Quiz Pass State (tracks best score per quiz per user)
CREATE TABLE quiz_pass_state (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  best_score INTEGER NOT NULL,
  best_percentage DECIMAL(5,2) NOT NULL,
  passed_at TIMESTAMPTZ,
  attempt_count INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(quiz_id, user_id)
);

-- Link lessons to required quiz
ALTER TABLE course_lessons
  ADD CONSTRAINT fk_required_quiz
  FOREIGN KEY (required_quiz_id) REFERENCES quizzes(id) ON DELETE SET NULL;

-- Indexes
CREATE INDEX idx_quizzes_course ON quizzes(course_id);
CREATE INDEX idx_quizzes_lesson ON quizzes(lesson_id);
CREATE INDEX idx_quizzes_type ON quizzes(quiz_type);
CREATE INDEX idx_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX idx_options_question ON quiz_options(question_id);
CREATE INDEX idx_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX idx_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_attempt_answers_attempt ON quiz_attempt_answers(attempt_id);
CREATE INDEX idx_pass_state_quiz_user ON quiz_pass_state(quiz_id, user_id);

-- Triggers
CREATE TRIGGER update_quizzes_updated_at
  BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_quiz_pass_state_updated_at
  BEFORE UPDATE ON quiz_pass_state
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 004: Certificates System

```sql
-- Migration: 004_certificates_system
-- Description: Certificate issuance, verification, and revocation

-- Enum for certificate status
CREATE TYPE certificate_status AS ENUM ('PENDING', 'ISSUED', 'REVOKED');

-- Certificates table
CREATE TABLE certificates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  enrollment_id UUID NOT NULL REFERENCES course_enrollments(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Issuer information (snapshot at time of issue)
  issued_by_type instructor_type NOT NULL,
  issued_by_user_id UUID REFERENCES profiles(id),
  issued_by_company_id UUID REFERENCES companies(id),
  issuer_name TEXT NOT NULL,

  -- Certificate details
  serial_number TEXT NOT NULL UNIQUE,
  verify_code TEXT NOT NULL UNIQUE,
  qr_code_data TEXT,
  pdf_storage_path TEXT,

  -- Status
  status certificate_status NOT NULL DEFAULT 'PENDING',
  issued_at TIMESTAMPTZ,

  -- Revocation
  revoked_at TIMESTAMPTZ,
  revoked_by UUID REFERENCES profiles(id),
  revoked_reason TEXT,

  -- Metadata
  course_title TEXT NOT NULL,
  course_description TEXT,
  completion_date DATE NOT NULL,
  final_quiz_score INTEGER,
  total_lessons_completed INTEGER,
  total_watch_time_hours DECIMAL(6,2),

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

  UNIQUE(enrollment_id)
);

-- Certificate Verification Log (public access tracking)
CREATE TABLE certificate_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id UUID NOT NULL REFERENCES certificates(id) ON DELETE CASCADE,
  verify_code TEXT NOT NULL,
  verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT,
  referrer TEXT,
  is_valid BOOLEAN NOT NULL,
  failure_reason TEXT
);

-- Function to generate serial number
CREATE OR REPLACE FUNCTION generate_certificate_serial() RETURNS TEXT AS $$
DECLARE
  year_part TEXT;
  random_part TEXT;
  serial TEXT;
BEGIN
  year_part := EXTRACT(YEAR FROM NOW())::TEXT;
  random_part := upper(substr(md5(random()::text), 1, 6));
  serial := 'TAMAD-' || year_part || '-' || random_part;
  RETURN serial;
END;
$$ LANGUAGE plpgsql;

-- Function to generate verify code
CREATE OR REPLACE FUNCTION generate_verify_code() RETURNS TEXT AS $$
BEGIN
  RETURN upper(substr(md5(random()::text || NOW()::text), 1, 12));
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-generate codes on insert
CREATE OR REPLACE FUNCTION certificates_before_insert() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.serial_number IS NULL OR NEW.serial_number = '' THEN
    NEW.serial_number := generate_certificate_serial();
  END IF;
  IF NEW.verify_code IS NULL OR NEW.verify_code = '' THEN
    NEW.verify_code := generate_verify_code();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_certificates_before_insert
  BEFORE INSERT ON certificates
  FOR EACH ROW EXECUTE FUNCTION certificates_before_insert();

-- Indexes
CREATE INDEX idx_certificates_user ON certificates(user_id);
CREATE INDEX idx_certificates_course ON certificates(course_id);
CREATE INDEX idx_certificates_serial ON certificates(serial_number);
CREATE INDEX idx_certificates_verify_code ON certificates(verify_code);
CREATE INDEX idx_certificates_status ON certificates(status);
CREATE INDEX idx_cert_verifications_cert ON certificate_verifications(certificate_id);
CREATE INDEX idx_cert_verifications_code ON certificate_verifications(verify_code);

-- Trigger
CREATE TRIGGER update_certificates_updated_at
  BEFORE UPDATE ON certificates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 005: Moderation and Audit

```sql
-- Migration: 005_moderation_audit
-- Description: Reports, audit logs, and moderation tools

-- Enum for report target type
CREATE TYPE report_target_type AS ENUM (
  'POST',
  'COMMENT',
  'USER',
  'COMPANY',
  'COURSE',
  'JOB',
  'MESSAGE'
);

-- Enum for report status
CREATE TYPE report_status AS ENUM (
  'PENDING',
  'REVIEWING',
  'RESOLVED',
  'DISMISSED',
  'ESCALATED'
);

-- Enum for report reason
CREATE TYPE report_reason AS ENUM (
  'SPAM',
  'HARASSMENT',
  'INAPPROPRIATE_CONTENT',
  'MISINFORMATION',
  'COPYRIGHT',
  'FRAUD',
  'IMPERSONATION',
  'VIOLENCE',
  'HATE_SPEECH',
  'OTHER'
);

-- Reports table
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  target_type report_target_type NOT NULL,
  target_id UUID NOT NULL,
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason report_reason NOT NULL,
  description TEXT,
  evidence_urls TEXT[],

  -- Status
  status report_status NOT NULL DEFAULT 'PENDING',
  priority INTEGER DEFAULT 0,

  -- Resolution
  resolved_at TIMESTAMPTZ,
  resolved_by UUID REFERENCES profiles(id),
  resolution_notes TEXT,
  action_taken TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enum for audit action
CREATE TYPE audit_action AS ENUM (
  -- Auth
  'LOGIN',
  'LOGOUT',
  'PASSWORD_CHANGE',
  'PASSWORD_RESET',

  -- Content
  'CREATE',
  'UPDATE',
  'DELETE',
  'PUBLISH',
  'UNPUBLISH',
  'ARCHIVE',

  -- Moderation
  'APPROVE',
  'REJECT',
  'SUSPEND',
  'UNSUSPEND',
  'BAN',
  'UNBAN',
  'REPORT_RESOLVE',
  'REPORT_DISMISS',

  -- Verification
  'VERIFICATION_SUBMIT',
  'VERIFICATION_APPROVE',
  'VERIFICATION_REJECT',

  -- Certificate
  'CERTIFICATE_ISSUE',
  'CERTIFICATE_REVOKE',

  -- Admin
  'SETTINGS_CHANGE',
  'ROLE_CHANGE',
  'PERMISSION_CHANGE'
);

-- Audit Logs table
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Actor
  actor_type TEXT NOT NULL, -- 'user', 'system', 'admin'
  actor_id UUID REFERENCES profiles(id),
  actor_email TEXT,
  actor_role TEXT,

  -- Action
  action audit_action NOT NULL,

  -- Target
  entity_type TEXT NOT NULL,
  entity_id UUID,
  entity_name TEXT,

  -- Details
  metadata JSONB DEFAULT '{}',
  old_values JSONB,
  new_values JSONB,

  -- Context
  ip_address INET,
  user_agent TEXT,
  request_id TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User Blocks
CREATE TABLE user_blocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  blocker_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(blocker_id, blocked_id),
  CHECK(blocker_id != blocked_id)
);

-- User Mutes
CREATE TABLE user_mutes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  muter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  muted_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(muter_id, muted_id),
  CHECK(muter_id != muted_id)
);

-- Indexes
CREATE INDEX idx_reports_target ON reports(target_type, target_id);
CREATE INDEX idx_reports_reporter ON reports(reporter_id);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created ON reports(created_at DESC);

CREATE INDEX idx_audit_actor ON audit_logs(actor_id);
CREATE INDEX idx_audit_action ON audit_logs(action);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at DESC);

CREATE INDEX idx_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX idx_blocks_blocked ON user_blocks(blocked_id);
CREATE INDEX idx_mutes_muter ON user_mutes(muter_id);

-- Trigger
CREATE TRIGGER update_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 006: Jobs Pipeline Enhancement

```sql
-- Migration: 006_jobs_pipeline
-- Description: Enhanced job applications with pipeline stages

-- Enum for application status
CREATE TYPE application_status AS ENUM (
  'NEW',
  'REVIEWING',
  'SHORTLISTED',
  'INTERVIEW_SCHEDULED',
  'INTERVIEWED',
  'OFFER_EXTENDED',
  'OFFER_ACCEPTED',
  'HIRED',
  'REJECTED',
  'WITHDRAWN'
);

-- Alter job_applications table
ALTER TABLE job_applications
  ADD COLUMN IF NOT EXISTS status application_status NOT NULL DEFAULT 'NEW',
  ADD COLUMN IF NOT EXISTS internal_notes TEXT,
  ADD COLUMN IF NOT EXISTS rejection_reason TEXT,
  ADD COLUMN IF NOT EXISTS interview_date TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS offer_details JSONB,
  ADD COLUMN IF NOT EXISTS rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  ADD COLUMN IF NOT EXISTS last_updated_by UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS status_changed_at TIMESTAMPTZ;

-- Add unique constraint to prevent duplicate applications
ALTER TABLE job_applications
  ADD CONSTRAINT unique_active_application UNIQUE (job_id, user_id);

-- Application Status History
CREATE TABLE application_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES job_applications(id) ON DELETE CASCADE,
  old_status application_status,
  new_status application_status NOT NULL,
  changed_by UUID REFERENCES profiles(id),
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Application Notes (separate from status changes)
CREATE TABLE application_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id UUID NOT NULL REFERENCES job_applications(id) ON DELETE CASCADE,
  author_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  note_text TEXT NOT NULL,
  is_internal BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Function to track status changes
CREATE OR REPLACE FUNCTION track_application_status_change() RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO application_status_history (
      application_id, old_status, new_status, changed_by
    ) VALUES (
      NEW.id, OLD.status, NEW.status, NEW.last_updated_by
    );
    NEW.status_changed_at := NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_track_application_status
  BEFORE UPDATE ON job_applications
  FOR EACH ROW EXECUTE FUNCTION track_application_status_change();

-- Indexes
CREATE INDEX idx_applications_status ON job_applications(status);
CREATE INDEX idx_applications_job_status ON job_applications(job_id, status);
CREATE INDEX idx_status_history_app ON application_status_history(application_id);
CREATE INDEX idx_app_notes_app ON application_notes(application_id);

-- Trigger
CREATE TRIGGER update_app_notes_updated_at
  BEFORE UPDATE ON application_notes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
```

### Migration 007: Search Indexes

```sql
-- Migration: 007_search_indexes
-- Description: Full-text search and trigram indexes

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Jobs full-text search
ALTER TABLE jobs ADD COLUMN IF NOT EXISTS search_vector tsvector;

CREATE OR REPLACE FUNCTION jobs_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('arabic', coalesce(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER jobs_search_update
  BEFORE INSERT OR UPDATE OF title, description ON jobs
  FOR EACH ROW EXECUTE FUNCTION jobs_search_vector_update();

CREATE INDEX idx_jobs_search ON jobs USING GIN(search_vector);
CREATE INDEX idx_jobs_title_trgm ON jobs USING GIN(title gin_trgm_ops);

-- Courses full-text search
ALTER TABLE courses ADD COLUMN IF NOT EXISTS search_vector tsvector;

CREATE OR REPLACE FUNCTION courses_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('arabic', coalesce(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER courses_search_update
  BEFORE INSERT OR UPDATE OF title, description ON courses
  FOR EACH ROW EXECUTE FUNCTION courses_search_vector_update();

CREATE INDEX idx_courses_search ON courses USING GIN(search_vector);
CREATE INDEX idx_courses_title_trgm ON courses USING GIN(title gin_trgm_ops);

-- Profiles full-text search
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS search_vector tsvector;

CREATE OR REPLACE FUNCTION profiles_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', coalesce(NEW.display_name, '')), 'A') ||
    setweight(to_tsvector('arabic', coalesce(NEW.headline, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.display_name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.headline, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_search_update
  BEFORE INSERT OR UPDATE OF display_name, headline ON profiles
  FOR EACH ROW EXECUTE FUNCTION profiles_search_vector_update();

CREATE INDEX idx_profiles_search ON profiles USING GIN(search_vector);
CREATE INDEX idx_profiles_name_trgm ON profiles USING GIN(display_name gin_trgm_ops);

-- Companies full-text search
ALTER TABLE companies ADD COLUMN IF NOT EXISTS search_vector tsvector;

CREATE OR REPLACE FUNCTION companies_search_vector_update() RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('arabic', coalesce(NEW.name, '')), 'A') ||
    setweight(to_tsvector('arabic', coalesce(NEW.description, '')), 'B') ||
    setweight(to_tsvector('english', coalesce(NEW.name, '')), 'A') ||
    setweight(to_tsvector('english', coalesce(NEW.description, '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER companies_search_update
  BEFORE INSERT OR UPDATE OF name, description ON companies
  FOR EACH ROW EXECUTE FUNCTION companies_search_vector_update();

CREATE INDEX idx_companies_search ON companies USING GIN(search_vector);
CREATE INDEX idx_companies_name_trgm ON companies USING GIN(name gin_trgm_ops);

-- Search function
CREATE OR REPLACE FUNCTION global_search(
  search_query TEXT,
  search_type TEXT DEFAULT 'all',
  result_limit INTEGER DEFAULT 20,
  result_offset INTEGER DEFAULT 0
) RETURNS TABLE (
  entity_type TEXT,
  entity_id UUID,
  title TEXT,
  subtitle TEXT,
  image_url TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  WITH search_results AS (
    -- Jobs
    SELECT
      'job'::TEXT as entity_type,
      j.id as entity_id,
      j.title,
      c.name as subtitle,
      c.logo_url as image_url,
      ts_rank(j.search_vector, plainto_tsquery('arabic', search_query)) as rank
    FROM jobs j
    LEFT JOIN companies c ON j.company_id = c.id
    WHERE (search_type = 'all' OR search_type = 'job')
      AND j.status = 'active'
      AND j.search_vector @@ plainto_tsquery('arabic', search_query)

    UNION ALL

    -- Courses
    SELECT
      'course'::TEXT,
      co.id,
      co.title,
      COALESCE(p.display_name, cm.name) as subtitle,
      co.thumbnail_url,
      ts_rank(co.search_vector, plainto_tsquery('arabic', search_query))
    FROM courses co
    LEFT JOIN profiles p ON co.instructor_user_id = p.id
    LEFT JOIN companies cm ON co.instructor_company_id = cm.id
    WHERE (search_type = 'all' OR search_type = 'course')
      AND co.status = 'PUBLISHED'
      AND co.search_vector @@ plainto_tsquery('arabic', search_query)

    UNION ALL

    -- Users
    SELECT
      'user'::TEXT,
      pr.id,
      pr.display_name,
      pr.headline,
      pr.avatar_url,
      ts_rank(pr.search_vector, plainto_tsquery('arabic', search_query))
    FROM profiles pr
    WHERE (search_type = 'all' OR search_type = 'user')
      AND pr.search_vector @@ plainto_tsquery('arabic', search_query)

    UNION ALL

    -- Companies
    SELECT
      'company'::TEXT,
      cp.id,
      cp.name,
      cp.industry,
      cp.logo_url,
      ts_rank(cp.search_vector, plainto_tsquery('arabic', search_query))
    FROM companies cp
    WHERE (search_type = 'all' OR search_type = 'company')
      AND cp.search_vector @@ plainto_tsquery('arabic', search_query)
  )
  SELECT * FROM search_results
  ORDER BY rank DESC
  LIMIT result_limit
  OFFSET result_offset;
END;
$$ LANGUAGE plpgsql;
```

---

## Task 4: RLS Policies

### Policy 1: Courses (Read-Only for Visitors, Full for Instructors)

```sql
-- Courses RLS Policies

-- Enable RLS
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view published courses
CREATE POLICY courses_select_published ON courses
  FOR SELECT
  USING (status = 'PUBLISHED');

-- Policy: Instructors can view their own courses (any status)
CREATE POLICY courses_select_own ON courses
  FOR SELECT
  USING (
    auth.uid() = instructor_user_id
    OR
    EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = courses.instructor_company_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin', 'instructor')
    )
  );

-- Policy: Admin can view all courses
CREATE POLICY courses_select_admin ON courses
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Verified user instructors can create USER courses
CREATE POLICY courses_insert_user_instructor ON courses
  FOR INSERT
  WITH CHECK (
    instructor_type = 'USER'
    AND instructor_user_id = auth.uid()
    AND EXISTS (
      SELECT 1 FROM user_instructor_applications
      WHERE user_id = auth.uid() AND status = 'approved'
    )
  );

-- Policy: Verified company instructors can create COMPANY courses
CREATE POLICY courses_insert_company_instructor ON courses
  FOR INSERT
  WITH CHECK (
    instructor_type = 'COMPANY'
    AND EXISTS (
      SELECT 1 FROM company_verification_requests cvr
      JOIN company_members cm ON cm.company_id = cvr.company_id
      WHERE cvr.company_id = courses.instructor_company_id
        AND cvr.status = 'approved'
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin', 'instructor')
    )
  );

-- Policy: Instructors can update their own courses
CREATE POLICY courses_update_own ON courses
  FOR UPDATE
  USING (
    auth.uid() = instructor_user_id
    OR
    EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = courses.instructor_company_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin', 'instructor')
    )
  )
  WITH CHECK (
    auth.uid() = instructor_user_id
    OR
    EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = courses.instructor_company_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin', 'instructor')
    )
  );

-- Policy: Admin can update any course
CREATE POLICY courses_update_admin ON courses
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Only admin can delete courses
CREATE POLICY courses_delete_admin ON courses
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Policy 2: Course Lessons

```sql
-- Course Lessons RLS Policies

ALTER TABLE course_lessons ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view lessons of published courses
CREATE POLICY lessons_select_published ON course_lessons
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = course_lessons.course_id
        AND courses.status = 'PUBLISHED'
    )
  );

-- Policy: Enrolled users can view lessons
CREATE POLICY lessons_select_enrolled ON course_lessons
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM course_enrollments ce
      WHERE ce.course_id = course_lessons.course_id
        AND ce.user_id = auth.uid()
    )
  );

-- Policy: Course instructors can manage lessons
CREATE POLICY lessons_all_instructor ON course_lessons
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = course_lessons.course_id
        AND (
          c.instructor_user_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM company_members cm
            WHERE cm.company_id = c.instructor_company_id
              AND cm.user_id = auth.uid()
              AND cm.role IN ('owner', 'admin', 'instructor')
          )
        )
    )
  );

-- Policy: Admin can manage all lessons
CREATE POLICY lessons_all_admin ON course_lessons
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Policy 3: Quizzes

```sql
-- Quizzes RLS Policies

ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;

-- Policy: Anyone can view quizzes of published courses
CREATE POLICY quizzes_select_published ON quizzes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM courses
      WHERE courses.id = quizzes.course_id
        AND courses.status = 'PUBLISHED'
    )
  );

-- Policy: Enrolled users can view quizzes
CREATE POLICY quizzes_select_enrolled ON quizzes
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM course_enrollments ce
      WHERE ce.course_id = quizzes.course_id
        AND ce.user_id = auth.uid()
    )
  );

-- Policy: Verified instructors can manage quizzes for their courses
CREATE POLICY quizzes_all_instructor ON quizzes
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM courses c
      WHERE c.id = quizzes.course_id
        AND (
          (c.instructor_type = 'USER'
           AND c.instructor_user_id = auth.uid()
           AND EXISTS (
             SELECT 1 FROM user_instructor_applications
             WHERE user_id = auth.uid() AND status = 'approved'
           ))
          OR
          (c.instructor_type = 'COMPANY'
           AND EXISTS (
             SELECT 1 FROM company_members cm
             JOIN company_verification_requests cvr ON cvr.company_id = cm.company_id
             WHERE cm.company_id = c.instructor_company_id
               AND cm.user_id = auth.uid()
               AND cm.role IN ('owner', 'admin', 'instructor')
               AND cvr.status = 'approved'
           ))
        )
    )
  );

-- Policy: Admin can manage all quizzes
CREATE POLICY quizzes_all_admin ON quizzes
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Policy 4: Certificates

```sql
-- Certificates RLS Policies

ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- Policy: Public verification (anyone can verify by code)
CREATE POLICY certificates_select_verify ON certificates
  FOR SELECT
  USING (
    status = 'ISSUED'
  );

-- Policy: Users can view their own certificates
CREATE POLICY certificates_select_own ON certificates
  FOR SELECT
  USING (user_id = auth.uid());

-- Policy: Issuers can view certificates they issued
CREATE POLICY certificates_select_issuer ON certificates
  FOR SELECT
  USING (
    issued_by_user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = certificates.issued_by_company_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin', 'instructor')
    )
  );

-- Policy: Verified instructors can issue certificates for their courses
CREATE POLICY certificates_insert_instructor ON certificates
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM courses c
      JOIN course_enrollments ce ON ce.course_id = c.id
      WHERE c.id = certificates.course_id
        AND ce.id = certificates.enrollment_id
        AND ce.status = 'completed'
        AND (
          (c.instructor_type = 'USER'
           AND c.instructor_user_id = auth.uid()
           AND EXISTS (
             SELECT 1 FROM user_instructor_applications
             WHERE user_id = auth.uid() AND status = 'approved'
           ))
          OR
          (c.instructor_type = 'COMPANY'
           AND EXISTS (
             SELECT 1 FROM company_members cm
             WHERE cm.company_id = c.instructor_company_id
               AND cm.user_id = auth.uid()
               AND cm.role IN ('owner', 'admin', 'instructor')
           ))
        )
    )
  );

-- Policy: Issuers can revoke certificates
CREATE POLICY certificates_update_revoke ON certificates
  FOR UPDATE
  USING (
    issued_by_user_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = certificates.issued_by_company_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin')
    )
  )
  WITH CHECK (
    -- Can only update revocation fields
    status IN ('ISSUED', 'REVOKED')
  );

-- Policy: Admin can manage all certificates
CREATE POLICY certificates_all_admin ON certificates
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Policy 5: Company Documents

```sql
-- Company Documents RLS Policies

ALTER TABLE company_documents ENABLE ROW LEVEL SECURITY;

-- Policy: Company members can view their documents
CREATE POLICY company_docs_select_member ON company_documents
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = company_documents.company_id
        AND cm.user_id = auth.uid()
    )
  );

-- Policy: Company admin/owner can manage documents
CREATE POLICY company_docs_all_admin ON company_documents
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM company_members cm
      WHERE cm.company_id = company_documents.company_id
        AND cm.user_id = auth.uid()
        AND cm.role IN ('owner', 'admin')
    )
  );

-- Policy: System admin can view and verify documents
CREATE POLICY company_docs_all_sysadmin ON company_documents
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

### Policy 6: Reports

```sql
-- Reports RLS Policies

ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can create reports
CREATE POLICY reports_insert_authenticated ON reports
  FOR INSERT
  WITH CHECK (
    auth.uid() IS NOT NULL
    AND reporter_id = auth.uid()
  );

-- Policy: Users can view their own reports
CREATE POLICY reports_select_own ON reports
  FOR SELECT
  USING (reporter_id = auth.uid());

-- Policy: Admin can view and manage all reports
CREATE POLICY reports_all_admin ON reports
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Policy: Prevent users from updating their own reports (only admin)
CREATE POLICY reports_update_admin_only ON reports
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );
```

---

## Task 5: Flutter Implementation Plan

### Guard Updates

```dart
// lib/core/auth/route_guard.dart - Add new routes

// Add to visitorAccessibleRoutes:
static const Set<String> visitorAccessibleRoutes = {
  // ... existing routes ...
  RouteNames.certificateVerifyPublic, // Public certificate verification
};

// Add to authenticatedRoutes:
static const Set<String> authenticatedRoutes = {
  // ... existing routes ...
  RouteNames.reportContent,
  RouteNames.blockedUsers,
  RouteNames.privacySettings,
};

// Add to instructorRoutes:
static const Set<String> instructorRoutes = {
  // ... existing routes ...
  RouteNames.quizBuilder,
  RouteNames.questionBank,
  RouteNames.coursePublish,
  RouteNames.certificateRevoke,
};

// Add to adminRoutes:
static const Set<String> adminRoutes = {
  // ... existing routes ...
  RouteNames.adminInstructorVerifications,
  RouteNames.adminCompanyVerifications,
  RouteNames.adminAuditLog,
};
```

### BLoC Map

| BLoC | Location | Purpose |
|------|----------|---------|
| VerificationBloc | `lib/features/verification/presentation/bloc/` | User and company verification workflows |
| DocumentsBloc | `lib/features/verification/presentation/bloc/` | Document upload and management |
| CourseLifecycleBloc | `lib/features/courses/presentation/bloc/` | Draft/publish/archive transitions |
| QuizBuilderBloc | `lib/features/courses/presentation/bloc/` | Quiz creation and editing |
| QuestionBankBloc | `lib/features/courses/presentation/bloc/` | Question CRUD operations |
| ProgressLockBloc | `lib/features/courses/presentation/bloc/` | Lesson lock/unlock based on quiz |
| CertificateBloc | `lib/features/courses/presentation/bloc/` | Issue/verify/revoke certificates |
| AdminVerificationsBloc | `lib/features/admin/presentation/bloc/` | Admin verification queue management |
| AuditLogsBloc | `lib/features/admin/presentation/bloc/` | Audit log viewing and filtering |
| JobPipelineBloc | `lib/features/jobs/presentation/bloc/` | Application pipeline management |
| PrivacyBloc | `lib/features/profile/presentation/bloc/` | Block/mute user management |
| ModerationBloc | `lib/features/moderation/presentation/bloc/` | Report submission |

### New Repository Structure

```
lib/features/
  verification/
    data/
      datasources/verification_remote_data_source.dart
      repositories/verification_repository_impl.dart
    domain/
      entities/verification_entity.dart
      repositories/verification_repository.dart
    presentation/
      bloc/verification_bloc.dart
      bloc/documents_bloc.dart
      pages/verification_documents_page.dart
      pages/verification_requirements_page.dart

  moderation/
    data/
      datasources/moderation_remote_data_source.dart
      repositories/moderation_repository_impl.dart
    domain/
      entities/report_entity.dart
      repositories/moderation_repository.dart
    presentation/
      bloc/moderation_bloc.dart
      pages/report_page.dart
      widgets/report_dialog.dart
```

### YouTube Utilities

```dart
// lib/core/utils/youtube_utils.dart

class YouTubeUtils {
  static final _youtubeRegex = RegExp(
    r'^(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
  );

  /// Extract video ID from any YouTube URL format
  static String? extractVideoId(String url) {
    final match = _youtubeRegex.firstMatch(url);
    return match?.group(1);
  }

  /// Normalize URL to embed format
  static String? toEmbedUrl(String url) {
    final videoId = extractVideoId(url);
    if (videoId == null) return null;
    return 'https://www.youtube.com/embed/$videoId';
  }

  /// Validate YouTube URL format
  static bool isValidUrl(String url) {
    return _youtubeRegex.hasMatch(url);
  }

  /// Get thumbnail URL
  static String getThumbnailUrl(String videoId, {String quality = 'hqdefault'}) {
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }
}
```

### LoginRequiredPrompt Widget

```dart
// lib/core/widgets/login_required_prompt.dart

class LoginRequiredPrompt extends StatelessWidget {
  const LoginRequiredPrompt({
    super.key,
    required this.action,
    this.onLogin,
    this.onDismiss,
  });

  final String action; // e.g., "like", "comment", "apply"
  final VoidCallback? onLogin;
  final VoidCallback? onDismiss;

  static Future<bool> show(
    BuildContext context, {
    required String action,
    VoidCallback? onLogin,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => LoginRequiredPrompt(
        action: action,
        onLogin: onLogin,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48),
          const SizedBox(height: 16),
          Text(
            'تسجيل الدخول مطلوب',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'يجب تسجيل الدخول لـ$action',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                    onLogin?.call();
                    context.push(RouteNames.login);
                  },
                  child: const Text('تسجيل الدخول'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## Task 6: Edge Function for Certificate PDF

### Edge Function: generate-certificate-pdf

```typescript
// supabase/functions/generate-certificate-pdf/index.ts

import { serve } from 'https://deno.land/std@0.177.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { PDFDocument, rgb, StandardFonts } from 'https://esm.sh/pdf-lib@1.17.1'
import QRCode from 'https://esm.sh/qrcode@1.5.3'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { certificateId } = await req.json()

    // Fetch certificate data
    const { data: cert, error: certError } = await supabaseClient
      .from('certificates')
      .select(`
        *,
        user:profiles!user_id(display_name),
        course:courses(title, description)
      `)
      .eq('id', certificateId)
      .single()

    if (certError || !cert) {
      throw new Error('Certificate not found')
    }

    // Generate QR Code
    const verifyUrl = `${Deno.env.get('PUBLIC_URL')}/verify/${cert.verify_code}`
    const qrCodeDataUrl = await QRCode.toDataURL(verifyUrl, {
      width: 150,
      margin: 1,
    })

    // Create PDF
    const pdfDoc = await PDFDocument.create()
    const page = pdfDoc.addPage([842, 595]) // A4 Landscape
    const { width, height } = page.getSize()

    // Embed fonts
    const helveticaBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold)
    const helvetica = await pdfDoc.embedFont(StandardFonts.Helvetica)

    // Add certificate content
    page.drawText('CERTIFICATE OF COMPLETION', {
      x: width / 2 - 180,
      y: height - 80,
      size: 28,
      font: helveticaBold,
      color: rgb(0.1, 0.3, 0.5),
    })

    page.drawText('This is to certify that', {
      x: width / 2 - 80,
      y: height - 150,
      size: 14,
      font: helvetica,
    })

    page.drawText(cert.user.display_name, {
      x: width / 2 - 100,
      y: height - 200,
      size: 24,
      font: helveticaBold,
    })

    page.drawText('has successfully completed', {
      x: width / 2 - 90,
      y: height - 250,
      size: 14,
      font: helvetica,
    })

    page.drawText(cert.course.title, {
      x: width / 2 - 150,
      y: height - 290,
      size: 18,
      font: helveticaBold,
    })

    page.drawText(`Serial: ${cert.serial_number}`, {
      x: 50,
      y: 50,
      size: 10,
      font: helvetica,
    })

    page.drawText(`Issued: ${new Date(cert.issued_at).toLocaleDateString()}`, {
      x: 50,
      y: 35,
      size: 10,
      font: helvetica,
    })

    // Embed QR code
    const qrImageBytes = Uint8Array.from(
      atob(qrCodeDataUrl.split(',')[1]),
      c => c.charCodeAt(0)
    )
    const qrImage = await pdfDoc.embedPng(qrImageBytes)
    page.drawImage(qrImage, {
      x: width - 170,
      y: 30,
      width: 120,
      height: 120,
    })

    // Save PDF
    const pdfBytes = await pdfDoc.save()

    // Upload to storage
    const fileName = `certificates/${cert.id}.pdf`
    const { error: uploadError } = await supabaseClient.storage
      .from('certificates')
      .upload(fileName, pdfBytes, {
        contentType: 'application/pdf',
        upsert: true,
      })

    if (uploadError) throw uploadError

    // Update certificate with PDF path
    await supabaseClient
      .from('certificates')
      .update({
        pdf_storage_path: fileName,
        qr_code_data: verifyUrl,
        status: 'ISSUED',
        issued_at: new Date().toISOString(),
      })
      .eq('id', certificateId)

    // Get public URL
    const { data: urlData } = supabaseClient.storage
      .from('certificates')
      .getPublicUrl(fileName)

    return new Response(
      JSON.stringify({
        success: true,
        pdfUrl: urlData.publicUrl,
        verifyUrl,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
```

### Flutter Integration

```dart
// lib/features/courses/data/datasources/certificate_remote_data_source.dart

Future<CertificateEntity> generateCertificatePdf(String certificateId) async {
  final response = await _client.functions.invoke(
    'generate-certificate-pdf',
    body: {'certificateId': certificateId},
  );

  if (response.status != 200) {
    throw Exception('Failed to generate certificate PDF');
  }

  final data = response.data as Map<String, dynamic>;

  // Refetch updated certificate
  final cert = await getCertificateById(certificateId);
  return cert.copyWith(
    pdfUrl: data['pdfUrl'] as String?,
    verificationUrl: data['verifyUrl'] as String?,
  );
}
```

---

## Task 6: Phased Execution Plan

### Phase 0: Visitor Enforcement + Guard Cleanup

**Files to Add/Edit:**
- `lib/core/widgets/login_required_prompt.dart` (new)
- `lib/core/widgets/visitor_action_wrapper.dart` (new)
- `lib/core/auth/route_guard.dart` (edit)
- `lib/features/posts/presentation/widgets/post_action_bar.dart` (edit)
- `lib/features/courses/presentation/pages/course_details_page.dart` (edit)
- `lib/features/jobs/presentation/pages/job_details_page.dart` (edit)

**DB Migrations:** None

**RLS Updates:** Verify existing policies enforce read-only for unauthenticated

**Acceptance Criteria:**
- [ ] Visitors can browse /posts, /jobs, /courses, /companies without login
- [ ] Clicking like/comment/save/apply/enroll shows LoginRequiredPrompt
- [ ] Prompt offers "Login" and "Cancel" buttons
- [ ] Login redirects to original page after authentication
- [ ] All action buttons hidden or disabled for visitors
- [ ] Chat, notifications, profile routes redirect to /login for visitors

---

### Phase 1: Verification Schema + Documents + RLS Gating

**Files to Add/Edit:**
- `lib/features/verification/` (new feature module)
- `lib/features/verification/domain/entities/verification_entity.dart`
- `lib/features/verification/domain/entities/document_entity.dart`
- `lib/features/verification/data/datasources/verification_remote_data_source.dart`
- `lib/features/verification/presentation/bloc/verification_bloc.dart`
- `lib/features/verification/presentation/bloc/documents_bloc.dart`
- `lib/features/verification/presentation/pages/verification_documents_page.dart`
- `lib/features/verification/presentation/pages/verification_requirements_page.dart`
- `lib/config/di/injection_container.dart` (edit)

**DB Migrations:**
- `001_verification_tables.sql`

**RLS Updates:**
- `user_instructor_applications` policies
- `user_instructor_documents` policies
- `company_verification_requests` policies
- `company_documents` policies

**Acceptance Criteria:**
- [ ] User can submit instructor application with documents
- [ ] Company owner can submit verification with documents
- [ ] Documents upload to Supabase Storage correctly
- [ ] Document list shows upload history and expiry
- [ ] Rejected users can resubmit with updated documents
- [ ] Requirements page shows checklist per verification type

---

### Phase 2: Split Instructor Dashboard vs Company Training

**Files to Add/Edit:**
- `lib/features/courses/presentation/pages/user_instructor_dashboard_page.dart` (new)
- `lib/features/companies/presentation/pages/company_training_dashboard_page.dart` (new)
- `lib/config/routes/app_router.dart` (edit)
- `lib/config/routes/route_names.dart` (edit)

**DB Migrations:** None (uses existing tables)

**RLS Updates:** None (uses existing policies)

**Acceptance Criteria:**
- [ ] /instructor shows UserInstructorDashboardPage for userInstructor role
- [ ] /companies/:id/training shows CompanyTrainingDashboardPage
- [ ] Each dashboard only shows courses for that instructor type
- [ ] Course cards display issuer badge (User/Company)
- [ ] Clicking issuer links to profile or company page
- [ ] Unverified instructors see VerificationGateWidget

---

### Phase 3: Course Lifecycle + YouTube Validation

**Files to Add/Edit:**
- `lib/core/utils/youtube_utils.dart` (new)
- `lib/features/courses/domain/entities/course_entity.dart` (edit - add status)
- `lib/features/courses/presentation/bloc/course_lifecycle_bloc.dart` (new)
- `lib/features/courses/presentation/pages/course_publish_page.dart` (new)
- `lib/features/courses/presentation/pages/course_preview_page.dart` (new)
- `lib/features/courses/presentation/widgets/youtube_player_widget.dart` (edit)

**DB Migrations:**
- `002_course_ownership_lifecycle.sql`

**RLS Updates:**
- Update courses policies for status filtering

**Acceptance Criteria:**
- [ ] New courses start as DRAFT
- [ ] Publish validates: min 1 lesson, final quiz exists, all YouTube URLs valid
- [ ] Preview page renders course as student would see
- [ ] Archive workflow sends notification to enrolled students
- [ ] Course listings filter by status (published only for public)
- [ ] YouTube URLs validated on lesson save

---

### Phase 4: Quiz Builder + Question Bank + Progress Lock

**Files to Add/Edit:**
- `lib/features/courses/presentation/bloc/quiz_builder_bloc.dart` (new)
- `lib/features/courses/presentation/bloc/question_bank_bloc.dart` (new)
- `lib/features/courses/presentation/bloc/progress_lock_bloc.dart` (new)
- `lib/features/courses/presentation/pages/quiz_builder_page.dart` (new)
- `lib/features/courses/presentation/pages/question_bank_page.dart` (new)
- `lib/features/courses/presentation/pages/quiz_attempts_page.dart` (new)
- `lib/features/courses/presentation/pages/locked_lesson_page.dart` (new)
- `lib/features/courses/presentation/pages/final_quiz_gate_page.dart` (new)

**DB Migrations:**
- `003_quizzes_system.sql`

**RLS Updates:**
- `quizzes` policies
- `quiz_questions` policies
- `quiz_options` policies
- `quiz_attempts` policies
- `quiz_pass_state` policies

**Acceptance Criteria:**
- [ ] Instructor can create quiz with pass score and settings
- [ ] Instructor can add MCQ/TrueFalse questions with options
- [ ] Question bank shows all questions for course
- [ ] Student cannot access locked lesson until quiz passed
- [ ] Quiz attempts logged with score and answers
- [ ] Best score tracked in quiz_pass_state
- [ ] Final quiz gate prevents certificate until passed

---

### Phase 5: Certificates Ecosystem

**Files to Add/Edit:**
- `lib/features/courses/presentation/bloc/certificate_bloc.dart` (new)
- `lib/features/courses/presentation/pages/certificate_verify_public_page.dart` (new)
- `lib/features/courses/presentation/pages/certificate_revoke_page.dart` (new)
- `supabase/functions/generate-certificate-pdf/index.ts` (new)

**DB Migrations:**
- `004_certificates_system.sql`

**RLS Updates:**
- `certificates` policies
- `certificate_verifications` policies

**Acceptance Criteria:**
- [ ] Certificate auto-issued on course completion + final quiz pass
- [ ] PDF generated with student name, course, date, QR code
- [ ] Serial number format: TAMAD-YEAR-RANDOM
- [ ] /verify/:code shows public verification page
- [ ] Revoked certificates show "REVOKED" on verification
- [ ] Instructor/admin can revoke with reason

---

### Phase 6: Admin Verification Queues + Moderation + Audit

**Files to Add/Edit:**
- `lib/features/admin/presentation/pages/admin_instructor_verifications_page.dart` (new)
- `lib/features/admin/presentation/pages/admin_company_verifications_page.dart` (new)
- `lib/features/admin/presentation/pages/admin_reports_page.dart` (new)
- `lib/features/admin/presentation/pages/admin_audit_logs_page.dart` (new)
- `lib/features/admin/presentation/bloc/admin_verifications_bloc.dart` (new)
- `lib/features/admin/presentation/bloc/audit_logs_bloc.dart` (new)
- `lib/features/moderation/` (new feature module)

**DB Migrations:**
- `005_moderation_audit.sql`

**RLS Updates:**
- `reports` policies
- `audit_logs` policies (admin only)

**Acceptance Criteria:**
- [ ] Admin sees pending instructor verifications with documents
- [ ] Admin can approve/reject with reason
- [ ] Admin sees pending company verifications
- [ ] Admin can view and resolve content reports
- [ ] Audit logs track all admin actions
- [ ] Audit logs filterable by action, entity, date

---

### Phase 7: Jobs Pipeline + Applicant Review

**Files to Add/Edit:**
- `lib/features/jobs/presentation/bloc/job_pipeline_bloc.dart` (new)
- `lib/features/jobs/presentation/pages/application_pipeline_page.dart` (new)
- `lib/features/jobs/presentation/pages/applicant_review_page.dart` (new)

**DB Migrations:**
- `006_jobs_pipeline.sql`

**RLS Updates:**
- Update `job_applications` policies for status workflow

**Acceptance Criteria:**
- [ ] Company sees Kanban-style pipeline for applications
- [ ] Drag-drop to change status
- [ ] Applicant review shows resume and answers
- [ ] Internal notes per application
- [ ] Status history tracked
- [ ] Duplicate applications prevented

---

### Phase 8: Search Infrastructure + Filters

**Files to Add/Edit:**
- `lib/features/search/presentation/pages/global_search_page.dart` (edit)
- `lib/features/search/presentation/widgets/search_filters_sheet.dart` (new)

**DB Migrations:**
- `007_search_indexes.sql`

**RLS Updates:** None (search respects existing RLS)

**Acceptance Criteria:**
- [ ] Full-text search across jobs, courses, users, companies
- [ ] Trigram fuzzy matching for typos
- [ ] Filters for location, salary, category, level
- [ ] Infinite scroll pagination
- [ ] Search results cached

---

### Phase 9: Production Hardening

**Files to Add/Edit:**
- `lib/core/presentation/pages/unauthorized_page.dart` (new)
- `lib/core/presentation/pages/not_found_page.dart` (new)
- `lib/core/presentation/pages/network_error_page.dart` (new)
- `lib/core/widgets/empty_state.dart` (new)
- `lib/core/error/error_boundary.dart` (new)
- `test/` (new test files)
- `.github/workflows/ci.yml` (new)

**DB Migrations:** None

**RLS Updates:** None

**Acceptance Criteria:**
- [ ] 403 page shows for unauthorized access
- [ ] 404 page shows for missing routes/resources
- [ ] Network error page with retry button
- [ ] All lists have empty state components
- [ ] Error boundary catches widget errors
- [ ] CI runs tests and lint on PR
- [ ] Unit tests for BLoCs
- [ ] Integration tests for critical flows

---

## Summary

| Phase | Focus | New Pages | Migrations | Priority |
|-------|-------|-----------|------------|----------|
| 0 | Visitor Enforcement | 0 | 0 | Critical |
| 1 | Verification | 2 | 1 | Critical |
| 2 | Dashboard Split | 2 | 0 | High |
| 3 | Course Lifecycle | 2 | 1 | High |
| 4 | Quiz System | 5 | 1 | High |
| 5 | Certificates | 2 | 1 | High |
| 6 | Admin/Moderation | 4 | 1 | Medium |
| 7 | Jobs Pipeline | 2 | 1 | Medium |
| 8 | Search | 0 | 1 | Medium |
| 9 | Production | 3 | 0 | Low |

**Total New Pages:** 22
**Total Migrations:** 7
**Estimated Effort:** 4-6 weeks with focused development
