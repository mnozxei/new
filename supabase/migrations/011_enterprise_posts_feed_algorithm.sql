-- ============================================
-- TAMAD HUB Enterprise Posts System
-- NO-LINKS Enforcement + Professional Feed Algorithm
-- ============================================

-- ============================================
-- 1. NO-LINKS ENFORCEMENT
-- ============================================

-- Function to detect URLs in text
CREATE OR REPLACE FUNCTION contains_url(text_content TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Detect common URL patterns
    RETURN text_content ~* '(https?://|www\.|[a-z0-9]+(\.com|\.org|\.net|\.io|\.sa|\.ae|\.eg|\.kw|\.qa|\.bh|\.om|\.jo|\.lb|\.ly|\.tn|\.ma|\.dz|\.sd|\.ye|\.sy|\.iq|\.ps|\.edu|\.gov|\.co|\.me|\.tv|\.info|\.biz|\.app|\.dev|\.cloud)[/\s\b]?)';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Trigger function to reject posts with URLs
CREATE OR REPLACE FUNCTION enforce_no_links_in_posts()
RETURNS TRIGGER AS $$
BEGIN
    IF contains_url(NEW.content) THEN
        RAISE EXCEPTION 'الروابط غير مسموح بها في المنشورات. يرجى إزالة أي روابط من المحتوى.';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger on posts table
DROP TRIGGER IF EXISTS tr_enforce_no_links ON posts;
CREATE TRIGGER tr_enforce_no_links
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION enforce_no_links_in_posts();

-- ============================================
-- 2. FEED ALGORITHM TABLES
-- ============================================

-- Post statistics (materialized for performance)
CREATE TABLE IF NOT EXISTS post_stats (
    post_id UUID PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    impressions_count INTEGER DEFAULT 0,
    saves_count INTEGER DEFAULT 0,
    engagement_rate DECIMAL(8,6) DEFAULT 0,
    quality_score DECIMAL(5,3) DEFAULT 0,
    trending_score DECIMAL(8,4) DEFAULT 0,
    last_engagement_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User follows (users and companies)
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    followed_type TEXT NOT NULL CHECK (followed_type IN ('user', 'company')),
    followed_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(follower_id, followed_type, followed_id)
);

-- User feed preferences
CREATE TABLE IF NOT EXISTS user_feed_prefs (
    user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    industry TEXT,
    interests TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    preferred_languages TEXT[] DEFAULT ARRAY['ar'],
    muted_words TEXT[] DEFAULT '{}',
    hide_reposts BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Feed seen tracking (for avoiding duplicates)
CREATE TABLE IF NOT EXISTS feed_seen (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    seen_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    interaction_type TEXT, -- 'view', 'scroll', 'click', 'engage'
    UNIQUE(user_id, post_id)
);

-- User blocks
CREATE TABLE IF NOT EXISTS user_blocks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocker_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    blocked_type TEXT NOT NULL CHECK (blocked_type IN ('user', 'company')),
    blocked_id UUID NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(blocker_id, blocked_type, blocked_id)
);

-- User mutes (softer than blocks)
CREATE TABLE IF NOT EXISTS user_mutes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    muter_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    muted_type TEXT NOT NULL CHECK (muted_type IN ('user', 'company')),
    muted_id UUID NOT NULL,
    mute_until TIMESTAMPTZ, -- NULL = permanent
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(muter_id, muted_type, muted_id)
);

-- Post bookmarks/saves
CREATE TABLE IF NOT EXISTS post_bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(user_id, post_id)
);

-- Post reports
CREATE TABLE IF NOT EXISTS post_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID REFERENCES posts(id) ON DELETE CASCADE NOT NULL,
    reporter_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'actioned', 'dismissed')),
    reviewed_by UUID REFERENCES profiles(id),
    reviewed_at TIMESTAMPTZ,
    action_taken TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE(post_id, reporter_id)
);

