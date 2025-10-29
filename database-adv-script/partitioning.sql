-- Task 5: Partitioning Large Tables
-- This file implements table partitioning on the Booking table based on start_date

-- =============================================================================
-- STEP 1: Create Partitioned Booking Table
-- =============================================================================
-- Note: This creates a NEW partitioned table. In production, you would:
-- 1. Backup existing data
-- 2. Create new partitioned table
-- 3. Migrate data
-- 4. Rename tables

-- Drop existing table if recreating (BACKUP DATA FIRST!)
-- DROP TABLE IF EXISTS Booking_Partitioned;

CREATE TABLE Booking_Partitioned (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    -- Indexes for performance
    INDEX idx_property (property_id),
    INDEX idx_user (user_id),
    INDEX idx_status (status),
    INDEX idx_start_date (start_date)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p_2020 VALUES LESS THAN (2021),
    PARTITION p_2021 VALUES LESS THAN (2022),
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025),
    PARTITION p_2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);


-- =============================================================================
-- STEP 2: Alternative Partitioning Strategy (By Month)
-- =============================================================================
-- For more granular partitioning, use RANGE COLUMNS with monthly partitions

CREATE TABLE Booking_Partitioned_Monthly (
    booking_id CHAR(36) PRIMARY KEY,
    property_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10, 2) NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES User(user_id) ON DELETE CASCADE,
    
    INDEX idx_property (property_id),
    INDEX idx_user (user_id),
    INDEX idx_status (status)
)
PARTITION BY RANGE COLUMNS(start_date) (
    PARTITION p_2024_q1 VALUES LESS THAN ('2024-04-01'),
    PARTITION p_2024_q2 VALUES LESS THAN ('2024-07-01'),
    PARTITION p_2024_q3 VALUES LESS THAN ('2024-10-01'),
    PARTITION p_2024_q4 VALUES LESS THAN ('2025-01-01'),
    PARTITION p_2025_q1 VALUES LESS THAN ('2025-04-01'),
    PARTITION p_2025_q2 VALUES LESS THAN ('2025-07-01'),
    PARTITION p_2025_q3 VALUES LESS THAN ('2025-10-01'),
    PARTITION p_2025_q4 VALUES LESS THAN ('2026-01-01'),
    PARTITION p_future VALUES LESS THAN (MAXVALUE)
);


-- =============================================================================
-- STEP 3: Migrate Data from Original to Partitioned Table
-- =============================================================================
-- Copy existing booking data to the new partitioned table

INSERT INTO Booking_Partitioned 
SELECT * FROM Booking;

-- Verify row counts match
SELECT 'Original' AS table_name, COUNT(*) AS row_count FROM Booking
UNION ALL
SELECT 'Partitioned' AS table_name, COUNT(*) AS row_count FROM Booking_Partitioned;


-- =============================================================================
-- STEP 4: Performance Testing Queries
-- =============================================================================

-- Query 1: Fetch bookings for a specific date range (BEFORE partitioning)
-- This query will scan the entire Booking table
EXPLAIN
SELECT *
FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';

-- Query 2: Same query on partitioned table (AFTER partitioning)
-- This query will only scan the relevant partitions (2024 partition)
EXPLAIN
SELECT *
FROM Booking_Partitioned
WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';


-- Query 3: Get bookings for last month
EXPLAIN
SELECT booking_id, property_id, user_id, start_date, total_price
FROM Booking_Partitioned
WHERE start_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
ORDER BY start_date DESC;


-- Query 4: Count bookings per year (partition pruning benefits)
EXPLAIN
SELECT 
    YEAR(start_date) AS booking_year,
    COUNT(*) AS total_bookings,
    SUM(total_price) AS total_revenue
FROM Booking_Partitioned
WHERE YEAR(start_date) = 2024
GROUP BY YEAR(start_date);


-- =============================================================================
-- STEP 5: View Partition Information
-- =============================================================================

-- Show partition details
SELECT 
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH
FROM 
    INFORMATION_SCHEMA.PARTITIONS
WHERE 
    TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'Booking_Partitioned'
ORDER BY 
    PARTITION_ORDINAL_POSITION;


-- =============================================================================
-- STEP 6: Partition Maintenance Operations
-- =============================================================================

-- Add a new partition for future years
ALTER TABLE Booking_Partitioned
ADD PARTITION (PARTITION p_2026 VALUES LESS THAN (2027));

-- Drop old partition (CAUTION: This deletes data!)
-- ALTER TABLE Booking_Partitioned DROP PARTITION p_2020;

-- Reorganize partitions if needed
-- ALTER TABLE Booking_Partitioned REORGANIZE PARTITION p_future INTO (
--     PARTITION p_2026 VALUES LESS THAN (2027),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );

-- Analyze partitions to update statistics
ANALYZE TABLE Booking_Partitioned;


-- =============================================================================
-- STEP 7: Compare Performance with BENCHMARK
-- =============================================================================

-- Test query performance on original table
SET @start_time = NOW(6);
SELECT COUNT(*) FROM Booking WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS non_partitioned_microseconds;

-- Test query performance on partitioned table
SET @start_time = NOW(6);
SELECT COUNT(*) FROM Booking_Partitioned WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31';
SET @end_time = NOW(6);
SELECT TIMESTAMPDIFF(MICROSECOND, @start_time, @end_time) AS partitioned_microseconds;


-- =============================================================================
-- NOTES ON PARTITIONING BENEFITS
-- =============================================================================
/*
1. Partition Pruning: MySQL only scans relevant partitions based on WHERE clause
2. Maintenance Operations: Can archive old data by dropping partitions
3. Parallel Query Execution: Some storage engines can query multiple partitions in parallel
4. Improved Index Performance: Smaller indexes per partition
5. Easier Data Management: Can back up, restore, or optimize individual partitions

TRADE-OFFS:
- Increased complexity in table management
- Primary key must include partitioning column or be global
- Some queries may not benefit if they don't filter by partition key
- Partition management overhead
*/
