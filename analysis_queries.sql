-- Check missing values in important date columns (orders table)
SELECT 
    COUNT(*) AS total_orders,
    COUNT(order_purchase_timestamp) AS purchase_dates_filled,
    COUNT(order_approved_at) AS approved_dates_filled,
    COUNT(order_delivered_carrier_date) AS carrier_dates_filled,
    COUNT(order_delivered_customer_date) AS delivered_dates_filled,
    COUNT(order_estimated_delivery_date) AS estimated_dates_filled
FROM orders;
-- Check missing important IDs
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS unique_orders,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS missing_customer_id
FROM orders;
SELECT 
    COUNT(*) AS total_products,
    COUNT(product_category_name) AS category_filled,
    COUNT(DISTINCT product_category_name) AS unique_categories
FROM products;
--customer city 
SELECT 
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 10;
--product category
SELECT 
    p.product_category_name,
    COUNT(oi.order_item_id) AS total_items_sold,
    ROUND(AVG(oi.price)::numeric, 2) AS avg_price
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC
LIMIT 10;
SELECT
    date_trunc('month', o.order_purchase_timestamp::timestamp) AS month,
    ROUND(SUM(op.payment_value)::numeric, 2) AS total_revenue_brl
FROM orders o
JOIN order_payments op 
    ON o.order_id = op.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY month
ORDER BY month;
SELECT 
    CASE 
        WHEN EXTRACT(DAY FROM AGE(
            o.order_delivered_customer_date::timestamp, 
            o.order_purchase_timestamp::timestamp
        )) <= 2 THEN '≤ 2 days'
        WHEN EXTRACT(DAY FROM AGE(
            o.order_delivered_customer_date::timestamp, 
            o.order_purchase_timestamp::timestamp
        )) <= 5 THEN '3-5 days'
        WHEN EXTRACT(DAY FROM AGE(
            o.order_delivered_customer_date::timestamp, 
            o.order_purchase_timestamp::timestamp
        )) <= 10 THEN '6-10 days'
        ELSE '>10 days'
    END AS delivery_bucket,
    COUNT(*) AS order_count,
    ROUND(AVG(r.review_score)::numeric, 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND o.order_purchase_timestamp IS NOT NULL
GROUP BY delivery_bucket
ORDER BY delivery_bucket;
--payment methods
SELECT 
    op.payment_type,
    COUNT(*) AS payment_count,
    ROUND(SUM(op.payment_value)::numeric, 2) AS total_value_brl,
    ROUND(AVG(op.payment_value)::numeric, 2) AS avg_payment_value
FROM order_payments op
GROUP BY op.payment_type
ORDER BY total_value_brl DESC;
--customer state
SELECT 
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(op.payment_value)::numeric, 2) AS total_revenue_brl
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_payments op ON o.order_id = op.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
GROUP BY c.customer_state
ORDER BY order_count DESC
LIMIT 5;