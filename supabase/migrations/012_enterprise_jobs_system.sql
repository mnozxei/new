-- ============================================
-- ENTERPRISE JOBS SYSTEM
-- Migration 012: Complete Jobs System with Pipeline, Notes, Status History, and Admin features
-- ============================================

-- ============================================
-- 1. ADD JOB STATUS ENUM AND UPDATE JOBS TABLE
-- ============================================

-- Add job_status enum for draft/published/closed/archived
DO $$ BEGIN
  CREATE TYPE job_status AS ENUM ('draft', 'published', 'closed', 'archived', 'hidden');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Add experience_level enum
DO $$ BEGIN
  CREATE TYPE experience_level AS ENUM ('entry', 'junior', 'mid', 'senior', 'lead', 'manager', 'director', 'executive');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Add location_type enum
DO $$ BEGIN
  CREATE TYPE location_type AS ENUM ('onsite', 'remote', 'hybrid');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Update jobs table with new fields
ALTER TABLE jobs
  ADD COLUMN IF NOT EXISTS status job_status DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS experience_level experience_level DEFAULT 'mid',
  ADD COLUMN IF NOT EXISTS location_type location_type DEFAULT 'onsite',
  ADD COLUMN IF NOT EXISTS city TEXT,
  ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS closed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS hidden_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS hidden_by UUID REFERENCES profiles(id),
  ADD COLUMN IF NOT EXISTS hidden_reason TEXT;

-- Migrate existing is_active to status
UPDATE jobs SET status = CASE
  WHEN is_active = true THEN 'published'::job_status
  ELSE 'closed'::job_status
END WHERE status IS NULL OR status = 'draft';

-- ============================================
-- 2. JOB APPLICATION STATUS HISTORY
-- ============================================

CREATE TABLE IF NOT EXISTS job_application_status_history (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID REFERENCES job_applications(id) ON DELETE CASCADE NOT NULL,
  from_status application_status,
  to_status application_status NOT NULL,
  changed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_app_status_history_application ON job_application_status_history(application_id);
CREATE INDEX IF NOT EXISTS idx_app_status_history_created ON job_application_status_history(created_at DESC);

-- ============================================
-- 3. INTERNAL NOTES FOR APPLICATIONS
-- ============================================

CREATE TABLE IF NOT EXISTS job_application_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID REFERENCES job_applications(id) ON DELETE CASCADE NOT NULL,
  author_id UUID REFERENCES profiles(id) ON DELETE SET NULL NOT NULL,
  content TEXT NOT NULL,
  is_private BOOLEAN DEFAULT TRUE, -- True = only company can see
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_app_notes_application ON job_application_notes(application_id);

-- ============================================
-- 4. JOB QUESTIONS (CUSTOM APPLICATION QUESTIONS)
-- ============================================

CREATE TABLE IF NOT EXISTS job_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE NOT NULL,
  question TEXT NOT NULL,
  question_type TEXT DEFAULT 'text', -- text, textarea, select, multiselect, file
  options JSONB DEFAULT '[]', -- For select/multiselect types
  is_required BOOLEAN DEFAULT FALSE,
  order_index INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_job_questions_job ON job_questions(job_id);

-- ============================================
-- 5. JOB QUESTION ANSWERS
-- ============================================

CREATE TABLE IF NOT EXISTS job_question_answers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  application_id UUID REFERENCES job_applications(id) ON DELETE CASCADE NOT NULL,
  question_id UUID REFERENCES job_questions(id) ON DELETE CASCADE NOT NULL,
  answer TEXT,
  file_url TEXT, -- For file type questions
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  UNIQUE(application_id, question_id)
);

CREATE INDEX IF NOT EXISTS idx_question_answers_application ON job_question_answers(application_id);

-- ============================================
-- 6. AUDIT LOGS FOR JOBS
-- ============================================

