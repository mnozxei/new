-- Migration: 003_instructor_verification.sql
-- Description: Add instructor verification tables and workflow

-- Instructor verification status enum
DO $$ BEGIN
  CREATE TYPE instructor_verification_status AS ENUM (
    'not_submitted',
    'pending',
    'approved',
    'rejected',
    'suspended'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- User instructor verifications
CREATE TABLE IF NOT EXISTS instructor_verifications (
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
CREATE TABLE IF NOT EXISTS instructor_verification_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  verification_id UUID NOT NULL REFERENCES instructor_verifications(id) ON DELETE CASCADE,
  previous_status instructor_verification_status NOT NULL,
  new_status instructor_verification_status NOT NULL,
  changed_by UUID REFERENCES profiles(id),
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_instructor_verifications_user ON instructor_verifications(user_id);
CREATE INDEX IF NOT EXISTS idx_instructor_verifications_status ON instructor_verifications(status);
CREATE INDEX IF NOT EXISTS idx_instructor_verification_history_verification ON instructor_verification_history(verification_id);

-- Trigger for updated_at
DROP TRIGGER IF EXISTS update_instructor_verifications_updated_at ON instructor_verifications;
CREATE TRIGGER update_instructor_verifications_updated_at
  BEFORE UPDATE ON instructor_verifications
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Trigger to log verification status changes
CREATE OR REPLACE FUNCTION log_verification_status_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO instructor_verification_history (
      verification_id,
      previous_status,
      new_status,
      changed_by,
      reason
    ) VALUES (
      NEW.id,
      OLD.status,
      NEW.status,
      NEW.reviewed_by,
      CASE
        WHEN NEW.status = 'rejected' THEN NEW.rejection_reason
        ELSE NEW.admin_notes
      END
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_log_verification_status ON instructor_verifications;
CREATE TRIGGER trigger_log_verification_status
  AFTER UPDATE ON instructor_verifications
  FOR EACH ROW EXECUTE FUNCTION log_verification_status_change();

-- RLS Policies
ALTER TABLE instructor_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE instructor_verification_history ENABLE ROW LEVEL SECURITY;

-- Users can view their own verification
DROP POLICY IF EXISTS "Users can view own verification" ON instructor_verifications;
CREATE POLICY "Users can view own verification"
  ON instructor_verifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Admins can view all verifications
DROP POLICY IF EXISTS "Admins can view all verifications" ON instructor_verifications;
CREATE POLICY "Admins can view all verifications"
  ON instructor_verifications FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Users can insert their own verification
DROP POLICY IF EXISTS "Users can create own verification" ON instructor_verifications;
CREATE POLICY "Users can create own verification"
  ON instructor_verifications FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- Users can update own verification if not approved
DROP POLICY IF EXISTS "Users can update own pending verification" ON instructor_verifications;
CREATE POLICY "Users can update own pending verification"
  ON instructor_verifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() AND status IN ('not_submitted', 'rejected'))
  WITH CHECK (user_id = auth.uid());

-- Admins can update any verification
DROP POLICY IF EXISTS "Admins can update any verification" ON instructor_verifications;
CREATE POLICY "Admins can update any verification"
  ON instructor_verifications FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- History policies
DROP POLICY IF EXISTS "Users can view own history" ON instructor_verification_history;
CREATE POLICY "Users can view own history"
  ON instructor_verification_history FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM instructor_verifications iv
      WHERE iv.id = verification_id AND iv.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Admins can view all history" ON instructor_verification_history;
CREATE POLICY "Admins can view all history"
  ON instructor_verification_history FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );
