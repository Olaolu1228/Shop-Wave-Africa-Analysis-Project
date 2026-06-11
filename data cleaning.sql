USE project_db;

-- Data Cleaning Steps

SELECT *
FROM project_1
-- Inspecting if every row in the data set was uploaded to the database
SELECT COUNT(*)
FROM project_1

--- Creating a backup table so we can keep the original table before it was cleaned 
SELECT *
INTO project_1_backup
FROM project_1

-- Checking for duplicates 
--For the Order_id column

SELECT order_id, COUNT(*)
FROM project_1
GROUP BY order_id
HAVING COUNT(*) > 1;

-- No duplicates detected in order_id

-- Check for duplicate enteries (full row duplicates)


EXEC sp_help project_1

-- Check for null or missing values

SELECT * 
FROM project_1
WHERE order_id IS NULL
	OR customer_id IS NULL
	OR product_id IS NULL
	OR category IS NULL 
	OR price IS NULL
	OR quantity IS NULL
	OR customer_age IS NULL
	OR customer_gender IS NULL

-- No NULL VALUES

-- Check for rows with product_id having more than 1 category

SELECT product_id, COUNT(DISTINCT category) AS category_count
FROM project_1
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1;

-- Check how many customer gender category
SELECT DISTINCT customer_gender FROM project_1;

--- Date conversion to one particular date format

SELECT order_id, order_date
FROM project_1
WHERE TRY_CONVERT(DATE, order_date) IS NULL
  AND order_date IS NOT NULL;

  -- Check for null values in each column category
  SELECT
    SUM(CASE WHEN order_id          IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id       IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN product_id        IS NULL THEN 1 ELSE 0 END) AS missing_product_id,
    SUM(CASE WHEN category          IS NULL THEN 1 ELSE 0 END) AS missing_category,
    SUM(CASE WHEN price             IS NULL THEN 1 ELSE 0 END) AS missing_price,
    SUM(CASE WHEN discount          IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN quantity          IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN payment_method    IS NULL THEN 1 ELSE 0 END) AS missing_payment_method,
    SUM(CASE WHEN order_date        IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN delivery_time_days IS NULL THEN 1 ELSE 0 END) AS missing_delivery_time,
    SUM(CASE WHEN region            IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN returned          IS NULL THEN 1 ELSE 0 END) AS missing_returned,
    SUM(CASE WHEN total_amount      IS NULL THEN 1 ELSE 0 END) AS missing_total_amount,
    SUM(CASE WHEN shipping_cost     IS NULL THEN 1 ELSE 0 END) AS missing_shipping_cost,
    SUM(CASE WHEN profit_margin     IS NULL THEN 1 ELSE 0 END) AS missing_profit_margin,
    SUM(CASE WHEN customer_age      IS NULL THEN 1 ELSE 0 END) AS missing_customer_age,
    SUM(CASE WHEN customer_gender   IS NULL THEN 1 ELSE 0 END) AS missing_customer_gender
FROM project_1;



-- Check for duplicates 
SELECT 
    order_id, customer_id, product_id, order_date,
    COUNT(*) AS duplicate_count
FROM project_1
GROUP BY order_id, customer_id, product_id, order_date
HAVING COUNT(*) > 1;





SELECT order_id, order_date
FROM project_1
WHERE TRY_CONVERT(DATE, order_date) IS NULL
  AND order_date IS NOT NULL;

-- To get the earliest and latest purchase date to see if it match the records
  SELECT 
    MIN(TRY_CONVERT(DATE, order_date)) AS earliest_date,
    MAX(TRY_CONVERT(DATE, order_date)) AS latest_date
FROM project_1;

-- Count of rows with negative profit margin.....Total negative profits
SELECT COUNT(*) AS negative_profit_rows
FROM project_1
WHERE profit_margin < 0;

-- Check how many negative profits each category has
SELECT 
    category,
    COUNT(*) AS negative_profit_count
FROM project_1
WHERE profit_margin < 0
GROUP BY category
ORDER BY negative_profit_count DESC;

-- Check for rows wherre price is less than or equal to zero
SELECT * FROM project_1 WHERE price <= 0;

--- Check the minimum, average, and maximum value of each category
SELECT
    MIN(price)              AS min_price,
    MAX(price)              AS max_price,
    AVG(price)              AS avg_price,

    MIN(total_amount)       AS min_total,
    MAX(total_amount)       AS max_total,
    AVG(total_amount)       AS avg_total,

    MIN(profit_margin)      AS min_profit,
    MAX(profit_margin)      AS max_profit,
    AVG(profit_margin)      AS avg_profit,

    MIN(shipping_cost)      AS min_shipping,
    MAX(shipping_cost)      AS max_shipping,

    MIN(delivery_time_days) AS min_delivery,
    MAX(delivery_time_days) AS max_delivery,

    MIN(customer_age)       AS min_age,
    MAX(customer_age)       AS max_age
