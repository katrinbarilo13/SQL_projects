USE mavenfuzzyfactory; 

-- This mini project was designed to showcase business intelligence analysis based on a fictional dataset 
-- This project focuses on more business related situations and advanced SQL techniques
-- Its based on e-commerce products and website analytics 


-- 1/ based on quarterly trends, show overall website sessions and orders
SELECT
YEAR(website_sessions.created_at), 
quarter(website_sessions.created_at),
COUNT(website_sessions.website_session_id) AS overall_sessions, 
COUNT(orders.order_id) AS overall_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.order_id
GROUP BY 1,2
ORDER BY 1,2; 

-- 2/ based on quarterly trends, session to order conversion rates, revenue per order, revenue per session
SELECT
YEAR(website_sessions.created_at), 
QUARTER(website_sessions.created_at),
COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id) AS crv_rates, 
SUM(price_usd)/COUNT(DISTINCT orders.order_id) AS rev_per_order,
SUM(price_usd)/COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.order_id
GROUP BY YEAR(website_sessions.created_at), quarter(website_sessions.created_at)
ORDER BY 1,2;

-- 3/ based on quarterly trends, and different searches and brands based on orders
SELECT utm_source, utm_campaign, http_referer FROM website_sessions GROUP BY 1, 2, 3; 

SELECT
YEAR(website_sessions.created_at), 
quarter(website_sessions.created_at),
COUNT(distinct CASE WHEN website_sessions.utm_source = 'gsearch'AND website_sessions.utm_campaign = 'nonbrand'THEN orders.order_id ELSE NULL END) AS gnon_orders,
COUNT(distinct CASE WHEN website_sessions.utm_source = 'bsearch'AND website_sessions.utm_campaign = 'nonbrand'THEN orders.order_id ELSE NULL END) AS bnon_orders,
COUNT(distinct CASE WHEN website_sessions.utm_source IS NULL  AND website_sessions.http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS orgsearch_orders,
COUNT(distinct CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_orders,
COUNT(distinct CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN orders.order_id ELSE NULL END) AS dirtype_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.order_id
GROUP BY YEAR(website_sessions.created_at), quarter(website_sessions.created_at);

-- 4/ based on quarterly trends provide order sessions conversion rates based on previous query
SELECT
YEAR(website_sessions.created_at), 
quarter(website_sessions.created_at),
COUNT(distinct CASE WHEN website_sessions.utm_source = 'gsearch'AND website_sessions.utm_campaign = 'nonbrand'THEN orders.order_id ELSE NULL END)/
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'gsearch'AND website_sessions.utm_campaign = 'nonbrand'THEN website_sessions.website_session_id ELSE NULL END) AS gnon_orders,
COUNT(distinct CASE WHEN website_sessions.utm_source = 'bsearch'AND website_sessions.utm_campaign = 'nonbrand'THEN orders.order_id ELSE NULL END) / 
COUNT(DISTINCT CASE WHEN website_sessions.utm_source = 'bsearch'AND website_sessions.utm_campaign = 'nonbrand'THEN website_sessions.website_session_id ELSE NULL END) AS bnon_orders,
COUNT(distinct CASE WHEN website_sessions.utm_source IS NULL  AND website_sessions.http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) /
COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END)
AS orgsearch_orders,
COUNT(distinct CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)/ 
COUNT(DISTINCT CASE WHEN website_sessions.utm_campaign = 'brand'THEN website_sessions.website_session_id ELSE NULL END) AS brand_orders,
COUNT(distinct CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN orders.order_id ELSE NULL END) / 
COUNT(DISTINCT CASE WHEN website_sessions.utm_source IS NULL AND website_sessions.http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END)AS dirtype_orders
FROM website_sessions
LEFT JOIN orders
	ON website_sessions.website_session_id = orders.order_id
GROUP BY 1, 2; 

-- 5/ monthly trends on revenue, margin by product, total sales + revenue

SELECT
YEAR(created_at), 
MONTH(created_at), 
SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg,
SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
SUM(price_usd - cogs_usd) AS total_marg,
COUNT(order_id) AS total_sales, 
SUM(price_usd) AS total_rev
FROM order_items
GROUP BY 1,2
ORDER BY 1,2; 

-- 6/ monthly trend of sessions for products page, clickthrough rates
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id, 
    website_pageview_id, 
    created_at AS saw_product_page_at

FROM website_pageviews 
WHERE pageview_url = '/products';


SELECT 
	YEAR(saw_product_page_at) AS yr, 
    MONTH(saw_product_page_at) AS mo,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_of_product_page, 
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page, 
    COUNT(DISTINCT website_pageviews.website_session_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS clickthru_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
	LEFT JOIN website_pageviews 
		ON website_pageviews.website_session_id = products_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id 
	LEFT JOIN orders 
		ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2;














