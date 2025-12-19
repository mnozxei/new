-- Migration: 007_moderation_audit.sql
-- Description: Add content moderation and audit logging system

-- Report reason enum
DO $$ BEGIN
  CREATE TYPE report_reason AS ENUM (
    'spam',
    'harassment',
    'inappropriate_content',
    'misinformation',
    'copyright_violation',
    'other'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Report status enum
DO $$ BEGIN
  CREATE TYPE report_status AS ENUM (
    'pending',
    'under_review',
    'resolved_removed',
    'resolved_warned',
    'resolved_dismissed'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Content reports table
CREATE TABLE IF NOT EXISTS content_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Reporter
  reporter_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  -- Content reference (polymorphic)
  content_type TEXT NOT NULL CHECK (content_type IN ('post', 'comment', 'job', 'course', 'message', 'profile', 'company')),
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
CREATE TABLE IF NOT EXISTS admin_actions (
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
CREATE TABLE IF NOT EXISTS audit_logs (
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
  session_id TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Banned words table
CREATE TABLE IF NOT EXISTS banned_words (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  word TEXT NOT NULL UNIQUE,
  severity TEXT NOT NULL DEFAULT 'warn' CHECK (severity IN ('warn', 'block', 'ban')),
  is_regex BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- User moderation actions (warnings/bans)
CREATE TABLE IF NOT EXISTS user_moderation (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,

  action_type TEXT NOT NULL CHECK (action_type IN ('warning', 'temporary_ban', 'permanent_ban', 'mute')),
  reason TEXT NOT NULL,
  related_report_id UUID REFERENCES content_reports(id),

  issued_by UUID NOT NULL REFERENCES profiles(id),

  starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ends_at TIMESTAMPTZ,
  duration_hours INTEGER,

  is_active BOOLEAN DEFAULT TRUE,
  revoked_at TIMESTAMPTZ,
  revoked_by UUID REFERENCES profiles(id),
  revoke_reason TEXT,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Moderation queue view
CREATE OR REPLACE VIEW moderation_queue AS
SELECT
  cr.id,
  cr.content_type,
  cr.content_id,
  cr.reason,
  cr.description,
  cr.status,
  cr.created_at,
  p.full_name AS reporter_name,
  p.avatar_url AS reporter_avatar,
  COUNT(*) OVER (PARTITION BY cr.content_type, cr.content_id) AS report_count,
  CASE
    WHEN cr.content_type = 'post' THEN (SELECT content FROM posts WHERE id = cr.content_id)
    WHEN cr.content_type = 'comment' THEN (SELECT content FROM post_comments WHERE id = cr.content_id)
    ELSE NULL
  END AS content_preview
FROM content_reports cr
JOIN profiles p ON p.id = cr.reporter_id
WHERE cr.status IN ('pending', 'under_review')
ORDER BY cr.created_at DESC;

-- Indexes
CREATE INDEX IF NOT EXISTS idx_content_reports_status ON content_reports(status);
CREATE INDEX IF NOT EXISTS idx_content_reports_content ON content_reports(content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_reporter ON content_reports(reporter_id);
CREATE INDEX IF NOT EXISTS idx_content_reports_created ON content_reports(created_at);
CREATE INDEX IF NOT EXISTS idx_admin_actions_admin ON admin_actions(admin_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_target ON admin_actions(target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_admin_actions_created ON admin_actions(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_user_moderation_user ON user_moderation(user_id);
CREATE INDEX IF NOT EXISTS idx_user_moderation_active ON user_moderation(is_active) WHERE is_active = TRUE;

-- Triggers
DROP TRIGGER IF EXISTS update_content_reports_updated_at ON content_reports;
CREATE TRIGGER update_content_reports_updated_at
  BEFORE UPDATE ON content_reports
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to check if user is banned
CREATE OR REPLACE FUNCTION is_user_banned(p_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_moderation
    WHERE user_id = p_user_id
      AND is_active = TRUE
      AND action_type IN ('temporary_ban', 'permanent_ban')
      AND (ends_at IS NULL OR ends_at > NOW())
  );
END;
$$ LANGUAGE plpgsql;

-- Function to auto-expire temporary bans
CREATE OR REPLACE FUNCTION expire_temporary_bans()
RETURNS void AS $$
BEGIN
  UPDATE user_moderation
  SET is_active = FALSE
  WHERE is_active = TRUE
    AND action_type = 'temporary_ban'
    AND ends_at IS NOT NULL
    AND ends_at <= NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to log admin actions
CREATE OR REPLACE FUNCTION log_admin_action(
  p_admin_id UUID,
  p_action_type TEXT,
  p_target_type TEXT,
  p_target_id UUID,
  p_details JSONB DEFAULT NULL,
  p_reason TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_action_id UUID;
BEGIN
  INSERT INTO admin_actions (admin_id, action_type, target_type, target_id, details, reason)
  VALUES (p_admin_id, p_action_type, p_target_type, p_target_id, p_details, p_reason)
  RETURNING id INTO v_action_id;

  RETURN v_action_id;
END;
$$ LANGUAGE plpgsql;

-- Function to log audit entry
CREATE OR REPLACE FUNCTION log_audit(
  p_user_id UUID,
  p_action TEXT,
  p_resource_type TEXT,
  p_resource_id UUID DEFAULT NULL,
  p_old_values JSONB DEFAULT NULL,
  p_new_values JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
  v_user_role TEXT;
BEGIN
  SELECT role INTO v_user_role FROM profiles WHERE id = p_user_id;

  INSERT INTO audit_logs (user_id, user_role, action, resource_type, resource_id, old_values, new_values)
  VALUES (p_user_id, v_user_role, p_action, p_resource_type, p_resource_id, p_old_values, p_new_values)
  RETURNING id INTO v_log_id;

  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql;

-- RLS Policies
ALTER TABLE content_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE banned_words ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_moderation ENABLE ROW LEVEL SECURITY;

-- Content reports policies
DROP POLICY IF EXISTS "Users can create reports" ON content_reports;
CREATE POLICY "Users can create reports"
  ON content_reports FOR INSERT
  TO authenticated
  WITH CHECK (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Users can view own reports" ON content_reports;
CREATE POLICY "Users can view own reports"
  ON content_reports FOR SELECT
  TO authenticated
  USING (reporter_id = auth.uid());

DROP POLICY IF EXISTS "Admin can view all reports" ON content_reports;
CREATE POLICY "Admin can view all reports"
  ON content_reports FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admin can manage reports" ON content_reports;
CREATE POLICY "Admin can manage reports"
  ON content_reports FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Admin actions policies (admin only)
DROP POLICY IF EXISTS "Admin can view actions" ON admin_actions;
CREATE POLICY "Admin can view actions"
  ON admin_actions FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "Admin can create actions" ON admin_actions;
CREATE POLICY "Admin can create actions"
  ON admin_actions FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
    AND admin_id = auth.uid()
  );

-- Audit logs policies (admin only, insert allowed for system)
DROP POLICY IF EXISTS "Admin can view audit logs" ON audit_logs;
CREATE POLICY "Admin can view audit logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

DROP POLICY IF EXISTS "System can insert audit logs" ON audit_logs;
CREATE POLICY "System can insert audit logs"
  ON audit_logs FOR INSERT
  TO authenticated
  WITH CHECK (TRUE);

-- Banned words policies (admin only)
DROP POLICY IF EXISTS "Admin can manage banned words" ON banned_words;
CREATE POLICY "Admin can manage banned words"
  ON banned_words FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- User moderation policies
DROP POLICY IF EXISTS "Users can view own moderation" ON user_moderation;
CREATE POLICY "Users can view own moderation"
  ON user_moderation FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Admin can manage user moderation" ON user_moderation;
CREATE POLICY "Admin can manage user moderation"
  ON user_moderation FOR ALL
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Insert some default banned words (Arabic and English)
INSERT INTO banned_words (word, severity, is_active) VALUES
  ('spam', 'block', TRUE),
  ('scam', 'block', TRUE)
ON CONFLICT (word) DO NOTHING;
