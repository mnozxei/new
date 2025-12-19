-- Migration: 008_search_indexes.sql
-- Description: Add full-text search capability across all searchable entities

-- Add full-text search vectors to tables
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
CREATE INDEX IF NOT EXISTS idx_profiles_search ON profiles USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_courses_search ON courses USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_jobs_search ON jobs USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_companies_search ON companies USING GIN(search_vector);
CREATE INDEX IF NOT EXISTS idx_posts_search ON posts USING GIN(search_vector);

-- Function to update profile search vector
CREATE OR REPLACE FUNCTION update_profile_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('simple', COALESCE(NEW.full_name, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.headline, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.bio, '')), 'C') ||
    setweight(to_tsvector('simple', COALESCE(NEW.location, '')), 'D');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update course search vector
CREATE OR REPLACE FUNCTION update_course_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('simple', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.short_description, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.description, '')), 'C') ||
    setweight(to_tsvector('simple', COALESCE(NEW.category, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(array_to_string(NEW.tags, ' '), '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update job search vector
CREATE OR REPLACE FUNCTION update_job_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('simple', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.requirements, '')), 'C') ||
    setweight(to_tsvector('simple', COALESCE(NEW.location, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(array_to_string(NEW.skills, ' '), '')), 'B');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update company search vector
CREATE OR REPLACE FUNCTION update_company_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('simple', COALESCE(NEW.name, '')), 'A') ||
    setweight(to_tsvector('simple', COALESCE(NEW.description, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.industry, '')), 'B') ||
    setweight(to_tsvector('simple', COALESCE(NEW.city, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update post search vector
CREATE OR REPLACE FUNCTION update_post_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector :=
    setweight(to_tsvector('simple', COALESCE(NEW.content, '')), 'A');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers for search vector updates
DROP TRIGGER IF EXISTS trigger_update_profile_search ON profiles;
CREATE TRIGGER trigger_update_profile_search
  BEFORE INSERT OR UPDATE OF full_name, headline, bio, location ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_profile_search_vector();

DROP TRIGGER IF EXISTS trigger_update_course_search ON courses;
CREATE TRIGGER trigger_update_course_search
  BEFORE INSERT OR UPDATE OF title, description, short_description, category, tags ON courses
  FOR EACH ROW EXECUTE FUNCTION update_course_search_vector();

DROP TRIGGER IF EXISTS trigger_update_job_search ON jobs;
CREATE TRIGGER trigger_update_job_search
  BEFORE INSERT OR UPDATE OF title, description, requirements, location, skills ON jobs
  FOR EACH ROW EXECUTE FUNCTION update_job_search_vector();

DROP TRIGGER IF EXISTS trigger_update_company_search ON companies;
CREATE TRIGGER trigger_update_company_search
  BEFORE INSERT OR UPDATE OF name, description, industry, city ON companies
  FOR EACH ROW EXECUTE FUNCTION update_company_search_vector();

DROP TRIGGER IF EXISTS trigger_update_post_search ON posts;
CREATE TRIGGER trigger_update_post_search
  BEFORE INSERT OR UPDATE OF content ON posts
  FOR EACH ROW EXECUTE FUNCTION update_post_search_vector();

-- Update existing records to populate search vectors
UPDATE profiles SET search_vector =
  setweight(to_tsvector('simple', COALESCE(full_name, '')), 'A') ||
  setweight(to_tsvector('simple', COALESCE(headline, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(bio, '')), 'C') ||
  setweight(to_tsvector('simple', COALESCE(location, '')), 'D');

UPDATE courses SET search_vector =
  setweight(to_tsvector('simple', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('simple', COALESCE(short_description, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(description, '')), 'C') ||
  setweight(to_tsvector('simple', COALESCE(category, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(array_to_string(tags, ' '), '')), 'C');

UPDATE jobs SET search_vector =
  setweight(to_tsvector('simple', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('simple', COALESCE(description, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(requirements, '')), 'C') ||
  setweight(to_tsvector('simple', COALESCE(location, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(array_to_string(skills, ' '), '')), 'B');

UPDATE companies SET search_vector =
  setweight(to_tsvector('simple', COALESCE(name, '')), 'A') ||
  setweight(to_tsvector('simple', COALESCE(description, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(industry, '')), 'B') ||
  setweight(to_tsvector('simple', COALESCE(city, '')), 'C');

UPDATE posts SET search_vector =
  setweight(to_tsvector('simple', COALESCE(content, '')), 'A');

-- Unified search function
CREATE OR REPLACE FUNCTION search_all(
  p_query TEXT,
  p_types TEXT[] DEFAULT ARRAY['profile', 'course', 'job', 'company', 'post'],
  p_limit INTEGER DEFAULT 10,
  p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
  result_type TEXT,
  result_id UUID,
  title TEXT,
  subtitle TEXT,
  image_url TEXT,
  rank REAL,
  created_at TIMESTAMPTZ
) AS $$
DECLARE
  v_tsquery tsquery;
BEGIN
  -- Convert query to tsquery with prefix matching
  v_tsquery := to_tsquery('simple', regexp_replace(p_query, '\s+', ':* & ', 'g') || ':*');

  RETURN QUERY

  -- Profiles
  SELECT
    'profile'::TEXT,
    p.id,
    p.full_name,
    p.headline,
    p.avatar_url,
    ts_rank(p.search_vector, v_tsquery),
    p.created_at
  FROM profiles p
  WHERE 'profile' = ANY(p_types)
    AND p.search_vector @@ v_tsquery

  UNION ALL

  -- Courses (only published)
  SELECT
    'course'::TEXT,
    c.id,
    c.title,
    c.short_description,
    c.thumbnail_url,
    ts_rank(c.search_vector, v_tsquery),
    c.created_at
  FROM courses c
  WHERE 'course' = ANY(p_types)
    AND c.is_published = TRUE
    AND c.search_vector @@ v_tsquery

  UNION ALL

  -- Jobs (only active)
  SELECT
    'job'::TEXT,
    j.id,
    j.title,
    j.location,
    NULL,
    ts_rank(j.search_vector, v_tsquery),
    j.created_at
  FROM jobs j
  WHERE 'job' = ANY(p_types)
    AND j.is_active = TRUE
    AND j.search_vector @@ v_tsquery

  UNION ALL

  -- Companies
  SELECT
    'company'::TEXT,
    co.id,
    co.name,
    co.industry,
    co.logo_url,
    ts_rank(co.search_vector, v_tsquery),
    co.created_at
  FROM companies co
  WHERE 'company' = ANY(p_types)
    AND co.search_vector @@ v_tsquery

  UNION ALL

  -- Posts
  SELECT
    'post'::TEXT,
    po.id,
    LEFT(po.content, 100),
    NULL,
    NULL,
    ts_rank(po.search_vector, v_tsquery),
    po.created_at
  FROM posts po
  WHERE 'post' = ANY(p_types)
    AND po.search_vector @@ v_tsquery

  ORDER BY rank DESC, created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql;

-- Search suggestions function
CREATE OR REPLACE FUNCTION search_suggestions(
  p_query TEXT,
  p_limit INTEGER DEFAULT 5
)
RETURNS TABLE (
  suggestion TEXT,
  result_type TEXT,
  result_count BIGINT
) AS $$
DECLARE
  v_tsquery tsquery;
BEGIN
  v_tsquery := to_tsquery('simple', regexp_replace(p_query, '\s+', ':* & ', 'g') || ':*');

  RETURN QUERY

  SELECT DISTINCT ON (s.suggestion)
    s.suggestion,
    s.result_type,
    s.result_count
  FROM (
    -- Profile names
    SELECT
      p.full_name AS suggestion,
      'profile' AS result_type,
      COUNT(*) OVER () AS result_count
    FROM profiles p
    WHERE p.search_vector @@ v_tsquery
    ORDER BY ts_rank(p.search_vector, v_tsquery) DESC
    LIMIT 3

    UNION ALL

    -- Course titles
    SELECT
      c.title,
      'course',
      COUNT(*) OVER ()
    FROM courses c
    WHERE c.is_published = TRUE AND c.search_vector @@ v_tsquery
    ORDER BY ts_rank(c.search_vector, v_tsquery) DESC
    LIMIT 3

    UNION ALL

    -- Job titles
    SELECT
      j.title,
      'job',
      COUNT(*) OVER ()
    FROM jobs j
    WHERE j.is_active = TRUE AND j.search_vector @@ v_tsquery
    ORDER BY ts_rank(j.search_vector, v_tsquery) DESC
    LIMIT 3

    UNION ALL

    -- Company names
    SELECT
      co.name,
      'company',
      COUNT(*) OVER ()
    FROM companies co
    WHERE co.search_vector @@ v_tsquery
    ORDER BY ts_rank(co.search_vector, v_tsquery) DESC
    LIMIT 3
  ) s
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Recent searches table
CREATE TABLE IF NOT EXISTS search_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  query TEXT NOT NULL,
  result_type TEXT,
  result_id UUID,
  searched_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_search_history_user ON search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_search_history_searched ON search_history(searched_at);

-- RLS for search history
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can manage own search history" ON search_history;
CREATE POLICY "Users can manage own search history"
  ON search_history FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Function to get recent searches
CREATE OR REPLACE FUNCTION get_recent_searches(p_limit INTEGER DEFAULT 10)
RETURNS TABLE (
  query TEXT,
  searched_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT DISTINCT ON (sh.query)
    sh.query,
    sh.searched_at
  FROM search_history sh
  WHERE sh.user_id = auth.uid()
  ORDER BY sh.query, sh.searched_at DESC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clear search history
CREATE OR REPLACE FUNCTION clear_search_history()
RETURNS void AS $$
BEGIN
  DELETE FROM search_history WHERE user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