FROM project_1;


--- Business Validation EDA

--- 1. Count of negative profit margins

SELECT COUNT(*) AS negative_profits
FROM project_1
WHERE profit_margin < 0;

-- 2. Negative profits by Category

SELECT 
    category,
    COUNT(*) 
FROM project_1
WHERE profit_margin < 0
GROUP BY category

-- 3. Zero or negative Prices

SELECT * FROM project_1 WHERE price <= 0;

-- 4. Zero or negative quantity
SELECT * FROM project_1 WHERE quantity <= 0;

-- 5. Zero shipping cost (possible free shipping flag)
SELECT 
    order_id, price, quantity, total_amount, shipping_cost
FROM project_1 
WHERE shipping_cost = 0;

-- Validate Total Amount

SELECT 
    order_id,
    price,
    quantity,
    discount,
    total_amount,
    ROUND(price * quantity * (1 - discount), 2) AS expected_total,
    ABS(total_amount - ROUND(price * quantity * (1 - discount), 2)) AS difference
FROM project_1
WHERE ABS(total_amount - ROUND(price * quantity * (1 - discount), 2)) > 1
ORDER BY difference DESC;

-- Return Rate Analysis

-- Percentage of orders returned
SELECT 
    COUNT(*) AS total_orders,

    SUM(CAST(returned AS INT)) AS returned_orders,

    ROUND(
        100.0 * SUM(CAST(returned AS INT)) / COUNT(*),
    2) AS return_rate_pct

FROM project_1;

-- Percentage of orders returned by Category

SELECT
    category,
    COUNT(*) AS total_orders,
    SUM (CAST(returned AS INT)) AS returns,
    ROUND(
        100.0 * SUM (CAST(returned AS INT)) / COUNT(*), 2
    ) AS return_rate_pct
FROM project_1
GROUP BY category
ORDER BY return_rate_pct DESC;

-- Identify products with more than one category

SELECT 
    product_id,
    COUNT(DISTINCT category) AS category_count,
    STRING_AGG(category, ', ') WITHIN GROUP (ORDER BY category) AS categories
FROM project_1
GROUP BY product_id
HAVING COUNT(DISTINCT category) > 1
ORDER BY category_count DESC;

-- Affected rows

SELECT COUNT(*) AS affected_orders
FROM project_1
WHERE product_id IN (
    SELECT product_id
    FROM project_1
    GROUP BY product_id
    HAVING COUNT(DISTINCT category) > 1
);

-- Fix affected rows
-- Using CTE statement

WITH category_frequency AS (
    SELECT 
        product_id,
        category,
        COUNT(*) AS freq,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM project_1
    GROUP BY product_id, category
),
dominant_category AS (
    SELECT 
        product_id,
        category AS dominant_cat
    FROM category_frequency
    WHERE rn = 1
)

-- Final SELECT that uses the CTE result
SELECT 
    product_id,
    dominant_cat
FROM dominant_category
ORDER BY product_id;

-- Checking to see if the fix worked

WITH category_frequency AS (
    SELECT 
        product_id,
        category,
        COUNT(*) AS freq,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM project_1
    GROUP BY product_id, category
),
dominant_category AS (
    SELECT 
        product_id,
        category AS dominant_cat
    FROM category_frequency
    WHERE rn = 1
)

-- Your original query goes here
SELECT 
    e.order_id,
    e.product_id,
    e.category AS original_category,
    d.dominant_cat AS corrected_category
FROM project_1 e
JOIN dominant_category d ON e.product_id = d.product_id
WHERE e.category <> d.dominant_cat
ORDER BY e.product_id;


--- Outlier detection

WITH price_quartiles AS (
    SELECT
        PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY price) 
            OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY price) 
            OVER () AS Q3
    FROM project_1
)
SELECT 
    e.*,
    p.Q1,
    p.Q3,
    (p.Q3 - p.Q1) AS IQR,
    p.Q1 - 1.5 * (p.Q3 - p.Q1) AS lower_bound,
    p.Q3 + 1.5 * (p.Q3 - p.Q1) AS upper_bound
FROM project_1 e
CROSS JOIN (SELECT DISTINCT Q1, Q3 FROM price_quartiles) p
WHERE e.price < p.Q1 - 1.5 * (p.Q3 - p.Q1)
   OR e.price > p.Q3 + 1.5 * (p.Q3 - p.Q1);


