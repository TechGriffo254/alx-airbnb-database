# Database Schema (DDL)

This directory contains the SQL DDL script to create the database schema for the ALX Airbnb-like project.

Files:
- `schema.sql` - SQL statements to create tables, constraints, and indexes.

How to use:
- The scripts target PostgreSQL (recommended). To run locally:

  1. Create a database: `createdb alx_airbnb_db`
  2. Apply schema: `psql -d alx_airbnb_db -f schema.sql`

Notes:
- Data types and syntax follow PostgreSQL conventions. If you use MySQL or SQLite, adjust types and serial/UUID usage accordingly.
- Indexes are included for common query patterns (email lookup, property searches, bookings by date).
