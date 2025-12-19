-- Migration: 009_impressions_notifications
-- Description: Add content impressions tracking and improve notifications
-- Date: 2024

-- ===========================================
-- CONTENT IMPRESSIONS TABLE
-- ===========================================
CREATE TABLE IF NOT EXISTS content_impressions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type TEXT NOT NULL CHECK (entity_type IN ('post', 'job', 'course', 'company', 'profile')),
    entity_id UUID NOT NULL,
    viewer_user_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    viewer_session_id TEXT,
    date_bucket DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    -- Unique constraint: one impression per entity per viewer per day
    UNIQUE(entity_type, entity_id, viewer_user_id, date_bucket),
    -- Index for fast lookups
    CONSTRAINT impressions_viewer_check CHECK (
        viewer_user_id IS NOT NULL OR viewer_session_id IS NOT NULL
    )
);

-- Index for aggregation queries
CREATE INDEX IF NOT EXISTS idx_impressions_entity ON content_impressions(entity_type, entity_id);
CREATE INDEX IF NOT EXISTS idx_impressions_date ON content_impressions(date_bucket);
CREATE INDEX IF NOT EXISTS idx_impressions_entity_date ON content_impressions(entity_type, entity_id, date_bucket);

-- ===========================================
-- IMPRESSION AGGREGATES (Materialized View)
-- ===========================================
CREATE MATERIALIZED VIEW IF NOT EXISTS impression_aggregates AS
SELECT
    entity_type,
    entity_id,
    COUNT(*) as total_views,
    COUNT(DISTINCT COALESCE(viewer_user_id::text, viewer_session_id)) as unique_views,
    COUNT(*) FILTER (WHERE date_bucket = CURRENT_DATE) as today_views,
    COUNT(*) FILTER (WHERE date_bucket >= CURRENT_DATE - INTERVAL '7 days') as week_views,
    COUNT(*) FILTER (WHERE date_bucket >= CURRENT_DATE - INTERVAL '30 days') as month_views
FROM content_impressions
GROUP BY entity_type, entity_id;

CREATE UNIQUE INDEX IF NOT EXISTS idx_impression_agg_entity ON impression_aggregates(entity_type, entity_id);

-- ===========================================
-- UPDATE NOTIFICATIONS TABLE FOR DEEP LINKING
-- ===========================================
ALTER TABLE notifications
ADD COLUMN IF NOT EXISTS entity_id UUID,
ADD COLUMN IF NOT EXISTS parent_id UUID,
ADD COLUMN IF NOT EXISTS action_type TEXT;

-- Index for entity lookups
CREATE INDEX IF NOT EXISTS idx_notifications_entity ON notifications(type, entity_id);

