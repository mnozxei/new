-- Enhanced Company Verification Migration
-- Adding Saudi Arabia specific business fields

-- Add new columns to companies table
ALTER TABLE companies
ADD COLUMN IF NOT EXISTS commercial_registration_number TEXT,
ADD COLUMN IF NOT EXISTS commercial_registration_issue_date DATE,
ADD COLUMN IF NOT EXISTS commercial_registration_expiry_date DATE,
ADD COLUMN IF NOT EXISTS national_address JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS vat_number TEXT,
ADD COLUMN IF NOT EXISTS unified_number TEXT;

-- Create company_documents table for verification documents
CREATE TABLE IF NOT EXISTS company_documents (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    doc_type TEXT NOT NULL, -- 'commercial_register', 'tax_certificate', 'authorization_letter', 'national_address', 'other'
    storage_path TEXT NOT NULL,
    original_name TEXT,
    file_size INTEGER,
    mime_type TEXT,
    issue_date DATE,
    expiry_date DATE,
    status TEXT DEFAULT 'pending' NOT NULL, -- 'pending', 'verified', 'rejected', 'expired'
    rejection_reason TEXT,
    version INTEGER DEFAULT 1,
    uploaded_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    verified_at TIMESTAMPTZ,
    verified_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for fast company documents lookup
CREATE INDEX IF NOT EXISTS idx_company_documents_company_id ON company_documents(company_id);
CREATE INDEX IF NOT EXISTS idx_company_documents_doc_type ON company_documents(doc_type);
CREATE INDEX IF NOT EXISTS idx_company_documents_status ON company_documents(status);

-- Create company_verification_requests table
CREATE TABLE IF NOT EXISTS company_verification_requests (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
    requested_by UUID REFERENCES profiles(id) NOT NULL,
    status TEXT DEFAULT 'submitted' NOT NULL, -- 'submitted', 'under_review', 'approved', 'rejected', 'more_info_needed'
    notes TEXT,
    admin_notes TEXT,
    reviewed_by UUID REFERENCES profiles(id),
    submitted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for verification requests
CREATE INDEX IF NOT EXISTS idx_verification_requests_company_id ON company_verification_requests(company_id);
CREATE INDEX IF NOT EXISTS idx_verification_requests_status ON company_verification_requests(status);

-- RLS for company_documents
ALTER TABLE company_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their company documents" ON company_documents
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM companies c
            LEFT JOIN company_admins ca ON ca.company_id = c.id
            WHERE c.id = company_documents.company_id
            AND (c.owner_id = auth.uid() OR ca.user_id = auth.uid())
        )
    );

CREATE POLICY "Company admins can manage documents" ON company_documents
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM companies c
            LEFT JOIN company_admins ca ON ca.company_id = c.id
            WHERE c.id = company_documents.company_id
            AND (c.owner_id = auth.uid() OR ca.user_id = auth.uid())
        )
    );

CREATE POLICY "Admins can view all company documents" ON company_documents
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

CREATE POLICY "Admins can update company documents" ON company_documents
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- RLS for company_verification_requests
ALTER TABLE company_verification_requests ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Company admins can view their verification requests" ON company_verification_requests
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM companies c
            LEFT JOIN company_admins ca ON ca.company_id = c.id
            WHERE c.id = company_verification_requests.company_id
            AND (c.owner_id = auth.uid() OR ca.user_id = auth.uid())
        )
    );

CREATE POLICY "Company admins can create verification requests" ON company_verification_requests
    FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM companies c
            LEFT JOIN company_admins ca ON ca.company_id = c.id
            WHERE c.id = company_verification_requests.company_id
            AND (c.owner_id = auth.uid() OR ca.user_id = auth.uid())
        )
    );

CREATE POLICY "Admins can manage verification requests" ON company_verification_requests
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM profiles
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Function to check if company is verified (based on documents and request status)
CREATE OR REPLACE FUNCTION get_company_verified_status(company_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM companies c
        WHERE c.id = company_uuid AND c.status = 'verified'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update companies table trigger to update timestamp
CREATE OR REPLACE FUNCTION update_company_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS companies_updated_at ON companies;
CREATE TRIGGER companies_updated_at
    BEFORE UPDATE ON companies
    FOR EACH ROW
    EXECUTE FUNCTION update_company_updated_at();
