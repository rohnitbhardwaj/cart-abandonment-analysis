
/*
PROJECT: E-COMMERCE DATA QUALITY CHECKS
PURPOSE:
Validates data completeness and consistency across the store schema
through row counts, data previews, orphan checks, and funnel reconciliation.
*/


-- ==============================================
-- 1. WEBSITE SESSIONS
-- ==============================================

-- Check total session records.
SELECT COUNT(*) FROM store.website_sessions;

-- Preview session data.
SELECT TOP 10 * FROM store.website_sessions;


-- ==============================================
-- 2. WEBSITE PAGEVIEWS
-- ==============================================

-- Check total pageview records.
SELECT COUNT(*) FROM store.website_pageviews;

-- Preview pageview data.
SELECT TOP 10 * FROM store.website_pageviews;

-- Identify the most viewed pages.
SELECT pageview_url, COUNT(*)
FROM store.website_pageviews
GROUP BY pageview_url
ORDER BY 2 DESC;

-- Check for pageviews without a matching session.
SELECT COUNT(*)
FROM store.website_pageviews p
LEFT JOIN store.website_sessions s
    ON p.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;


-- ==============================================
-- 3. ORDERS
-- ==============================================

-- Check total order records.
SELECT COUNT(*) FROM store.orders;

-- Preview order data.
SELECT TOP 10 * FROM store.orders;

-- Check for orders without a matching session.
SELECT COUNT(*)
FROM store.orders p
LEFT JOIN store.website_sessions s
    ON p.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;


-- ==============================================
-- 4. SESSION FUNNEL RECONCILIATION
-- ==============================================

-- Check funnel records against total website sessions.
SELECT COUNT(*) FROM store.session_funnel;

-- Compare completed orders with source order records.
SELECT SUM(completed_order) FROM store.session_funnel;
SELECT COUNT(*) FROM store.orders;

-- Check total cart sessions and abandoned carts.
SELECT
    SUM(reached_cart) AS cart_sessions,
    SUM(CASE WHEN reached_cart = 1 AND completed_order = 0
             THEN 1 ELSE 0 END) AS abandoned
FROM store.session_funnel;
