-- Task 1: Practice Subqueries
-- This file contains both non-correlated and correlated subqueries

-- =============================================================================
-- Query 1: Non-Correlated Subquery
-- Find all properties where the average rating is greater than 4.0
-- =============================================================================
-- This subquery calculates the average rating for each property independently
-- and filters properties with avg rating > 4.0

SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.description,
    (SELECT AVG(r.rating) 
     FROM Review r 
     WHERE r.property_id = p.property_id) AS average_rating
FROM 
    Property p
WHERE 
    (SELECT AVG(r.rating) 
     FROM Review r 
     WHERE r.property_id = p.property_id) > 4.0
ORDER BY 
    average_rating DESC;


-- Alternative approach using HAVING clause with GROUP BY:
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    p.description,
    AVG(r.rating) AS average_rating
FROM 
    Property p
INNER JOIN 
    Review r ON p.property_id = r.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight, p.description
HAVING 
    AVG(r.rating) > 4.0
ORDER BY 
    average_rating DESC;


-- =============================================================================
-- Query 2: Correlated Subquery
-- Find users who have made more than 3 bookings
-- =============================================================================
-- This correlated subquery counts bookings for each user
-- The subquery is executed once for each row in the outer query

SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.created_at AS user_since,
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS total_bookings
FROM 
    User u
WHERE 
    (SELECT COUNT(*) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) > 3
ORDER BY 
    total_bookings DESC;


-- Alternative approach using GROUP BY and HAVING (more efficient):
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.created_at AS user_since,
    COUNT(b.booking_id) AS total_bookings
FROM 
    User u
INNER JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email, u.phone_number, u.created_at
HAVING 
    COUNT(b.booking_id) > 3
ORDER BY 
    total_bookings DESC;


-- =============================================================================
-- BONUS: Additional Subquery Examples
-- =============================================================================

-- Example 3: Find properties that have never been booked (non-correlated)
SELECT 
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight
FROM 
    Property p
WHERE 
    p.property_id NOT IN (
        SELECT DISTINCT property_id 
        FROM Booking
    )
ORDER BY 
    p.pricepernight DESC;


-- Example 4: Find users whose total booking value exceeds the average (correlated)
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    (SELECT SUM(b.total_price) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) AS total_spent
FROM 
    User u
WHERE 
    (SELECT SUM(b.total_price) 
     FROM Booking b 
     WHERE b.user_id = u.user_id) > (
        SELECT AVG(total_booking_value)
        FROM (
            SELECT SUM(b2.total_price) AS total_booking_value
            FROM Booking b2
            GROUP BY b2.user_id
        ) AS user_totals
    )
ORDER BY 
    total_spent DESC;


-- Example 5: Find the most recent booking for each property (correlated)
SELECT 
    p.property_id,
    p.name AS property_name,
    (SELECT MAX(b.start_date) 
     FROM Booking b 
     WHERE b.property_id = p.property_id) AS most_recent_booking_date,
    (SELECT b2.status 
     FROM Booking b2 
     WHERE b2.property_id = p.property_id 
     AND b2.start_date = (
         SELECT MAX(b3.start_date) 
         FROM Booking b3 
         WHERE b3.property_id = p.property_id
     )
     LIMIT 1) AS booking_status
FROM 
    Property p
WHERE 
    EXISTS (
        SELECT 1 
        FROM Booking b 
        WHERE b.property_id = p.property_id
    )
ORDER BY 
    most_recent_booking_date DESC;
