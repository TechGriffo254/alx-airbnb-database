-- Task 3: Implement Indexes for Optimization
-- This file contains CREATE INDEX commands for high-usage columns

-- =============================================================================
-- Indexes for User Table
-- =============================================================================
-- User table is frequently queried by email (login), phone, and role

-- Index on email for login queries and user lookups
CREATE INDEX idx_user_email ON User(email);

-- Index on phone_number for user searches
CREATE INDEX idx_user_phone ON User(phone_number);

-- Index on role for filtering by user type (guest, host, admin)
CREATE INDEX idx_user_role ON User(role);

-- Composite index for common search patterns
CREATE INDEX idx_user_role_created ON User(role, created_at);


-- =============================================================================
-- Indexes for Property Table
-- =============================================================================
-- Property table is frequently searched by location, price, and host

-- Index on host_id for finding all properties by a specific host
CREATE INDEX idx_property_host ON Property(host_id);

-- Index on location for location-based searches
CREATE INDEX idx_property_location ON Property(location);

-- Index on pricepernight for price range queries
CREATE INDEX idx_property_price ON Property(pricepernight);

-- Composite index for common search patterns (location + price)
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- Index on created_at for newest listings
CREATE INDEX idx_property_created ON Property(created_at);


-- =============================================================================
-- Indexes for Booking Table
-- =============================================================================
-- Booking table is heavily queried by user, property, dates, and status

-- Index on user_id for finding all bookings by a user
CREATE INDEX idx_booking_user ON Booking(user_id);

-- Index on property_id for finding all bookings for a property
CREATE INDEX idx_booking_property ON Booking(property_id);

-- Index on start_date for date range queries
CREATE INDEX idx_booking_start_date ON Booking(start_date);

-- Index on end_date for date range queries
CREATE INDEX idx_booking_end_date ON Booking(end_date);

-- Index on status for filtering by booking status
CREATE INDEX idx_booking_status ON Booking(status);

-- Composite index for property availability checks (property + dates)
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);

-- Composite index for user booking history (user + dates + status)
CREATE INDEX idx_booking_user_dates_status ON Booking(user_id, start_date, status);

-- Index on created_at for recent bookings
CREATE INDEX idx_booking_created ON Booking(created_at);


-- =============================================================================
-- Indexes for Payment Table
-- =============================================================================
-- Payment table is queried by booking, payment method, and status

-- Index on booking_id for finding payment by booking
CREATE INDEX idx_payment_booking ON Payment(booking_id);

-- Index on payment_method for payment method analysis
CREATE INDEX idx_payment_method ON Payment(payment_method);

-- Index on payment_date for transaction history
CREATE INDEX idx_payment_date ON Payment(payment_date);

-- Composite index for payment tracking
CREATE INDEX idx_payment_booking_date ON Payment(booking_id, payment_date);


-- =============================================================================
-- Indexes for Review Table
-- =============================================================================
-- Review table is queried by property, user, and rating

-- Index on property_id for finding all reviews for a property
CREATE INDEX idx_review_property ON Review(property_id);

-- Index on user_id for finding all reviews by a user
CREATE INDEX idx_review_user ON Review(user_id);

-- Index on rating for filtering high/low-rated reviews
CREATE INDEX idx_review_rating ON Review(rating);

-- Composite index for property reviews sorted by rating
CREATE INDEX idx_review_property_rating ON Review(property_id, rating DESC);

-- Index on created_at for recent reviews
CREATE INDEX idx_review_created ON Review(created_at);


-- =============================================================================
-- Indexes for Message Table
-- =============================================================================
-- Message table is queried by sender, recipient, and timestamps

-- Index on sender_id for finding sent messages
CREATE INDEX idx_message_sender ON Message(sender_id);

-- Index on recipient_id for finding received messages
CREATE INDEX idx_message_recipient ON Message(recipient_id);

-- Composite index for conversation threads
CREATE INDEX idx_message_conversation ON Message(sender_id, recipient_id, sent_at);

-- Index on sent_at for message history
CREATE INDEX idx_message_sent ON Message(sent_at);


-- =============================================================================
-- Performance Testing Queries
-- =============================================================================
-- Run these queries with EXPLAIN before and after creating indexes

-- Query 1: Find all bookings for a specific user
EXPLAIN SELECT * FROM Booking WHERE user_id = 'some-uuid-here';

-- Query 2: Find available properties in a location and price range
EXPLAIN SELECT * 
FROM Property 
WHERE location = 'New York' 
AND pricepernight BETWEEN 100 AND 300;

-- Query 3: Find bookings in a date range
EXPLAIN SELECT * 
FROM Booking 
WHERE start_date >= '2024-01-01' 
AND end_date <= '2024-12-31';

-- Query 4: Find properties with average rating > 4.0
EXPLAIN SELECT p.*, AVG(r.rating) as avg_rating
FROM Property p
JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id
HAVING AVG(r.rating) > 4.0;

-- Query 5: Complex join query (bookings with user and property details)
EXPLAIN SELECT 
    b.booking_id,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    b.total_price
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
WHERE b.status = 'confirmed'
AND b.start_date >= '2024-01-01';


-- =============================================================================
-- ANALYZE TABLE commands (for MySQL)
-- =============================================================================
-- Update table statistics after creating indexes

ANALYZE TABLE User;
ANALYZE TABLE Property;
ANALYZE TABLE Booking;
ANALYZE TABLE Payment;
ANALYZE TABLE Review;
ANALYZE TABLE Message;