CREATE TABLE IF NOT EXISTS job_audit_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  job_id UUID REFERENCES jobs(id) ON DELETE CASCADE,
  application_id UUID REFERENCES job_applications(id) ON DELETE CASCADE,
  actor_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
  action TEXT NOT NULL, -- created, updated, published, closed, hidden, application_submitted, status_changed, etc.
  entity_type TEXT NOT NULL, -- job, application, note
  old_data JSONB,
  new_data JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_job_audit_job ON job_audit_logs(job_id);
CREATE INDEX IF NOT EXISTS idx_job_audit_application ON job_audit_logs(application_id);
CREATE INDEX IF NOT EXISTS idx_job_audit_actor ON job_audit_logs(actor_id);
CREATE INDEX IF NOT EXISTS idx_job_audit_created ON job_audit_logs(created_at DESC);

-- ============================================
-- 7. HELPER FUNCTIONS
-- ============================================

-- Function to record status history
CREATE OR REPLACE FUNCTION record_application_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO job_application_status_history (
      application_id,
      from_status,
      to_status,
      changed_by
    ) VALUES (
      NEW.id,
      OLD.status,
      NEW.status,
      auth.uid()
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for status change
DROP TRIGGER IF EXISTS trigger_application_status_change ON job_applications;
CREATE TRIGGER trigger_application_status_change
  AFTER UPDATE ON job_applications
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION record_application_status_change();

-- Function to get job stats for company
CREATE OR REPLACE FUNCTION get_job_stats(p_job_id UUID)
RETURNS TABLE (
  total_applications BIGINT,
  pending_count BIGINT,
  reviewing_count BIGINT,
  shortlisted_count BIGINT,
  interview_count BIGINT,
  offered_count BIGINT,
  accepted_count BIGINT,
  rejected_count BIGINT,
  withdrawn_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) as total_applications,
    COUNT(*) FILTER (WHERE status = 'pending') as pending_count,
    COUNT(*) FILTER (WHERE status = 'reviewing') as reviewing_count,
    COUNT(*) FILTER (WHERE status = 'shortlisted') as shortlisted_count,
    COUNT(*) FILTER (WHERE status = 'interview') as interview_count,
    COUNT(*) FILTER (WHERE status = 'offered') as offered_count,
    COUNT(*) FILTER (WHERE status = 'accepted') as accepted_count,
    COUNT(*) FILTER (WHERE status = 'rejected') as rejected_count,
    COUNT(*) FILTER (WHERE status = 'withdrawn') as withdrawn_count
  FROM job_applications
  WHERE job_id = p_job_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get company job analytics
CREATE OR REPLACE FUNCTION get_company_job_analytics(p_company_id UUID)
RETURNS TABLE (
  total_jobs BIGINT,
  published_jobs BIGINT,
  draft_jobs BIGINT,
  closed_jobs BIGINT,
  total_views BIGINT,
  total_applications BIGINT,
  conversion_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    COUNT(*) as total_jobs,
    COUNT(*) FILTER (WHERE status = 'published') as published_jobs,
    COUNT(*) FILTER (WHERE status = 'draft') as draft_jobs,
    COUNT(*) FILTER (WHERE status = 'closed') as closed_jobs,
    COALESCE(SUM(view_count), 0) as total_views,
    COALESCE(SUM(application_count), 0) as total_applications,
    CASE
      WHEN SUM(view_count) > 0
      THEN ROUND((SUM(application_count)::NUMERIC / SUM(view_count)::NUMERIC) * 100, 2)
      ELSE 0
    END as conversion_rate
  FROM jobs
  WHERE company_id = p_company_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to publish a job
CREATE OR REPLACE FUNCTION publish_job(p_job_id UUID)
RETURNS jobs AS $$
DECLARE
  v_job jobs;
BEGIN
  UPDATE jobs
  SET
    status = 'published',
    is_active = true,
    published_at = NOW(),
    updated_at = NOW()
  WHERE id = p_job_id
  RETURNING * INTO v_job;

  -- Log the action
  INSERT INTO job_audit_logs (job_id, actor_id, action, entity_type, new_data)
  VALUES (p_job_id, auth.uid(), 'published', 'job', row_to_json(v_job));

  RETURN v_job;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to close a job
CREATE OR REPLACE FUNCTION close_job(p_job_id UUID)
RETURNS jobs AS $$
DECLARE
  v_job jobs;
BEGIN
  UPDATE jobs
  SET
    status = 'closed',
    is_active = false,
    closed_at = NOW(),
    updated_at = NOW()
  WHERE id = p_job_id
  RETURNING * INTO v_job;

  -- Log the action
  INSERT INTO job_audit_logs (job_id, actor_id, action, entity_type, new_data)
  VALUES (p_job_id, auth.uid(), 'closed', 'job', row_to_json(v_job));

  RETURN v_job;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to archive a job
CREATE OR REPLACE FUNCTION archive_job(p_job_id UUID)
RETURNS jobs AS $$
DECLARE
  v_job jobs;
BEGIN
  UPDATE jobs
  SET
    status = 'archived',
    is_active = false,
    updated_at = NOW()
  WHERE id = p_job_id
  RETURNING * INTO v_job;

  RETURN v_job;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function for admin to hide a job
CREATE OR REPLACE FUNCTION admin_hide_job(p_job_id UUID, p_reason TEXT)
RETURNS jobs AS $$
DECLARE
  v_job jobs;
  v_user_role user_role;
BEGIN
  -- Check if user is admin
  SELECT role INTO v_user_role FROM profiles WHERE id = auth.uid();
  IF v_user_role != 'admin' THEN
    RAISE EXCEPTION 'Only admins can hide jobs';
  END IF;

  UPDATE jobs
  SET
    status = 'hidden',
    is_active = false,
    hidden_at = NOW(),
    hidden_by = auth.uid(),
    hidden_reason = p_reason,
    updated_at = NOW()
  WHERE id = p_job_id
  RETURNING * INTO v_job;

  -- Log the action
  INSERT INTO job_audit_logs (job_id, actor_id, action, entity_type, new_data)
  VALUES (p_job_id, auth.uid(), 'hidden', 'job', jsonb_build_object('reason', p_reason));

  RETURN v_job;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to send notification on application status change
CREATE OR REPLACE FUNCTION notify_application_status_change()
RETURNS TRIGGER AS $$
DECLARE
  v_job_title TEXT;
  v_company_name TEXT;
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Get job and company info
    SELECT j.title, c.name INTO v_job_title, v_company_name
    FROM jobs j
    JOIN companies c ON j.company_id = c.id
    WHERE j.id = NEW.job_id;

    -- Create notification for applicant
    INSERT INTO notifications (
      user_id,
      type,
      title,
      body,
      data
    ) VALUES (
      NEW.user_id,
      'job',
      'تحديث حالة الطلب',
      'تم تحديث حالة طلبك لوظيفة "' || v_job_title || '" في ' || v_company_name,
      jsonb_build_object(
        'job_id', NEW.job_id,
        'application_id', NEW.id,
        'old_status', OLD.status,
        'new_status', NEW.status,
        'route', '/jobs/' || NEW.job_id
      )
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_application_status ON job_applications;
CREATE TRIGGER trigger_notify_application_status
  AFTER UPDATE ON job_applications
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION notify_application_status_change();

-- Function to notify company on new application
CREATE OR REPLACE FUNCTION notify_new_application()
RETURNS TRIGGER AS $$
DECLARE
  v_job_title TEXT;
  v_company_owner UUID;
  v_applicant_name TEXT;
BEGIN
  -- Get job title and company owner
  SELECT j.title, c.owner_id INTO v_job_title, v_company_owner
  FROM jobs j
  JOIN companies c ON j.company_id = c.id
  WHERE j.id = NEW.job_id;

  -- Get applicant name
  SELECT full_name INTO v_applicant_name
  FROM profiles WHERE id = NEW.user_id;

  -- Notify company owner
  INSERT INTO notifications (
    user_id,
    type,
    title,
    body,
    data
  ) VALUES (
    v_company_owner,
    'job',
    'طلب وظيفة جديد',
    'تقدم ' || v_applicant_name || ' لوظيفة "' || v_job_title || '"',
    jsonb_build_object(
      'job_id', NEW.job_id,
      'application_id', NEW.id,
      'applicant_id', NEW.user_id,
      'route', '/jobs/' || NEW.job_id || '/applications'
    )
  );

  -- Also notify company admins
  INSERT INTO notifications (user_id, type, title, body, data)
  SELECT
    ca.user_id,
    'job',
    'طلب وظيفة جديد',
    'تقدم ' || v_applicant_name || ' لوظيفة "' || v_job_title || '"',
    jsonb_build_object(
      'job_id', NEW.job_id,
      'application_id', NEW.id,
      'applicant_id', NEW.user_id,
      'route', '/jobs/' || NEW.job_id || '/applications'
    )
  FROM company_admins ca
  JOIN jobs j ON j.company_id = ca.company_id
  WHERE j.id = NEW.job_id AND ca.user_id != v_company_owner;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS trigger_notify_new_application ON job_applications;
CREATE TRIGGER trigger_notify_new_application
  AFTER INSERT ON job_applications
  FOR EACH ROW
  EXECUTE FUNCTION notify_new_application();

-- ============================================
-- 8. RLS POLICIES
-- ============================================

-- Enable RLS
ALTER TABLE job_application_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_application_notes ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_question_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_audit_logs ENABLE ROW LEVEL SECURITY;

-- Jobs RLS - Update existing policies
DROP POLICY IF EXISTS "Anyone can view published jobs" ON jobs;
CREATE POLICY "Anyone can view published jobs" ON jobs
  FOR SELECT USING (status = 'published' OR status IS NULL AND is_active = true);

DROP POLICY IF EXISTS "Company members can view all their jobs" ON jobs;
CREATE POLICY "Company members can view all their jobs" ON jobs
  FOR SELECT USING (
    company_id IN (
      SELECT company_id FROM company_admins WHERE user_id = auth.uid()
      UNION
      SELECT id FROM companies WHERE owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Company members can insert jobs" ON jobs;
CREATE POLICY "Company members can insert jobs" ON jobs
  FOR INSERT WITH CHECK (
    company_id IN (
      SELECT company_id FROM company_admins WHERE user_id = auth.uid() AND role IN ('admin', 'editor')
      UNION
      SELECT id FROM companies WHERE owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Company members can update their jobs" ON jobs;
CREATE POLICY "Company members can update their jobs" ON jobs
  FOR UPDATE USING (
    company_id IN (
      SELECT company_id FROM company_admins WHERE user_id = auth.uid() AND role IN ('admin', 'editor')
      UNION
      SELECT id FROM companies WHERE owner_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can do anything with jobs" ON jobs;
CREATE POLICY "Admins can do anything with jobs" ON jobs
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Job Applications RLS
DROP POLICY IF EXISTS "Users can view their own applications" ON job_applications;
CREATE POLICY "Users can view their own applications" ON job_applications
  FOR SELECT USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Company members can view applications for their jobs" ON job_applications;
CREATE POLICY "Company members can view applications for their jobs" ON job_applications
  FOR SELECT USING (
    job_id IN (
      SELECT j.id FROM jobs j
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Users can insert their own applications" ON job_applications;
CREATE POLICY "Users can insert their own applications" ON job_applications
  FOR INSERT WITH CHECK (user_id = auth.uid());

DROP POLICY IF EXISTS "Company members can update applications" ON job_applications;
CREATE POLICY "Company members can update applications" ON job_applications
  FOR UPDATE USING (
    job_id IN (
      SELECT j.id FROM jobs j
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Users can update their own applications" ON job_applications;
CREATE POLICY "Users can update their own applications" ON job_applications
  FOR UPDATE USING (user_id = auth.uid());

-- Status History RLS
CREATE POLICY "Users can view their application history" ON job_application_status_history
  FOR SELECT USING (
    application_id IN (SELECT id FROM job_applications WHERE user_id = auth.uid())
  );

CREATE POLICY "Company can view application history for their jobs" ON job_application_status_history
  FOR SELECT USING (
    application_id IN (
      SELECT ja.id FROM job_applications ja
      JOIN jobs j ON ja.job_id = j.id
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

-- Application Notes RLS
CREATE POLICY "Company can manage notes for their job applications" ON job_application_notes
  FOR ALL USING (
    application_id IN (
      SELECT ja.id FROM job_applications ja
      JOIN jobs j ON ja.job_id = j.id
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

CREATE POLICY "Users can view public notes on their applications" ON job_application_notes
  FOR SELECT USING (
    is_private = false AND
    application_id IN (SELECT id FROM job_applications WHERE user_id = auth.uid())
  );

-- Job Questions RLS
CREATE POLICY "Anyone can view job questions" ON job_questions
  FOR SELECT USING (true);

CREATE POLICY "Company can manage their job questions" ON job_questions
  FOR ALL USING (
    job_id IN (
      SELECT j.id FROM jobs j
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

-- Question Answers RLS
CREATE POLICY "Users can manage their own answers" ON job_question_answers
  FOR ALL USING (
    application_id IN (SELECT id FROM job_applications WHERE user_id = auth.uid())
  );

CREATE POLICY "Company can view answers for their jobs" ON job_question_answers
  FOR SELECT USING (
    application_id IN (
      SELECT ja.id FROM job_applications ja
      JOIN jobs j ON ja.job_id = j.id
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

-- Audit Logs RLS (read-only for admins)
CREATE POLICY "Admins can view audit logs" ON job_audit_logs
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Company can view audit logs for their jobs" ON job_audit_logs
  FOR SELECT USING (
    job_id IN (
      SELECT j.id FROM jobs j
      WHERE j.company_id IN (
        SELECT company_id FROM company_admins WHERE user_id = auth.uid()
        UNION
        SELECT id FROM companies WHERE owner_id = auth.uid()
      )
    )
  );

-- Saved Jobs RLS
DROP POLICY IF EXISTS "Users can manage their saved jobs" ON saved_jobs;
CREATE POLICY "Users can manage their saved jobs" ON saved_jobs
  FOR ALL USING (user_id = auth.uid());

-- ============================================
-- 9. INDEXES FOR PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS idx_jobs_company_status ON jobs(company_id, status);
CREATE INDEX IF NOT EXISTS idx_jobs_city ON jobs(city);
CREATE INDEX IF NOT EXISTS idx_jobs_experience_level ON jobs(experience_level);
CREATE INDEX IF NOT EXISTS idx_jobs_location_type ON jobs(location_type);
CREATE INDEX IF NOT EXISTS idx_jobs_tags ON jobs USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_jobs_published_at ON jobs(published_at DESC);
CREATE INDEX IF NOT EXISTS idx_jobs_search ON jobs USING GIN(to_tsvector('arabic', title || ' ' || COALESCE(description, '')));

CREATE INDEX IF NOT EXISTS idx_applications_status ON job_applications(status);
CREATE INDEX IF NOT EXISTS idx_applications_job_status ON job_applications(job_id, status);
CREATE INDEX IF NOT EXISTS idx_applications_user ON job_applications(user_id);

-- ============================================
-- 10. IMPRESSIONS FOR JOBS
-- ============================================

-- Update impressions to support jobs
-- Already handled in 009_impressions_notifications.sql but ensure job type exists
DO $$ BEGIN
  ALTER TABLE impressions ADD COLUMN IF NOT EXISTS entity_type TEXT DEFAULT 'post';
EXCEPTION WHEN others THEN NULL;
END $$;

-- Function to record job impression
CREATE OR REPLACE FUNCTION record_job_impression(p_job_id UUID, p_interaction_type TEXT DEFAULT 'view')
RETURNS VOID AS $$
BEGIN
  INSERT INTO impressions (entity_type, entity_id, user_id, interaction_type)
  VALUES ('job', p_job_id, auth.uid(), p_interaction_type)
  ON CONFLICT DO NOTHING;

  -- Update view count
  IF p_interaction_type = 'view' THEN
    UPDATE jobs SET view_count = view_count + 1 WHERE id = p_job_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
