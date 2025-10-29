-- Task 2: Apply Aggregations and Window Functions
-- This file demonstrates SQL aggregation functions and window functions for data analysis

-- =============================================================================
-- Query 1: Aggregation with COUNT and GROUP BY
-- Find the total number of bookings made by each user
-- =============================================================================
-- This query counts bookings per user and provides comprehensive booking statistics

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings,
    MIN(b.start_date) AS first_booking_date,
    MAX(b.start_date) AS last_booking_date,
    SUM(b.total_price) AS total_amount_spent,
    AVG(b.total_price) AS average_booking_value,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) AS confirmed_bookings,
    COUNT(CASE WHEN b.status = 'canceled' THEN 1 END) AS canceled_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) AS pending_bookings
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
HAVING 
    COUNT(b.booking_id) > 0  -- Only show users with at least one booking
ORDER BY 
    total_bookings DESC, total_amount_spent DESC;


-- Simpler version showing just booking counts:
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings
FROM 
    User u
INNER JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name
ORDER BY 
    total_bookings DESC;


-- =============================================================================
-- Query 2: Window Functions - ROW_NUMBER
-- Rank properties based on the total number of bookings they have received
-- =============================================================================
-- ROW_NUMBER assigns a unique sequential number to each row

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number_rank,
    CONCAT('#', ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC)) AS ranking_display
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;


-- =============================================================================
-- Query 3: Window Functions - RANK
-- Rank properties with RANK (allows ties, skips next rank after tie)
-- =============================================================================
-- RANK gives the same rank to rows with the same value and skips subsequent ranks

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_booking_rank
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;


-- =============================================================================
-- Query 4: Combined Window Functions - Comprehensive Property Rankings
-- =============================================================================
-- This query demonstrates multiple window functions to provide different perspectives

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS total_revenue,
    AVG(b.total_price) AS average_booking_value,
    
    -- Ranking by booking count
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_row_number,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_rank,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS booking_dense_rank,
    
    -- Ranking by revenue
    RANK() OVER (ORDER BY SUM(b.total_price) DESC) AS revenue_rank,
    
    -- Percentage of total bookings
    ROUND(
        COUNT(b.booking_id) * 100.0 / SUM(COUNT(b.booking_id)) OVER (), 
        2
    ) AS percentage_of_total_bookings,
    
    -- Cumulative bookings
    SUM(COUNT(b.booking_id)) OVER (ORDER BY COUNT(b.booking_id) DESC) AS cumulative_bookings
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC;


-- =============================================================================
-- Query 5: Window Functions with PARTITION BY
-- Rank properties by booking count within each location
-- =============================================================================
-- PARTITION BY divides the result set into partitions and applies the window function independently

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (
        PARTITION BY p.location 
        ORDER BY COUNT(b.booking_id) DESC
    ) AS rank_within_location,
    RANK() OVER (
        ORDER BY COUNT(b.booking_id) DESC
    ) AS overall_rank
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    p.location, rank_within_location;


-- =============================================================================
-- BONUS: Advanced Aggregation Examples
-- =============================================================================

-- Example 6: Monthly booking trends
SELECT 
    DATE_FORMAT(b.start_date, '%Y-%m') AS booking_month,
    COUNT(b.booking_id) AS total_bookings,
    SUM(b.total_price) AS monthly_revenue,
    AVG(b.total_price) AS average_booking_value,
    COUNT(DISTINCT b.user_id) AS unique_customers,
    COUNT(DISTINCT b.property_id) AS properties_booked
FROM 
    Booking b
GROUP BY 
    DATE_FORMAT(b.start_date, '%Y-%m')
ORDER BY 
    booking_month DESC;


-- Example 7: Property performance metrics with moving averages
SELECT 
    p.property_id,
    p.name AS property_name,
    COUNT(b.booking_id) AS total_bookings,
    AVG(COUNT(b.booking_id)) OVER (
        ORDER BY p.property_id 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_bookings_3period,
    FIRST_VALUE(COUNT(b.booking_id)) OVER (
        ORDER BY COUNT(b.booking_id) DESC
    ) AS max_bookings,
    LAST_VALUE(COUNT(b.booking_id)) OVER (
        ORDER BY COUNT(b.booking_id) DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS min_bookings
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name
ORDER BY 
    total_bookings DESC;