-- Add moderation_status to posts if not exists
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'posts' AND column_name = 'moderation_status') THEN
        ALTER TABLE posts ADD COLUMN moderation_status TEXT DEFAULT 'approved' CHECK (moderation_status IN ('pending', 'approved', 'rejected', 'flagged'));
    END IF;
END$$;

-- ============================================
-- 3. INDEXES FOR FEED PERFORMANCE
-- ============================================

CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_followed ON follows(followed_type, followed_id);
CREATE INDEX IF NOT EXISTS idx_feed_seen_user ON feed_seen(user_id, seen_at DESC);
CREATE INDEX IF NOT EXISTS idx_feed_seen_post ON feed_seen(post_id);
CREATE INDEX IF NOT EXISTS idx_post_stats_trending ON post_stats(trending_score DESC);
CREATE INDEX IF NOT EXISTS idx_post_stats_engagement ON post_stats(engagement_rate DESC);
CREATE INDEX IF NOT EXISTS idx_user_blocks_blocker ON user_blocks(blocker_id);
CREATE INDEX IF NOT EXISTS idx_user_mutes_muter ON user_mutes(muter_id);
CREATE INDEX IF NOT EXISTS idx_post_bookmarks_user ON post_bookmarks(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_moderation ON posts(moderation_status) WHERE moderation_status != 'approved';

-- ============================================
-- 4. TRIGGER TO SYNC POST STATS
-- ============================================

-- Initialize post_stats when post created
CREATE OR REPLACE FUNCTION init_post_stats()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO post_stats (post_id) VALUES (NEW.id) ON CONFLICT DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_init_post_stats ON posts;
CREATE TRIGGER tr_init_post_stats
    AFTER INSERT ON posts
    FOR EACH ROW
    EXECUTE FUNCTION init_post_stats();

-- Update post_stats on engagement
CREATE OR REPLACE FUNCTION update_post_stats()
RETURNS TRIGGER AS $$
DECLARE
    v_post_id UUID;
    v_likes INT;
    v_comments INT;
    v_shares INT;
    v_impressions INT;
    v_saves INT;
    v_engagement DECIMAL;
BEGIN
    -- Determine post_id based on table
    IF TG_TABLE_NAME = 'post_likes' THEN
        v_post_id := COALESCE(NEW.post_id, OLD.post_id);
    ELSIF TG_TABLE_NAME = 'post_comments' THEN
        v_post_id := COALESCE(NEW.post_id, OLD.post_id);
    ELSIF TG_TABLE_NAME = 'post_bookmarks' THEN
        v_post_id := COALESCE(NEW.post_id, OLD.post_id);
    END IF;

    -- Get counts
    SELECT COUNT(*) INTO v_likes FROM post_likes WHERE post_id = v_post_id;
    SELECT COUNT(*) INTO v_comments FROM post_comments WHERE post_id = v_post_id;
    SELECT COALESCE(share_count, 0) INTO v_shares FROM posts WHERE id = v_post_id;
    SELECT COUNT(*) INTO v_impressions FROM feed_seen WHERE post_id = v_post_id;
    SELECT COUNT(*) INTO v_saves FROM post_bookmarks WHERE post_id = v_post_id;

    -- Calculate engagement rate
    v_engagement := CASE
        WHEN v_impressions > 0 THEN
            (v_likes::DECIMAL + (v_comments * 2) + (v_shares * 3) + (v_saves * 2)) / v_impressions
        ELSE 0
    END;

    -- Upsert stats
    INSERT INTO post_stats (post_id, likes_count, comments_count, shares_count, impressions_count, saves_count, engagement_rate, last_engagement_at, updated_at)
    VALUES (v_post_id, v_likes, v_comments, v_shares, v_impressions, v_saves, v_engagement, NOW(), NOW())
    ON CONFLICT (post_id) DO UPDATE SET
        likes_count = EXCLUDED.likes_count,
        comments_count = EXCLUDED.comments_count,
        shares_count = EXCLUDED.shares_count,
        impressions_count = EXCLUDED.impressions_count,
        saves_count = EXCLUDED.saves_count,
        engagement_rate = EXCLUDED.engagement_rate,
        last_engagement_at = EXCLUDED.last_engagement_at,
        updated_at = NOW();

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_update_stats_likes ON post_likes;
CREATE TRIGGER tr_update_stats_likes
    AFTER INSERT OR DELETE ON post_likes
    FOR EACH ROW
    EXECUTE FUNCTION update_post_stats();

DROP TRIGGER IF EXISTS tr_update_stats_comments ON post_comments;
CREATE TRIGGER tr_update_stats_comments
    AFTER INSERT OR DELETE ON post_comments
    FOR EACH ROW
    EXECUTE FUNCTION update_post_stats();

DROP TRIGGER IF EXISTS tr_update_stats_saves ON post_bookmarks;
CREATE TRIGGER tr_update_stats_saves
    AFTER INSERT OR DELETE ON post_bookmarks
    FOR EACH ROW
    EXECUTE FUNCTION update_post_stats();

-- ============================================
-- 5. FEED ALGORITHM RPC FUNCTION
-- ============================================

CREATE OR REPLACE FUNCTION get_personalized_feed(
    p_user_id UUID DEFAULT NULL,
    p_limit INT DEFAULT 20,
    p_cursor TIMESTAMPTZ DEFAULT NULL,
    p_debug BOOLEAN DEFAULT FALSE
)
RETURNS TABLE (
    post_id UUID,
    content TEXT,
    media_urls TEXT[],
    media_types TEXT[],
    author_id UUID,
    author_name TEXT,
    author_avatar TEXT,
    author_verified BOOLEAN,
    company_id UUID,
    company_name TEXT,
    company_logo TEXT,
    company_verified BOOLEAN,
    likes_count INT,
    comments_count INT,
    shares_count INT,
    is_liked BOOLEAN,
    is_saved BOOLEAN,
    created_at TIMESTAMPTZ,
    feed_source TEXT,
    score DECIMAL,
    score_breakdown JSONB
) AS $$
DECLARE
    v_following_limit INT;
    v_relevance_limit INT;
    v_discover_limit INT;
    v_decay_hours DECIMAL := 36.0;
BEGIN
    -- Calculate limits based on percentages
    IF p_user_id IS NOT NULL THEN
        v_following_limit := CEIL(p_limit * 0.60);
        v_relevance_limit := CEIL(p_limit * 0.30);
        v_discover_limit := CEIL(p_limit * 0.10);
    ELSE
        -- Visitor: only discover
        v_following_limit := 0;
        v_relevance_limit := 0;
        v_discover_limit := p_limit;
    END IF;

    RETURN QUERY
    WITH
    -- Get user's follows
    user_follows AS (
        SELECT followed_id, followed_type
        FROM follows
        WHERE follower_id = p_user_id
    ),
    -- Get user's blocks/mutes
    blocked_entities AS (
        SELECT blocked_id, blocked_type FROM user_blocks WHERE blocker_id = p_user_id
        UNION ALL
        SELECT muted_id, muted_type FROM user_mutes WHERE muter_id = p_user_id AND (mute_until IS NULL OR mute_until > NOW())
    ),
    -- Get recently seen posts (last 7 days)
    recently_seen AS (
        SELECT post_id FROM feed_seen
        WHERE user_id = p_user_id AND seen_at > NOW() - INTERVAL '7 days'
    ),
    -- Get user preferences
    user_prefs AS (
        SELECT industry, interests, tags FROM user_feed_prefs WHERE user_id = p_user_id
    ),
    -- Following channel (60%)
    following_posts AS (
        SELECT
            p.id,
            p.content,
            p.media_urls,
            p.media_types,
            p.author_id,
            pr.full_name AS author_name,
            pr.avatar_url AS author_avatar,
            pr.is_verified AS author_verified,
            p.company_id,
            c.name AS company_name,
            c.logo_url AS company_logo,
            (c.status = 'verified') AS company_verified,
            COALESCE(ps.likes_count, 0) AS likes_count,
            COALESCE(ps.comments_count, 0) AS comments_count,
            COALESCE(ps.shares_count, 0) AS shares_count,
            EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = p_user_id) AS is_liked,
            EXISTS(SELECT 1 FROM post_bookmarks pb WHERE pb.post_id = p.id AND pb.user_id = p_user_id) AS is_saved,
            p.created_at,
            'following'::TEXT AS feed_source,
            -- Score calculation
            (
                -- Freshness decay: exp(-age_hours / H)
                EXP(-EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 / v_decay_hours) * 40 +
                -- Engagement rate boost
                COALESCE(ps.engagement_rate, 0) * 100 * 30 +
                -- Relationship boost (following = +20)
                20 +
                -- Author quality (verified = +10)
                CASE WHEN pr.is_verified OR c.status = 'verified' THEN 10 ELSE 0 END
            ) AS score,
            CASE WHEN p_debug THEN
                jsonb_build_object(
                    'freshness', EXP(-EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 / v_decay_hours) * 40,
                    'engagement', COALESCE(ps.engagement_rate, 0) * 100 * 30,
                    'relationship', 20,
                    'author_quality', CASE WHEN pr.is_verified OR c.status = 'verified' THEN 10 ELSE 0 END
                )
            ELSE NULL END AS score_breakdown
        FROM posts p
        LEFT JOIN profiles pr ON p.author_id = pr.id
        LEFT JOIN companies c ON p.company_id = c.id
        LEFT JOIN post_stats ps ON ps.post_id = p.id
        WHERE p.visibility = 'public'
            AND COALESCE(p.moderation_status, 'approved') = 'approved'
            AND (p_cursor IS NULL OR p.created_at < p_cursor)
            -- From followed users or companies
            AND (
                (p.author_id IN (SELECT followed_id FROM user_follows WHERE followed_type = 'user'))
                OR (p.company_id IN (SELECT followed_id FROM user_follows WHERE followed_type = 'company'))
            )
            -- Not blocked
            AND NOT EXISTS (
                SELECT 1 FROM blocked_entities be
                WHERE (be.blocked_type = 'user' AND be.blocked_id = p.author_id)
                   OR (be.blocked_type = 'company' AND be.blocked_id = p.company_id)
            )
            -- Not recently seen
            AND p.id NOT IN (SELECT post_id FROM recently_seen)
        ORDER BY score DESC, p.created_at DESC
        LIMIT v_following_limit
    ),
    -- Relevance channel (30%) - based on user interests/industry
    relevance_posts AS (
        SELECT
            p.id,
            p.content,
            p.media_urls,
            p.media_types,
            p.author_id,
            pr.full_name AS author_name,
            pr.avatar_url AS author_avatar,
            pr.is_verified AS author_verified,
            p.company_id,
            c.name AS company_name,
            c.logo_url AS company_logo,
            (c.status = 'verified') AS company_verified,
            COALESCE(ps.likes_count, 0) AS likes_count,
            COALESCE(ps.comments_count, 0) AS comments_count,
            COALESCE(ps.shares_count, 0) AS shares_count,
            EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = p_user_id) AS is_liked,
            EXISTS(SELECT 1 FROM post_bookmarks pb WHERE pb.post_id = p.id AND pb.user_id = p_user_id) AS is_saved,
            p.created_at,
            'relevance'::TEXT AS feed_source,
            (
                EXP(-EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 / v_decay_hours) * 35 +
                COALESCE(ps.engagement_rate, 0) * 100 * 35 +
                -- Topic match score (hashtags overlap)
                CASE WHEN p.hashtags && (SELECT COALESCE(tags, '{}') FROM user_prefs) THEN 20 ELSE 0 END +
                CASE WHEN pr.is_verified OR c.status = 'verified' THEN 10 ELSE 0 END
            ) AS score,
            CASE WHEN p_debug THEN
                jsonb_build_object(
                    'freshness', EXP(-EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 / v_decay_hours) * 35,
                    'engagement', COALESCE(ps.engagement_rate, 0) * 100 * 35,
                    'topic_match', CASE WHEN p.hashtags && (SELECT COALESCE(tags, '{}') FROM user_prefs) THEN 20 ELSE 0 END,
                    'author_quality', CASE WHEN pr.is_verified OR c.status = 'verified' THEN 10 ELSE 0 END
                )
            ELSE NULL END AS score_breakdown
        FROM posts p
        LEFT JOIN profiles pr ON p.author_id = pr.id
        LEFT JOIN companies c ON p.company_id = c.id
        LEFT JOIN post_stats ps ON ps.post_id = p.id
        WHERE p.visibility = 'public'
            AND COALESCE(p.moderation_status, 'approved') = 'approved'
            AND (p_cursor IS NULL OR p.created_at < p_cursor)
            -- Not from followed (those are in following channel)
            AND p.author_id NOT IN (SELECT followed_id FROM user_follows WHERE followed_type = 'user')
            AND (p.company_id IS NULL OR p.company_id NOT IN (SELECT followed_id FROM user_follows WHERE followed_type = 'company'))
            -- Not blocked
            AND NOT EXISTS (
                SELECT 1 FROM blocked_entities be
                WHERE (be.blocked_type = 'user' AND be.blocked_id = p.author_id)
                   OR (be.blocked_type = 'company' AND be.blocked_id = p.company_id)
            )
            AND p.id NOT IN (SELECT post_id FROM recently_seen)
            AND p.id NOT IN (SELECT id FROM following_posts)
            -- Has some relevance (verified author OR high engagement OR matching tags)
            AND (
                pr.is_verified
                OR c.status = 'verified'
                OR COALESCE(ps.engagement_rate, 0) > 0.02
                OR p.hashtags && (SELECT COALESCE(tags, '{}') FROM user_prefs)
            )
        ORDER BY score DESC, p.created_at DESC
        LIMIT v_relevance_limit
    ),
    -- Discover channel (10%) - trending/high-quality public posts
    discover_posts AS (
        SELECT
            p.id,
            p.content,
            p.media_urls,
            p.media_types,
            p.author_id,
            pr.full_name AS author_name,
            pr.avatar_url AS author_avatar,
            pr.is_verified AS author_verified,
            p.company_id,
            c.name AS company_name,
            c.logo_url AS company_logo,
            (c.status = 'verified') AS company_verified,
            COALESCE(ps.likes_count, 0) AS likes_count,
            COALESCE(ps.comments_count, 0) AS comments_count,
            COALESCE(ps.shares_count, 0) AS shares_count,
            CASE WHEN p_user_id IS NOT NULL THEN
                EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = p_user_id)
            ELSE FALSE END AS is_liked,
            CASE WHEN p_user_id IS NOT NULL THEN
                EXISTS(SELECT 1 FROM post_bookmarks pb WHERE pb.post_id = p.id AND pb.user_id = p_user_id)
            ELSE FALSE END AS is_saved,
            p.created_at,
            'discover'::TEXT AS feed_source,
            (
                EXP(-EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 / v_decay_hours) * 30 +
                COALESCE(ps.engagement_rate, 0) * 100 * 40 +
                CASE WHEN pr.is_verified OR c.status = 'verified' THEN 20 ELSE 0 END +
                -- Trending bonus (recent high engagement)
                CASE WHEN ps.last_engagement_at > NOW() - INTERVAL '6 hours' AND ps.likes_count > 10 THEN 10 ELSE 0 END
            ) AS score,
            CASE WHEN p_debug THEN
                jsonb_build_object(
                    'freshness', EXP(-EXTRACT(EPOCH FROM (NOW() - p.created_at)) / 3600 / v_decay_hours) * 30,
                    'engagement', COALESCE(ps.engagement_rate, 0) * 100 * 40,
                    'author_quality', CASE WHEN pr.is_verified OR c.status = 'verified' THEN 20 ELSE 0 END,
                    'trending', CASE WHEN ps.last_engagement_at > NOW() - INTERVAL '6 hours' AND ps.likes_count > 10 THEN 10 ELSE 0 END
                )
            ELSE NULL END AS score_breakdown
        FROM posts p
        LEFT JOIN profiles pr ON p.author_id = pr.id
        LEFT JOIN companies c ON p.company_id = c.id
        LEFT JOIN post_stats ps ON ps.post_id = p.id
        WHERE p.visibility = 'public'
            AND COALESCE(p.moderation_status, 'approved') = 'approved'
            AND (p_cursor IS NULL OR p.created_at < p_cursor)
            -- Not blocked (if user exists)
            AND (p_user_id IS NULL OR NOT EXISTS (
                SELECT 1 FROM blocked_entities be
                WHERE (be.blocked_type = 'user' AND be.blocked_id = p.author_id)
                   OR (be.blocked_type = 'company' AND be.blocked_id = p.company_id)
            ))
            -- Not recently seen (if user exists)
            AND (p_user_id IS NULL OR p.id NOT IN (SELECT post_id FROM recently_seen))
            AND p.id NOT IN (SELECT id FROM following_posts)
            AND p.id NOT IN (SELECT id FROM relevance_posts)
            -- Quality filter: verified authors OR engagement
            AND (
                pr.is_verified
                OR c.status = 'verified'
                OR COALESCE(ps.likes_count, 0) >= 5
                OR COALESCE(ps.engagement_rate, 0) > 0.01
            )
        ORDER BY score DESC, p.created_at DESC
        LIMIT v_discover_limit
    ),
    -- Combine all channels with anti-spam (max 2 per author in page)
    combined_feed AS (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY author_id ORDER BY score DESC) AS author_rank
        FROM (
            SELECT * FROM following_posts
            UNION ALL
            SELECT * FROM relevance_posts
            UNION ALL
            SELECT * FROM discover_posts
        ) all_posts
    )
    SELECT
        id AS post_id,
        content,
        media_urls,
        media_types,
        author_id,
        author_name,
        author_avatar,
        author_verified,
        company_id,
        company_name,
        company_logo,
        company_verified,
        likes_count,
        comments_count,
        shares_count,
        is_liked,
        is_saved,
        created_at,
        feed_source,
        score,
        score_breakdown
    FROM combined_feed
    WHERE author_rank <= 2  -- Max 2 posts per author per page
    ORDER BY score DESC, created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6. HELPER FUNCTIONS