-- ===========================================
-- RPC: Record Impression
-- ===========================================
CREATE OR REPLACE FUNCTION record_impression(
    p_entity_type TEXT,
    p_entity_id UUID,
    p_viewer_user_id UUID DEFAULT NULL,
    p_date_bucket DATE DEFAULT CURRENT_DATE
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO content_impressions (entity_type, entity_id, viewer_user_id, date_bucket)
    VALUES (p_entity_type, p_entity_id, p_viewer_user_id, p_date_bucket)
    ON CONFLICT (entity_type, entity_id, viewer_user_id, date_bucket) DO NOTHING;

    -- Update view count on the entity table if it has one
    IF p_entity_type = 'job' THEN
        UPDATE jobs SET view_count = view_count + 1 WHERE id = p_entity_id;
    ELSIF p_entity_type = 'post' THEN
        UPDATE posts SET view_count = COALESCE(view_count, 0) + 1 WHERE id = p_entity_id;
    ELSIF p_entity_type = 'course' THEN
        UPDATE courses SET view_count = COALESCE(view_count, 0) + 1 WHERE id = p_entity_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- RPC: Get Impression Stats
-- ===========================================
CREATE OR REPLACE FUNCTION get_impression_stats(
    p_entity_type TEXT,
    p_entity_id UUID
)
RETURNS TABLE (
    total_views BIGINT,
    unique_views BIGINT,
    today_views BIGINT,
    week_views BIGINT,
    month_views BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(*)::BIGINT as total_views,
        COUNT(DISTINCT COALESCE(viewer_user_id::text, viewer_session_id))::BIGINT as unique_views,
        COUNT(*) FILTER (WHERE date_bucket = CURRENT_DATE)::BIGINT as today_views,
        COUNT(*) FILTER (WHERE date_bucket >= CURRENT_DATE - INTERVAL '7 days')::BIGINT as week_views,
        COUNT(*) FILTER (WHERE date_bucket >= CURRENT_DATE - INTERVAL '30 days')::BIGINT as month_views
    FROM content_impressions
    WHERE entity_type = p_entity_type AND entity_id = p_entity_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- RPC: Get Aggregated Stats for Multiple Entities
-- ===========================================
CREATE OR REPLACE FUNCTION get_aggregated_impression_stats(
    p_entity_type TEXT,
    p_entity_ids UUID[],
    p_days INT DEFAULT 30
)
RETURNS TABLE (
    entity_id UUID,
    total_views BIGINT,
    unique_views BIGINT,
    daily_stats JSONB
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ci.entity_id,
        COUNT(*)::BIGINT as total_views,
        COUNT(DISTINCT COALESCE(ci.viewer_user_id::text, ci.viewer_session_id))::BIGINT as unique_views,
        COALESCE(
            jsonb_agg(
                jsonb_build_object(
                    'date', ci.date_bucket,
                    'views', daily.views,
                    'unique_views', daily.unique_views
                ) ORDER BY ci.date_bucket DESC
            ) FILTER (WHERE daily.views IS NOT NULL),
            '[]'::jsonb
        ) as daily_stats
    FROM content_impressions ci
    LEFT JOIN LATERAL (
        SELECT
            date_bucket as d,
            COUNT(*)::INT as views,
            COUNT(DISTINCT COALESCE(viewer_user_id::text, viewer_session_id))::INT as unique_views
        FROM content_impressions ci2
        WHERE ci2.entity_type = p_entity_type
        AND ci2.entity_id = ci.entity_id
        AND ci2.date_bucket >= CURRENT_DATE - (p_days || ' days')::INTERVAL
        GROUP BY date_bucket
    ) daily ON daily.d = ci.date_bucket
    WHERE ci.entity_type = p_entity_type
    AND ci.entity_id = ANY(p_entity_ids)
    AND ci.date_bucket >= CURRENT_DATE - (p_days || ' days')::INTERVAL
    GROUP BY ci.entity_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- RPC: Get Trending Entities by Impressions
-- ===========================================
CREATE OR REPLACE FUNCTION get_trending_by_impressions(
    p_entity_type TEXT,
    p_limit INT DEFAULT 10,
    p_days INT DEFAULT 7
)
RETURNS TABLE (
    entity_id UUID,
    view_count BIGINT,
    growth_rate FLOAT
) AS $$
BEGIN
    RETURN QUERY
    WITH recent AS (
        SELECT
            ci.entity_id,
            COUNT(*)::BIGINT as views
        FROM content_impressions ci
        WHERE ci.entity_type = p_entity_type
        AND ci.date_bucket >= CURRENT_DATE - (p_days || ' days')::INTERVAL
        GROUP BY ci.entity_id
    ),
    previous AS (
        SELECT
            ci.entity_id,
            COUNT(*)::BIGINT as views
        FROM content_impressions ci
        WHERE ci.entity_type = p_entity_type
        AND ci.date_bucket >= CURRENT_DATE - (p_days * 2 || ' days')::INTERVAL
        AND ci.date_bucket < CURRENT_DATE - (p_days || ' days')::INTERVAL
        GROUP BY ci.entity_id
    )
    SELECT
        r.entity_id,
        r.views as view_count,
        CASE
            WHEN COALESCE(p.views, 0) = 0 THEN 100.0
            ELSE ((r.views - COALESCE(p.views, 0))::FLOAT / p.views * 100)
        END as growth_rate
    FROM recent r
    LEFT JOIN previous p ON r.entity_id = p.entity_id
    ORDER BY r.views DESC, growth_rate DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- RLS POLICIES FOR IMPRESSIONS
-- ===========================================
ALTER TABLE content_impressions ENABLE ROW LEVEL SECURITY;

-- Anyone can record impressions (including anonymous)
CREATE POLICY "Allow impression recording" ON content_impressions
    FOR INSERT
    WITH CHECK (true);

-- Only authenticated users can view impressions
CREATE POLICY "Authenticated users can view impressions" ON content_impressions
    FOR SELECT
    USING (auth.role() = 'authenticated');

-- ===========================================
-- REFRESH AGGREGATES FUNCTION
-- ===========================================
CREATE OR REPLACE FUNCTION refresh_impression_aggregates()
RETURNS VOID AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY impression_aggregates;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ===========================================
-- ADD VIEW COUNT TO COURSES IF MISSING
-- ===========================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'courses' AND column_name = 'view_count'
    ) THEN
        ALTER TABLE courses ADD COLUMN view_count INTEGER DEFAULT 0;
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name = 'posts' AND column_name = 'view_count'
    ) THEN
        ALTER TABLE posts ADD COLUMN view_count INTEGER DEFAULT 0;
    END IF;
END $$;

-- ===========================================
-- CREATE NOTIFICATION WITH DEEP LINK
-- ===========================================
CREATE OR REPLACE FUNCTION create_notification_with_target(
    p_user_id UUID,
    p_type notification_type,
    p_title TEXT,
    p_message TEXT DEFAULT NULL,
    p_entity_id UUID DEFAULT NULL,
    p_parent_id UUID DEFAULT NULL,
    p_action_type TEXT DEFAULT NULL,
    p_data JSONB DEFAULT '{}'::JSONB
)
RETURNS UUID AS $$
DECLARE
    v_notification_id UUID;
BEGIN
    INSERT INTO notifications (
        user_id,
        type,
        title,
        message,
        entity_id,
        parent_id,
        action_type,
        data
    )
    VALUES (
        p_user_id,
        p_type,
        p_title,
        p_message,
        p_entity_id,
        p_parent_id,
        p_action_type,
        p_data
    )
    RETURNING id INTO v_notification_id;

    RETURN v_notification_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
