-- Migration: 005_certificate_system.sql
-- Description: Add certificate generation and verification system

-- Certificate status enum
DO $$ BEGIN
  CREATE TYPE certificate_status AS ENUM (
    'issued',
    'revoked',
    'expired'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Certificates table
CREATE TABLE IF NOT EXISTS certificates (
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
CREATE TABLE IF NOT EXISTS certificate_verifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  certificate_id UUID NOT NULL REFERENCES certificates(id) ON DELETE CASCADE,
  verified_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ip_address INET,
  user_agent TEXT
);

-- Certificate templates (for customization)
CREATE TABLE IF NOT EXISTS certificate_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,

  -- Template data
  template_html TEXT NOT NULL,
  css_styles TEXT,

  -- Ownership
  owner_type TEXT NOT NULL CHECK (owner_type IN ('platform', 'user_instructor', 'company')),
  owner_id UUID,

  -- Status
  is_active BOOLEAN DEFAULT TRUE,
  is_default BOOLEAN DEFAULT FALSE,

  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_certificates_user ON certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course ON certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_serial ON certificates(serial_number);
CREATE INDEX IF NOT EXISTS idx_certificates_token ON certificates(verification_token);
CREATE INDEX IF NOT EXISTS idx_certificates_status ON certificates(status);
CREATE INDEX IF NOT EXISTS idx_certificates_issued_by ON certificates(issued_by);
CREATE INDEX IF NOT EXISTS idx_certificate_verifications_cert ON certificate_verifications(certificate_id);
CREATE INDEX IF NOT EXISTS idx_certificate_templates_owner ON certificate_templates(owner_type, owner_id);

-- Trigger
DROP TRIGGER IF EXISTS update_certificates_updated_at ON certificates;
CREATE TRIGGER update_certificates_updated_at
  BEFORE UPDATE ON certificates
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_certificate_templates_updated_at ON certificate_templates;
CREATE TRIGGER update_certificate_templates_updated_at
  BEFORE UPDATE ON certificate_templates
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

-- Trigger to auto-generate serial and token
CREATE OR REPLACE FUNCTION auto_generate_certificate_identifiers()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.serial_number IS NULL THEN
    NEW.serial_number := generate_certificate_serial();
  END IF;

  IF NEW.verification_token IS NULL THEN
    NEW.verification_token := generate_verification_token();
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_auto_certificate_identifiers ON certificates;
CREATE TRIGGER trigger_auto_certificate_identifiers
  BEFORE INSERT ON certificates
  FOR EACH ROW EXECUTE FUNCTION auto_generate_certificate_identifiers();

-- Function to check if user can receive certificate
CREATE OR REPLACE FUNCTION can_issue_certificate(p_enrollment_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_enrollment RECORD;
  v_final_quiz_passed BOOLEAN;
BEGIN
  -- Get enrollment
  SELECT * INTO v_enrollment FROM enrollments WHERE id = p_enrollment_id;

  IF v_enrollment IS NULL THEN
    RETURN FALSE;
  END IF;

  -- Check enrollment status
  IF v_enrollment.status != 'completed' THEN
    RETURN FALSE;
  END IF;

  -- Check if final quiz exists and is passed
  SELECT EXISTS (
    SELECT 1 FROM quiz_attempts qa
    JOIN quizzes q ON q.id = qa.quiz_id
    WHERE q.course_id = v_enrollment.course_id
      AND q.is_final_quiz = TRUE
      AND qa.user_id = v_enrollment.user_id
      AND qa.passed = TRUE
  ) INTO v_final_quiz_passed;

  -- If there's a final quiz, it must be passed
  IF EXISTS (
    SELECT 1 FROM quizzes
    WHERE course_id = v_enrollment.course_id AND is_final_quiz = TRUE
  ) AND NOT v_final_quiz_passed THEN
    RETURN FALSE;
  END IF;

  -- Check if certificate already exists
  IF EXISTS (SELECT 1 FROM certificates WHERE enrollment_id = p_enrollment_id) THEN
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- RLS Policies
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificate_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificate_templates ENABLE ROW LEVEL SECURITY;

-- Public can view valid certificates (for verification)
DROP POLICY IF EXISTS "Public can view issued certificates" ON certificates;
CREATE POLICY "Public can view issued certificates"
  ON certificates FOR SELECT
  USING (status = 'issued');

-- Users can view their own certificates
DROP POLICY IF EXISTS "Users can view own certificates" ON certificates;
CREATE POLICY "Users can view own certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- Instructors can view certificates they issued
DROP POLICY IF EXISTS "Issuers can view their certificates" ON certificates;
CREATE POLICY "Issuers can view their certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (issued_by = auth.uid());

-- Admin can view all certificates
DROP POLICY IF EXISTS "Admin can view all certificates" ON certificates;
CREATE POLICY "Admin can view all certificates"
  ON certificates FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Instructors can issue certificates for their courses
DROP POLICY IF EXISTS "Instructors can issue certificates" ON certificates;
CREATE POLICY "Instructors can issue certificates"
  ON certificates FOR INSERT
  TO authenticated
  WITH CHECK (
    (
      EXISTS (
        SELECT 1 FROM courses c
        WHERE c.id = certificates.course_id AND c.instructor_id = auth.uid()
      )
      AND issued_by = auth.uid()
    )
    OR
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Only admin can update certificates (revoke)
DROP POLICY IF EXISTS "Admin can update certificates" ON certificates;
CREATE POLICY "Admin can update certificates"
  ON certificates FOR UPDATE
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Instructors can also revoke their own certificates
DROP POLICY IF EXISTS "Instructors can revoke own certificates" ON certificates;
CREATE POLICY "Instructors can revoke own certificates"
  ON certificates FOR UPDATE
  TO authenticated
  USING (issued_by = auth.uid())
  WITH CHECK (issued_by = auth.uid());

-- Verification logs - anyone can insert (for tracking)
DROP POLICY IF EXISTS "Public can log verifications" ON certificate_verifications;
CREATE POLICY "Public can log verifications"
  ON certificate_verifications FOR INSERT
  WITH CHECK (TRUE);

-- Admin can view verification logs
DROP POLICY IF EXISTS "Admin can view verification logs" ON certificate_verifications;
CREATE POLICY "Admin can view verification logs"
  ON certificate_verifications FOR SELECT
  TO authenticated
  USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Template policies
DROP POLICY IF EXISTS "Public can view active templates" ON certificate_templates;
CREATE POLICY "Public can view active templates"
  ON certificate_templates FOR SELECT
  USING (is_active = TRUE);

DROP POLICY IF EXISTS "Owners can manage templates" ON certificate_templates;
CREATE POLICY "Owners can manage templates"
  ON certificate_templates FOR ALL
  TO authenticated
  USING (
    owner_id = auth.uid() OR
    owner_type = 'platform' AND EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- Insert default platform template
INSERT INTO certificate_templates (name, description, template_html, owner_type, is_default)
SELECT
  'Default TAMAD Certificate',
  'Standard platform certificate template',
  '<div class="certificate">
    <div class="header">
      <h1>TAMAD HUB</h1>
      <h2>شهادة إتمام</h2>
    </div>
    <div class="body">
      <p>نشهد بأن</p>
      <h3>{{recipient_name}}</h3>
      <p>قد أتم بنجاح دورة</p>
      <h3>{{course_title}}</h3>
      <p>بتاريخ {{issued_date}}</p>
    </div>
    <div class="footer">
      <div class="signature">
        <p>{{issuer_name}}</p>
        <p>المدرب</p>
      </div>
      <div class="qr">
        <img src="{{qr_code_url}}" alt="QR Code" />
      </div>
      <div class="serial">
        <p>رقم الشهادة: {{serial_number}}</p>
      </div>
    </div>
  </div>',
  'platform',
  TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM certificate_templates WHERE is_default = TRUE
);
