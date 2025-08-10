-- Task(s): T001
-- This file should contain the initial SQL schema for the Cloudflare D1 database.
-- It should include CREATE TABLE statements for:
-- - UserSearches
-- - SearchResults
-- - SearchRunMetrics
-- - KanbanItems
-- - LandingPageContent
-- - Bookmarks

CREATE TABLE UserSearches (
  search_id TEXT PRIMARY KEY, -- UUID
  user_query TEXT NOT NULL,
  augmented_queries TEXT, -- JSON array of AI-generated query variations
  search_scope TEXT DEFAULT 'all', -- 'all', 'personal'
  search_depth TEXT DEFAULT 'deep', -- 'quick', 'deep', 'recurring'
  language_filters TEXT, -- JSON array of strings
  search_status TEXT DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  user_id TEXT -- For future multi-user, can be a default value or omitted if single-user
);

CREATE TABLE SearchResults (
  result_id TEXT PRIMARY KEY, -- UUID
  search_id TEXT NOT NULL, -- FK to UserSearches
  repo_full_name TEXT NOT NULL, -- e.g., "owner/repo"
  repo_id TEXT, -- GitHub's numeric repo ID, if available and useful
  repo_html_url TEXT,
  repo_description TEXT,
  ai_rationale TEXT, -- Gemini's explanation of relevance
  ai_category TEXT, -- Category assigned by AI for grouping
  stargazer_count INTEGER,
  watcher_count INTEGER,
  fork_count INTEGER,
  topics TEXT, -- JSON array of strings
  language TEXT, -- Primary language
  repo_owner_login TEXT,
  repo_owner_avatar_url TEXT,
  repo_owner_html_url TEXT,
  repo_created_at DATETIME, -- Original creation date of the repo
  repo_updated_at DATETIME, -- Last update date of the repo
  ai_score REAL, -- Score from personalized AI recommendations/ranking
  anomalies TEXT, -- JSON array of strings describing detected anomalies
  retrieved_at DATETIME DEFAULT CURRENT_TIMESTAMP, -- When this record was fetched/updated
  FOREIGN KEY (search_id) REFERENCES UserSearches(search_id)
);

CREATE TABLE SearchRunMetrics (
  metric_id TEXT PRIMARY KEY, -- UUID
  search_id TEXT NOT NULL UNIQUE, -- FK to UserSearches, one metrics entry per search
  top_developers TEXT, -- JSON array of objects: {login, avatar_url, html_url, rationale}
  top_topics TEXT, -- JSON array of objects: {topic, count}
  bottom_topics TEXT, -- JSON array of objects: {topic, count}
  top_starred_repos TEXT, -- JSON array of objects: {repo_full_name, stargazer_count}
  bottom_starred_repos TEXT, -- JSON array of objects: {repo_full_name, stargazer_count}
  top_watcher_repos TEXT, -- JSON array of objects: {repo_full_name, watcher_count}
  bottom_watcher_repos TEXT, -- JSON array of objects: {repo_full_name, watcher_count}
  top_forked_repos TEXT, -- JSON array of objects: {repo_full_name, fork_count}
  bottom_forked_repos TEXT, -- JSON array of objects: {repo_full_name, fork_count}
  language_distribution TEXT, -- JSON array of objects: {language, count}
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (search_id) REFERENCES UserSearches(search_id)
);

CREATE TABLE KanbanItems (
  item_id TEXT PRIMARY KEY, -- UUID
  user_id TEXT, -- For future multi-user
  repo_full_name TEXT, -- Nullable for manual entries not tied to a repo
  repo_html_url TEXT, -- Nullable
  item_title TEXT NOT NULL, -- Repo name or custom title
  item_notes TEXT,
  column_status TEXT DEFAULT 'Backlog', -- e.g., "Backlog", "In Progress"
  source_description TEXT, -- e.g., "From search: 'xyz'", "Manual entry"
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  sort_order INTEGER DEFAULT 0 -- For manual ordering within a column
);

CREATE TABLE LandingPageContent (
  content_id TEXT PRIMARY KEY, -- UUID
  user_id TEXT, -- For future multi-user personalization
  content_type TEXT NOT NULL, -- 'trending_repo', 'new_framework', 'article_link', 'tip'
  title TEXT NOT NULL,
  link_url TEXT,
  description TEXT,
  source_name TEXT, -- e.g., "GitHub Trending", "Agent Discovery"
  image_url TEXT, -- Optional
  ai_rationale TEXT, -- Why this is interesting
  discovered_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  expires_at DATETIME -- Optional, for auto-cleanup
);

CREATE TABLE Bookmarks (
  bookmark_id TEXT PRIMARY KEY, -- UUID
  user_id TEXT, -- For future multi-user
  repo_full_name TEXT NOT NULL,
  repo_html_url TEXT,
  bookmark_name TEXT, -- User's custom name for the bookmark, defaults to repo name
  bookmark_description TEXT, -- User's notes
  bookmark_hex_color TEXT, -- e.g., for tagging or visual distinction
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);