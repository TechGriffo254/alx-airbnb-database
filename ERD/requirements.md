# ERD Requirements for DataScape: Mastering Database Design

Project: ALX Airbnb Database Module

Objective: Create an Entity-Relationship Diagram (ERD) that models an Airbnb-like application's database. The ERD should include entities, attributes, relationships, cardinalities, and constraints. Use Draw.io or a similar tool to produce a visual diagram and export it as PNG/SVG.

Entities (suggested):

- User
  - user_id (PK)
  - first_name
  - last_name
  - email (unique)
  - phone
  - password_hash
  - created_at
  - updated_at
  - is_host (boolean)

- Property
  - property_id (PK)
  - host_id (FK -> User.user_id)
  - title
  - description
  - address_line1
  - address_line2
  - city
  - state
  - country
  - postal_code
  - latitude
  - longitude
  - property_type (e.g., Apartment, House)
  - room_count
  - bathroom_count
  - max_guests
  - price_per_night
  - created_at
  - updated_at
  - is_active

- Property_Image
  - image_id (PK)
  - property_id (FK -> Property.property_id)
  - url
  - caption
  - is_primary

- Amenity
  - amenity_id (PK)
  - name
  - description

- Property_Amenity
  - property_id (PK, FK -> Property.property_id)
  - amenity_id (PK, FK -> Amenity.amenity_id)

- Booking
  - booking_id (PK)
  - property_id (FK -> Property.property_id)
  - guest_id (FK -> User.user_id)
  - host_id (FK -> User.user_id)  # denormalized for quick access (optional)
  - start_date
  - end_date
  - total_amount
  - status (e.g., pending, confirmed, cancelled, completed)
  - created_at
  - updated_at

- Payment
  - payment_id (PK)
  - booking_id (FK -> Booking.booking_id)
  - amount
  - currency
  - method (e.g., card, paypal)
  - status (e.g., pending, paid, refunded)
  - transaction_id (external)
  - paid_at

- Review
  - review_id (PK)
  - booking_id (FK -> Booking.booking_id)
  - reviewer_id (FK -> User.user_id)
  - reviewee_id (FK -> User.user_id)  # host or guest being reviewed
  - rating (1-5)
  - comment
  - created_at

- Cancellation
  - cancellation_id (PK)
  - booking_id (FK -> Booking.booking_id)
  - cancelled_by (FK -> User.user_id)
  - reason
  - created_at

Relationships (high-level):

- User (host) 1..* Property
- Property 1..* Property_Image
- Property *..* Amenity (via Property_Amenity)
- User (guest) 1..* Booking
- Property 1..* Booking
- Booking 1..1 Payment
- Booking 0..1 Review
- Booking 0..1 Cancellation

Cardinalities and constraints:

- A property must have one host (User with is_host = true).
- A booking must reference an existing property and guest user.
- Payment must reference an existing booking.
- Reviews are tied to bookings to ensure only guests who booked can review.

Deliverables:

- A draw.io diagram exported to `ERD/diagram.png` and `ERD/diagram.drawio`.
- `ERD/requirements.md` (this file) describing the entities and relationships.

Notes:

- The diagram file itself isn't created by this script; use Draw.io (https://app.diagrams.net/) to visually create the ERD and export PNG + drawio file.
- Keep the schema normalized to 3NF; document normalization steps in `normalization.md`.
