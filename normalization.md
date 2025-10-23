# Normalization to Third Normal Form (3NF)

This document explains the normalization steps taken to ensure the Airbnb-like database design is in 3NF.

Overview of initial entities:
- User(user_id, first_name, last_name, email, phone, password_hash, is_host, created_at, updated_at)
- Property(property_id, host_id, title, description, address_line1, address_line2, city, state, country, postal_code, latitude, longitude, property_type, room_count, bathroom_count, max_guests, price_per_night, is_active, created_at, updated_at)
- Property_Image(image_id, property_id, url, caption, is_primary)
- Amenity(amenity_id, name, description)
- Property_Amenity(property_id, amenity_id)
- Booking(booking_id, property_id, guest_id, start_date, end_date, total_amount, status, created_at, updated_at)
- Payment(payment_id, booking_id, amount, currency, method, status, transaction_id, paid_at)
- Review(review_id, booking_id, reviewer_id, reviewee_id, rating, comment, created_at)
- Cancellation(cancellation_id, booking_id, cancelled_by, reason, created_at)

Normalization steps and rationale:

1. First Normal Form (1NF)
   - Ensured all attributes are atomic. Lists (e.g., multiple phone numbers, multiple amenities) are represented in separate tables (`Amenity`, `Property_Amenity`, `Property_Image`).

2. Second Normal Form (2NF)
   - Ensured no partial dependencies on a composite key. Primary keys are single-column surrogate keys (serial integers or UUIDs). Bridge tables like `Property_Amenity` use composite PKs of their foreign keys; these tables do not contain attributes that depend on only part of the composite key.

3. Third Normal Form (3NF)
   - Removed transitive dependencies: for example, address components remain in `Property` because they directly describe the property; if multiple properties could share the same address record (unlikely), an `Address` table could be extracted—but for clarity and simplicity address fields are kept on `Property`.
   - Denormalized fields like `host_id` stored elsewhere were avoided; `Booking` references `property_id` and `guest_id`; host can be inferred via `Property.host_id`. `host_id` is not stored on `Booking` to avoid update anomalies.
   - Payment references `booking_id`, and payment-specific details stored in `Payment` avoid mixing payment data into `Booking`.

Additional considerations:
- Reviews are linked to `Booking` to ensure only verified stays can be reviewed. The reviewer and reviewee IDs are present in `Review` but the canonical roles are maintained by referencing booking and users.
- `Property_Image` stores images per property and a boolean `is_primary` avoids storing multiple primary image URLs in `Property`.
- For performance, indexes will be added on frequently queried columns such as `User.email` (unique), `Property.city`, `Property.price_per_night`, and `Booking.start_date`/`end_date`.

Conclusion:
The schema follows 3NF: attributes are atomic, there are no partial dependencies on composite keys, and transitive dependencies have been removed or justified. Any future denormalization for performance (e.g., caching host info on `Booking`) must be handled carefully to keep data consistent.
