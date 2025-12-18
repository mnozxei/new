-- TAMAD HUB - Storage Bucket Setup
-- Run this AFTER schema.sql and rls_policies.sql

-- ===========================================
-- CREATE STORAGE BUCKETS
-- ===========================================

-- Profiles bucket for avatars and user files
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'profiles',
    'profiles',
    true,
    5242880, -- 5MB
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Companies bucket for logos, covers, and documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'companies',
    'companies',
    true,
    10485760, -- 10MB
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'application/pdf']
) ON CONFLICT (id) DO NOTHING;

-- Company documents bucket (private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'company-documents',
    'company-documents',
    false,
    20971520, -- 20MB
    ARRAY['application/pdf', 'image/jpeg', 'image/png']
) ON CONFLICT (id) DO NOTHING;

-- Company assets bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'company-assets',
    'company-assets',
    true,
    10485760, -- 10MB
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
) ON CONFLICT (id) DO NOTHING;

-- Resumes bucket (private)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'resumes',
    'resumes',
    false,
    10485760, -- 10MB
    ARRAY['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
) ON CONFLICT (id) DO NOTHING;

-- Courses bucket for thumbnails, videos, and materials
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'courses',
    'courses',
    true,
    104857600, -- 100MB for videos
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'video/mp4', 'video/webm', 'application/pdf']
) ON CONFLICT (id) DO NOTHING;

-- Posts bucket for media attachments
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'posts',
    'posts',
    true,
    20971520, -- 20MB
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'video/webm']
) ON CONFLICT (id) DO NOTHING;

-- Chat attachments bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'chat-attachments',
    'chat-attachments',
    false,
    20971520, -- 20MB
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4', 'application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']
) ON CONFLICT (id) DO NOTHING;

-- Ads bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'ads',
    'ads',
    true,
    10485760, -- 10MB
    ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4']
) ON CONFLICT (id) DO NOTHING;

-- ===========================================
-- STORAGE POLICIES
-- ===========================================

-- Profiles bucket policies
CREATE POLICY "Public profile images are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'profiles');

CREATE POLICY "Users can upload their own profile images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'profiles'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update their own profile images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'profiles'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete their own profile images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'profiles'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Companies bucket policies
CREATE POLICY "Company images are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'companies');

CREATE POLICY "Company owners can upload company images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'companies'
        AND EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id::text = (storage.foldername(name))[1]
            AND companies.owner_id = auth.uid()
        )
    );

CREATE POLICY "Company owners can update company images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'companies'
        AND EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id::text = (storage.foldername(name))[1]
            AND companies.owner_id = auth.uid()
        )
    );

CREATE POLICY "Company owners can delete company images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'companies'
        AND EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id::text = (storage.foldername(name))[1]
            AND companies.owner_id = auth.uid()
        )
    );

-- Company documents bucket policies (private)
CREATE POLICY "Company owners can view their documents"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'company-documents'
        AND EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id::text = (storage.foldername(name))[1]
            AND companies.owner_id = auth.uid()
        )
    );

CREATE POLICY "Company owners can upload documents"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'company-documents'
        AND EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id::text = (storage.foldername(name))[1]
            AND companies.owner_id = auth.uid()
        )
    );

-- Company assets bucket policies
CREATE POLICY "Company assets are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'company-assets');

CREATE POLICY "Company owners can upload assets"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'company-assets'
        AND EXISTS (
            SELECT 1 FROM companies
            WHERE companies.id::text = (storage.foldername(name))[1]
            AND companies.owner_id = auth.uid()
        )
    );

-- Resumes bucket policies (private)
CREATE POLICY "Users can view own resumes"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'resumes'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can upload own resumes"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'resumes'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own resumes"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'resumes'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Courses bucket policies
CREATE POLICY "Course content is viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'courses');

CREATE POLICY "Instructors can upload course content"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'courses'
        AND EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id::text = (storage.foldername(name))[1]
            AND courses.instructor_id = auth.uid()
        )
    );

CREATE POLICY "Instructors can update course content"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'courses'
        AND EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id::text = (storage.foldername(name))[1]
            AND courses.instructor_id = auth.uid()
        )
    );

CREATE POLICY "Instructors can delete course content"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'courses'
        AND EXISTS (
            SELECT 1 FROM courses
            WHERE courses.id::text = (storage.foldername(name))[1]
            AND courses.instructor_id = auth.uid()
        )
    );

-- Posts bucket policies
CREATE POLICY "Post media is viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'posts');

CREATE POLICY "Users can upload post media"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'posts'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete own post media"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'posts'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Chat attachments bucket policies (private)
CREATE POLICY "Chat participants can view attachments"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'chat-attachments'
        AND EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_participants.conversation_id::text = (storage.foldername(name))[1]
            AND conversation_participants.user_id = auth.uid()
        )
    );

CREATE POLICY "Chat participants can upload attachments"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'chat-attachments'
        AND EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_participants.conversation_id::text = (storage.foldername(name))[1]
            AND conversation_participants.user_id = auth.uid()
        )
    );

-- Ads bucket policies
CREATE POLICY "Ad images are viewable by everyone"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'ads');

CREATE POLICY "Advertisers can upload ad images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'ads'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Advertisers can update ad images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'ads'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Advertisers can delete ad images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'ads'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );
