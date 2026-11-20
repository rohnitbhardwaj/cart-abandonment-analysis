/*
PROJECT: SESSION FUNNEL SUMMARY TABLE
PURPOSE:
Creates store.session_funnel with one row per session,
including funnel-stage flags, landing pages, and the last
product page viewed before reaching the cart.
*/

-- ==============================================
-- 1. FUNNEL STAGE FLAGS
-- ==============================================

-- Identify whether each session reached each funnel stage.
WITH pv AS (
    SELECT
        website_session_id,
        MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS reached_products,
        MAX(CASE WHEN pageview_url LIKE '/the-%' THEN 1 ELSE 0 END) AS reached_product_page,
        MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS reached_cart,
        MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS reached_shipping,
        MAX(CASE WHEN pageview_url IN ('/billing','/billing-2') THEN 1 ELSE 0 END) AS reached_billing,
        MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS completed_order,

        -- Capture the first cart pageview for product-page analysis.
        MIN(CASE WHEN pageview_url = '/cart' THEN website_pageview_id END) AS first_cart_pv_id

    FROM store.website_pageviews
    GROUP BY website_session_id
),

-- ==============================================
-- 2. LANDING PAGE IDENTIFICATION
-- ==============================================

-- Identify the first page viewed in each session.
landing AS (
    SELECT
        website_session_id,
        landing_page
    FROM (
        SELECT
            website_session_id,
            pageview_url AS landing_page,
            ROW_NUMBER() OVER (
                PARTITION BY website_session_id
                ORDER BY website_pageview_id
            ) AS rn
        FROM store.website_pageviews
    ) t
    WHERE rn = 1
)

-- ==============================================
-- 3. BUILD SESSION FUNNEL TABLE
-- ==============================================

-- Combine session details with funnel and landing-page data.
SELECT
    s.website_session_id,
    s.created_at,
    s.is_repeat_session,
    s.device_type,
    s.utm_source,
    s.utm_campaign,
    l.landing_page,
    pv.reached_products,
    pv.reached_product_page,
    pv.reached_cart,
    pv.reached_shipping,
    pv.reached_billing,
    pv.completed_order,
    prod.product_page AS product_before_cart

INTO store.session_funnel

FROM store.website_sessions AS s

LEFT JOIN landing AS l
    ON s.website_session_id = l.website_session_id

LEFT JOIN pv
    ON s.website_session_id = pv.website_session_id

-- Find the last product page viewed before the first cart visit.
OUTER APPLY (
    SELECT TOP 1
        p2.pageview_url AS product_page
    FROM store.website_pageviews p2
    WHERE p2.website_session_id = s.website_session_id
        AND p2.pageview_url LIKE '/the-%'
        AND p2.website_pageview_id < pv.first_cart_pv_id
    ORDER BY p2.website_pageview_id DESC
) prod;