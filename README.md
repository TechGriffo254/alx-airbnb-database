# ALX Airbnb Database Project

**Project:** DataScape: Mastering Database Design  
**Module:** ALX Airbnb Database Module  
**Deadline:** October 27, 2025

## Project Overview

This repository contains a complete database design and implementation for an Airbnb-like application, demonstrating professional-grade database engineering skills including ERD design, normalization, schema definition, and data seeding.

## Repository Structure

```
alx-airbnb-database/
├── ERD/
│   └── requirements.md          # Entity-Relationship diagram requirements and entity definitions
├── database-script-0x01/
│   ├── schema.sql              # DDL script to create database tables, constraints, and indexes
│   └── README.md               # Instructions for running the schema
├── database-script-0x02/
│   ├── seed.sql                # DML script to populate database with sample data
│   └── README.md               # Instructions for running the seed script
└── normalization.md            # Normalization analysis and 3NF compliance documentation
```

## Tasks Completed

### ✅ Task 0: Define Entities and Relationships in ER Diagram
- **File:** `ERD/requirements.md`
- **Description:** Comprehensive documentation of all entities (User, Property, Booking, Payment, Review, etc.), their attributes, and relationships
- **Next Step:** Create visual ERD using Draw.io and export as `ERD/diagram.png` and `ERD/diagram.drawio`

### ✅ Task 1: Normalize Your Database Design
- **File:** `normalization.md`
- **Description:** Detailed explanation of normalization steps to achieve Third Normal Form (3NF), including rationale for design decisions

### ✅ Task 2: Design Database Schema (DDL)
- **Directory:** `database-script-0x01/`
- **Files:** `schema.sql`, `README.md`
- **Description:** Complete PostgreSQL DDL with:
  - UUID primary keys using `uuid-ossp` extension
  - Foreign key constraints with proper CASCADE rules
  - Check constraints for data validation
  - Performance indexes on commonly queried columns
  - Triggers for automatic `updated_at` timestamp management

### ✅ Task 3: Seed the Database with Sample Data
- **Directory:** `database-script-0x02/`
- **Files:** `seed.sql`, `README.md`
- **Description:** Realistic sample data including:
  - Multiple users (hosts and guests)
  - Properties with different types and pricing
  - Bookings with various statuses
  - Payments and reviews
  - Property amenities and images

## Database Entities

The database models the following core entities:

- **User** - Platform users (both hosts and guests)
- **Property** - Rental properties with location and pricing details
- **Property_Image** - Property photos
- **Amenity** - Available amenities (WiFi, Kitchen, etc.)
- **Property_Amenity** - Bridge table linking properties to amenities
- **Booking** - Rental reservations
- **Payment** - Payment transactions for bookings
- **Review** - User reviews tied to completed bookings
- **Cancellation** - Booking cancellation records

## How to Run

### Prerequisites
- PostgreSQL 12+ installed
- `psql` command-line tool available

### Setup Instructions

1. **Create the database:**
```powershell
createdb alx_airbnb_db
```

2. **Apply the schema:**
```powershell
psql -d alx_airbnb_db -f database-script-0x01/schema.sql
```

3. **Load sample data:**
```powershell
psql -d alx_airbnb_db -f database-script-0x02/seed.sql
```

4. **Verify the setup:**
```powershell
# List all tables
psql -d alx_airbnb_db -c "\dt"

# Check sample data
psql -d alx_airbnb_db -c "SELECT user_id, email, is_host FROM \"user\";"
psql -d alx_airbnb_db -c "SELECT property_id, title, price_per_night FROM property;"
psql -d alx_airbnb_db -c "SELECT booking_id, status FROM booking;"
```

## Key Design Decisions

1. **UUID Primary Keys:** Used for better scalability and distributed system support
2. **Normalization to 3NF:** Eliminated redundancy while maintaining query performance
3. **Strategic Indexing:** Added indexes on email, city/price, and booking dates for common queries
4. **Audit Timestamps:** Automatic `created_at` and `updated_at` tracking with triggers
5. **Referential Integrity:** Proper foreign key constraints with CASCADE rules
6. **Data Validation:** Check constraints for ratings, date ranges, etc.

## Technologies Used

- **Database:** PostgreSQL 12+
- **Extensions:** uuid-ossp for UUID generation
- **Tools:** psql, Draw.io (for ERD)

## Manual QA Review Checklist

Before requesting manual review, ensure:

- [ ] All required files are present and properly organized
- [ ] ERD visual diagram has been created and added to `ERD/` folder
- [ ] Schema script runs without errors
- [ ] Seed script successfully populates the database
- [ ] Normalization documentation explains 3NF compliance
- [ ] README files provide clear instructions

## Author

**GitHub:** [TechGriffo254](https://github.com/TechGriffo254)  
**Repository:** [alx-airbnb-database](https://github.com/TechGriffo254/alx-airbnb-database)

## Project Timeline

- **Start Date:** October 20, 2025
- **Due Date:** October 27, 2025
- **Submission Date:** October 23, 2025

---

**Note:** This project is part of the ALX Software Engineering curriculum and demonstrates mastery of database design principles, SQL DDL/DML, and professional development practices.
