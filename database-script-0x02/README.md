# Seed Data (DML)

This directory contains SQL scripts to populate the ALX Airbnb-like database with realistic sample data for development and testing.

Files:
- `seed.sql` - INSERT statements to add sample users, properties, bookings, payments, reviews, and cancellations.

How to use:
1. Ensure the schema from `database-script-0x01/schema.sql` has been applied to your PostgreSQL database.
2. Run the seed script: `psql -d alx_airbnb_db -f database-script-0x02/seed.sql`

Notes:
- The script uses explicit UUIDs for clarity, but you can change to DEFAULT uuid_generate_v4() if you prefer generated IDs.
- Timestamps are set to illustrative values. Adjust as needed.
