# Complex Queries with Joins

## Overview
This file contains SQL queries demonstrating three types of joins: INNER JOIN, LEFT JOIN, and FULL OUTER JOIN. These queries are designed to retrieve data from the Airbnb database schema.

## Database Schema
The queries work with the following main tables:
- **User**: Contains user information (user_id, first_name, last_name, email, etc.)
- **Booking**: Contains booking information (booking_id, user_id, property_id, start_date, end_date, etc.)
- **Property**: Contains property listings (property_id, name, location, pricepernight, etc.)
- **Review**: Contains property reviews (review_id, property_id, user_id, rating, comment, etc.)

## Query Descriptions

### 1. INNER JOIN - Bookings with Users
**Purpose**: Retrieve all bookings along with the details of the users who made those bookings.

**How it works**: 
- Uses INNER JOIN to match bookings with their corresponding users
- Only returns records where both booking and user exist
- Ordered by booking creation date (most recent first)

**Use case**: Get a comprehensive list of all active bookings with customer information for customer service or reporting purposes.

**Columns returned**:
- Booking details: booking_id, start_date, end_date, total_price, status
- User details: user_id, first_name, last_name, email, phone_number

---

### 2. LEFT JOIN - Properties with Reviews
**Purpose**: Retrieve all properties and their reviews, including properties that haven't been reviewed yet.

**How it works**:
- Uses LEFT JOIN from Property to Review to include all properties
- Properties without reviews will show NULL values for review columns
- Additional LEFT JOIN to User table to get reviewer information
- Ordered by property_id and review date

**Use case**: Analyze which properties need more reviews, view all properties with their ratings, or identify properties that haven't received feedback.

**Columns returned**:
- Property details: property_id, name, location, pricepernight, description
- Review details: review_id, rating, comment, review_date
- Reviewer details: first_name, last_name

---

### 3. FULL OUTER JOIN - Users and Bookings
**Purpose**: Retrieve all users and all bookings, even if a user has no bookings or a booking is not linked to a user.

**How it works**:
- **MySQL version**: Simulates FULL OUTER JOIN using UNION of LEFT JOIN and RIGHT JOIN
- **PostgreSQL version**: Uses native FULL OUTER JOIN syntax (commented out)
- Returns all users (even those without bookings) and all bookings (even orphaned ones)
- Ordered by user_id and booking_id

**Use case**: Identify users who haven't made any bookings (for marketing campaigns) or orphaned bookings (data integrity check).

**Columns returned**:
- User details: user_id, first_name, last_name, email
- Booking details: booking_id, start_date, end_date, total_price, status

---

## Technical Notes

### FULL OUTER JOIN Implementation
MySQL doesn't natively support FULL OUTER JOIN, so we implement it using:
```sql
LEFT JOIN ... UNION ... RIGHT JOIN
```

PostgreSQL users can use the native FULL OUTER JOIN syntax (provided in comments).

### Performance Considerations
- All queries use appropriate indexes on join columns (user_id, property_id)
- Queries are ordered to facilitate result analysis
- LEFT JOINs may return multiple rows per property if multiple reviews exist

## Usage Instructions

1. Ensure the database schema is properly set up with all tables and relationships
2. Execute queries individually or as needed for reporting
3. Modify SELECT columns based on specific requirements
4. Add WHERE clauses to filter results by specific criteria (dates, status, etc.)

## Example Results

### INNER JOIN Example
```
booking_id | start_date  | user_id | first_name | email
-----------|-------------|---------|------------|-------------------
1          | 2024-12-01  | 101     | John       | john@example.com
2          | 2024-12-05  | 102     | Jane       | jane@example.com
```

### LEFT JOIN Example (showing property without review)
```
property_id | property_name | review_id | rating | comment
------------|---------------|-----------|--------|--------
1           | Beach House   | 1         | 5      | Great!
2           | City Apt      | NULL      | NULL   | NULL
```

### FULL OUTER JOIN Example
```
user_id | first_name | booking_id | start_date
--------|------------|------------|------------
101     | John       | 1          | 2024-12-01
102     | Jane       | NULL       | NULL
NULL    | NULL       | 99         | 2024-11-15
```

---

# Practice Subqueries

## Overview
This section demonstrates both **non-correlated** and **correlated** subqueries for advanced data analysis in the Airbnb database.

## Query Descriptions

### 1. Non-Correlated Subquery - Properties with Average Rating > 4.0
**Purpose**: Find all properties that have an average rating greater than 4.0.

**How it works**:
- The subquery `(SELECT AVG(r.rating) FROM Review r WHERE r.property_id = p.property_id)` calculates the average rating for each property
- This subquery is independent of the outer query (non-correlated)
- Results are filtered to only show properties with avg rating > 4.0
- An alternative approach using `HAVING AVG(rating) > 4.0` is also provided (more efficient)

**Use case**: Identify high-quality properties for featured listings or premium recommendations.

**Performance note**: The alternative GROUP BY/HAVING approach is generally faster than the subquery approach.

---

### 2. Correlated Subquery - Users with More Than 3 Bookings
**Purpose**: Find users who have made more than 3 bookings.

**How it works**:
- The subquery `(SELECT COUNT(*) FROM Booking b WHERE b.user_id = u.user_id)` counts bookings for each user
- This is a **correlated subquery** because it references `u.user_id` from the outer query
- The subquery executes once for each row in the outer User table
- An alternative approach using JOIN/GROUP BY/HAVING is also provided (more efficient)

**Use case**: Identify frequent customers for loyalty programs, VIP treatment, or targeted marketing campaigns.

**Performance note**: For large datasets, the JOIN/GROUP BY approach is significantly faster than the correlated subquery.

---

## Bonus Examples

### 3. Properties Never Booked (Non-Correlated with NOT IN)
Finds properties that have never received a booking using a NOT IN subquery.

### 4. Users Spending Above Average (Nested Subqueries)
Identifies users whose total booking value exceeds the average spending across all users.

### 5. Most Recent Booking Per Property (Correlated with EXISTS)
Retrieves the most recent booking date and status for each property using correlated subqueries and EXISTS.

---

## Performance Comparison

| Query Type | Approach | Performance | Best For |
|------------|----------|-------------|----------|
| Non-Correlated | Subquery in WHERE | Good | Simple filters, small datasets |
| Non-Correlated | JOIN + GROUP BY | Excellent | Large datasets, complex aggregations |
| Correlated | Subquery | Fair | Row-by-row calculations |
| Correlated | JOIN + Window Functions | Excellent | Ranking, running totals |

---

## Author
ALX Airbnb Database Project - Advanced SQL Queries