----------------------

-- STEP 1: First aggregate the counts
WITH category_frequency AS (
    SELECT 
        product_id,
        category,
        COUNT(*) AS freq
    FROM project_1
    GROUP BY product_id, category
),

-- STEP 2: Then apply ROW_NUMBER() on top of the aggregated result
category_ranked AS (
    SELECT 
        product_id,
        category,
        freq,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY freq DESC
        ) AS rn
    FROM category_frequency
),

-- STEP 3: Filter to only the dominant (rank 1) category
dominant_category AS (
    SELECT 
        product_id, 
        category AS dominant_cat
    FROM category_ranked
    WHERE rn = 1
)

-- STEP 4: Join back to your main table
SELECT 
    p.order_id,
    p.customer_id,
    p.product_id,
    d.dominant_cat        AS category,        -- corrected category
    p.price,
    p.discount,
    p.quantity,
    p.payment_method,
    TRY_CONVERT(DATE, p.order_date) AS order_date,
    p.delivery_time_days,
    p.region,
    p.returned,
    p.total_amount,
    p.shipping_cost,
    p.profit_margin,
    p.customer_age,
    p.customer_gender
INTO ecommerce_sales_cleaned
FROM project_1 p
JOIN dominant_category d ON p.product_id = d.product_id;


SELECT *
INTO project_2
FROM project_1

SELECT TOP 20 * 
FROM project_2;

SELECT COUNT (*)
FROM project_3

SELECT category, COUNT(*) AS order_count
FROM project_3
GROUP BY category
ORDER BY order_count DESC;

SELECT SUM(order_count) AS total
FROM (
    SELECT category, COUNT(*) AS order_count
    FROM project_3
    GROUP BY category
) t;



WITH category_frequency AS (
    SELECT 
        product_id,
        category,
        COUNT(*) AS freq
    FROM project_1
    GROUP BY product_id, category
),
category_ranked AS (
    SELECT 
        product_id,
        category,
        freq,
        ROW_NUMBER() OVER (
            PARTITION BY product_id 
            ORDER BY freq DESC, category ASC  
        ) AS rn
    FROM category_frequency
),
dominant_category AS (
    SELECT 
        product_id, 
        category AS dominant_cat
    FROM category_ranked
    WHERE rn = 1
)
SELECT 
    p.order_id,
    p.customer_id,
    p.product_id,
    d.dominant_cat        AS category,
    p.price,
    p.discount,
    p.quantity,
    p.payment_method,
    TRY_CONVERT(DATE, p.order_date) AS order_date,
    p.delivery_time_days,
    p.region,
    p.returned,
    p.total_amount,
    p.shipping_cost,
    p.profit_margin,
    p.customer_age,
    p.customer_gender
INTO project_3
FROM project_1 p
JOIN dominant_category d ON p.product_id = d.product_id;

SELECT *
FROM project_3

--- Revenue Analysis

------- Revenue earned before discount

ALTER TABLE project_3
ADD revenue_before_discount FLOAT;

UPDATE project_3
SET revenue_before_discount = price * quantity;

-- Discount value analysis

ALTER TABLE project_3
ADD discount_value FLOAT;

SELECT *
FROM project_3

UPDATE project_3
SET discount_value = (price * quantity) * discount;

--- net revenue

ALTER TABLE project_3
ADD net_revenue FLOAT;

-- Net profit

UPDATE project_3
SET net_revenue = total_amount - shipping_cost;


SELECT DISTINCT region
FROM project_3;


ALTER TABLE project_3
ADD order_date_clean DATE;

UPDATE project_3
SET order_date_clean = TRY_CONVERT(DATE, order_date, 101);

SELECT *
FROM project_3

-- Extract Month and year

ALTER TABLE project_3
ADD order_month VARCHAR(20),
    order_year INT;

UPDATE project_3
SET order_month = DATENAME(MONTH, order_date_clean),
    order_year = YEAR(order_date_clean);

-- Negative profit margins

SELECT *
FROM project_3
WHERE profit_margin < 0;

SELECT COUNT(*) AS lost_profit
FROM project_3
WHERE profit_margin < 0;

-- Impact of lost profit on Revenue

SELECT SUM(total_amount) AS lost_revenue
FROM project_3
WHERE profit_margin < 0;

--- Unusual delivery period

SELECT *
FROM project_3
WHERE delivery_time_days > 30;

SELECT AVG(total_amount) AS average_amount
FROM project_3