-- ============================================

-- Record impression when post is viewed
CREATE OR REPLACE FUNCTION record_post_impression(
    p_user_id UUID,
    p_post_id UUID,
    p_interaction_type TEXT DEFAULT 'view'
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO feed_seen (user_id, post_id, interaction_type, seen_at)
    VALUES (p_user_id, p_post_id, p_interaction_type, NOW())
    ON CONFLICT (user_id, post_id) DO UPDATE SET
        interaction_type = CASE
            WHEN feed_seen.interaction_type = 'view' AND p_interaction_type IN ('click', 'engage') THEN p_interaction_type
            WHEN feed_seen.interaction_type = 'click' AND p_interaction_type = 'engage' THEN p_interaction_type
            ELSE feed_seen.interaction_type
        END,
        seen_at = NOW();

    -- Update impression count in post_stats
    UPDATE post_stats SET
        impressions_count = impressions_count + 1,
        updated_at = NOW()
    WHERE post_id = p_post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Toggle bookmark
CREATE OR REPLACE FUNCTION toggle_post_bookmark(p_user_id UUID, p_post_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    v_exists BOOLEAN;
BEGIN
    SELECT EXISTS(SELECT 1 FROM post_bookmarks WHERE user_id = p_user_id AND post_id = p_post_id) INTO v_exists;

    IF v_exists THEN
        DELETE FROM post_bookmarks WHERE user_id = p_user_id AND post_id = p_post_id;
        RETURN FALSE;
    ELSE
        INSERT INTO post_bookmarks (user_id, post_id) VALUES (p_user_id, p_post_id);
        RETURN TRUE;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get saved posts
CREATE OR REPLACE FUNCTION get_saved_posts(p_user_id UUID, p_limit INT DEFAULT 20, p_offset INT DEFAULT 0)
RETURNS TABLE (
    post_id UUID,
    content TEXT,
    media_urls TEXT[],
    author_id UUID,
    author_name TEXT,
    author_avatar TEXT,
    company_id UUID,
    company_name TEXT,
    company_logo TEXT,
    likes_count INT,
    comments_count INT,
    created_at TIMESTAMPTZ,
    saved_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.content,
        p.media_urls,
        p.author_id,
        pr.full_name,
        pr.avatar_url,
        p.company_id,
        c.name,
        c.logo_url,
        COALESCE(ps.likes_count, p.like_count, 0)::INT,
        COALESCE(ps.comments_count, p.comment_count, 0)::INT,
        p.created_at,
        pb.created_at AS saved_at
    FROM post_bookmarks pb
    JOIN posts p ON p.id = pb.post_id
    LEFT JOIN profiles pr ON p.author_id = pr.id
    LEFT JOIN companies c ON p.company_id = c.id
    LEFT JOIN post_stats ps ON ps.post_id = p.id
    WHERE pb.user_id = p_user_id
    ORDER BY pb.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Report post
CREATE OR REPLACE FUNCTION report_post(
    p_post_id UUID,
    p_reporter_id UUID,
    p_reason TEXT,
    p_details TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    v_report_id UUID;
BEGIN
    INSERT INTO post_reports (post_id, reporter_id, reason, details)
    VALUES (p_post_id, p_reporter_id, p_reason, p_details)
    RETURNING id INTO v_report_id;

    -- Flag post if multiple reports
    IF (SELECT COUNT(*) FROM post_reports WHERE post_id = p_post_id) >= 3 THEN
        UPDATE posts SET moderation_status = 'flagged' WHERE id = p_post_id;
    END IF;

    RETURN v_report_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7. RLS POLICIES
-- ============================================

ALTER TABLE post_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feed_prefs ENABLE ROW LEVEL SECURITY;
ALTER TABLE feed_seen ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_mutes ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_reports ENABLE ROW LEVEL SECURITY;

-- post_stats: public read
CREATE POLICY "Post stats are publicly readable" ON post_stats FOR SELECT USING (true);

-- follows: user manages own
CREATE POLICY "Users can view follows" ON follows FOR SELECT USING (true);
CREATE POLICY "Users manage own follows" ON follows FOR ALL USING (auth.uid() = follower_id);

-- user_feed_prefs: user manages own
CREATE POLICY "Users manage own feed prefs" ON user_feed_prefs FOR ALL USING (auth.uid() = user_id);

-- feed_seen: user manages own
CREATE POLICY "Users manage own feed seen" ON feed_seen FOR ALL USING (auth.uid() = user_id);

-- user_blocks: user manages own
CREATE POLICY "Users manage own blocks" ON user_blocks FOR ALL USING (auth.uid() = blocker_id);

-- user_mutes: user manages own
CREATE POLICY "Users manage own mutes" ON user_mutes FOR ALL USING (auth.uid() = muter_id);

-- post_bookmarks: user manages own
CREATE POLICY "Users manage own bookmarks" ON post_bookmarks FOR ALL USING (auth.uid() = user_id);

-- post_reports: users create, admins read all
CREATE POLICY "Users create own reports" ON post_reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);
CREATE POLICY "Users view own reports" ON post_reports FOR SELECT USING (auth.uid() = reporter_id);
CREATE POLICY "Admins view all reports" ON post_reports FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
CREATE POLICY "Admins update reports" ON post_reports FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);
