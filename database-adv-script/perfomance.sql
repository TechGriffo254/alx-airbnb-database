-- Task 4: Optimize Complex Queries
-- This file contains initial and refactored queries for performance optimization

-- =============================================================================
-- INITIAL QUERY (Before Optimization)
-- =============================================================================
-- This query retrieves all bookings along with user details, property details, 
-- and payment details WITHOUT optimization

SELECT 
    -- Booking details
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_price,
    b.status AS booking_status,
    b.created_at AS booking_created_at,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role AS user_role,
    u.created_at AS user_created_at,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    
    -- Host details (from User table again)
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.phone_number AS host_phone,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM 
    Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.created_at DESC;


-- =============================================================================
-- REFACTORED QUERY (After Optimization)
-- =============================================================================
-- Optimizations applied:
-- 1. Removed unnecessary columns (reduced data transfer)
-- 2. Added WHERE clause to filter relevant data
-- 3. Use proper indexes (defined in database_index.sql)
-- 4. Added LIMIT for pagination
-- 5. Simplified joins

SELECT 
    -- Essential booking details only
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Essential user details
    u.user_id,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    
    -- Essential property details
    p.property_id,
    p.name AS property_name,
    p.location,
    
    -- Essential host details
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    
    -- Payment status
    CASE 
        WHEN pay.payment_id IS NOT NULL THEN 'Paid'
        ELSE 'Pending'
    END AS payment_status,
    pay.payment_method
FROM 
    Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)  -- Last 6 months only
    AND b.status IN ('confirmed', 'pending')  -- Active bookings only
ORDER BY 
    b.created_at DESC
LIMIT 100;  -- Pagination


-- =============================================================================
-- ADDITIONAL OPTIMIZATION: Indexed Query for Recent Confirmed Bookings
-- =============================================================================
-- This version is optimized for a specific use case: recent confirmed bookings

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name,
    b.total_price
FROM 
    Booking b
    FORCE INDEX (idx_booking_created)  -- Force use of index on created_at
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
WHERE 
    b.status = 'confirmed'
    AND b.created_at >= '2024-01-01'
ORDER BY 
    b.created_at DESC
LIMIT 50;


-- =============================================================================
-- COMPARISON QUERY: Analyze Performance
-- =============================================================================
-- Run EXPLAIN on both queries to compare execution plans

-- Initial query EXPLAIN:
EXPLAIN 
SELECT 
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    u.user_id, u.first_name, u.last_name, u.email,
    p.property_id, p.name, p.location,
    h.first_name AS host_first_name, h.last_name AS host_last_name,
    pay.payment_id, pay.amount, pay.payment_method
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;


-- Refactored query EXPLAIN:
EXPLAIN 
SELECT 
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    p.name AS property_name, p.location,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    CASE WHEN pay.payment_id IS NOT NULL THEN 'Paid' ELSE 'Pending' END AS payment_status
FROM Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.created_at >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
    AND b.status IN ('confirmed', 'pending')
ORDER BY b.created_at DESC
LIMIT 100;


-- =============================================================================
-- BONUS: Materialized View Alternative (for frequently accessed data)
-- =============================================================================
-- Create a view for commonly accessed booking summary

CREATE OR REPLACE VIEW vw_booking_summary AS
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    p.name AS property_name,
    p.location,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    pay.payment_method,
    b.created_at
FROM 
    Booking b
INNER JOIN User u ON b.user_id = u.user_id
INNER JOIN Property p ON b.property_id = p.property_id
INNER JOIN User h ON p.host_id = h.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;

-- Usage:
-- SELECT * FROM vw_booking_summary WHERE status = 'confirmed' LIMIT 100;
