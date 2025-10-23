-- Seed data for ALX Airbnb-like app (PostgreSQL)

-- Clear tables (careful in production)
TRUNCATE TABLE cancellation, review, payment, booking, property_amenity, amenity, property_image, property, "user" RESTART IDENTITY CASCADE;

-- Users
INSERT INTO "user" (user_id, first_name, last_name, email, phone, password_hash, is_host, created_at)
VALUES
('11111111-1111-1111-1111-111111111111','Alice','Anderson','alice@example.com','+15551234567','hash_alice',true, now()),
('22222222-2222-2222-2222-222222222222','Bob','Brown','bob@example.com','+15557654321','hash_bob',false, now()),
('33333333-3333-3333-3333-333333333333','Carol','Clark','carol@example.com','+15559876543','hash_carol',true, now());

-- Properties
INSERT INTO property (property_id, host_id, title, description, address_line1, city, state, country, postal_code, latitude, longitude, property_type, room_count, bathroom_count, max_guests, price_per_night, is_active)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','11111111-1111-1111-1111-111111111111','Downtown Apartment','Cozy 2BR in downtown','123 Main St','Metropolis','MetroState','Freedonia','12345',40.712776,-74.005974,'Apartment',2,1,4,120.00,true),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','33333333-3333-3333-3333-333333333333','Beach House','Oceanfront house with deck','456 Beach Ave','Seaside','Coast','Freedonia','67890',34.019454,-118.491191,'House',3,2,6,350.00,true);

-- Property Images
INSERT INTO property_image (image_id, property_id, url, caption, is_primary)
VALUES
('d1d1d1d1-d1d1-d1d1-d1d1-d1d1d1d1d1d1','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','https://example.com/images/apartment1.jpg','Living room',true),
('d2d2d2d2-d2d2-d2d2-d2d2-d2d2d2d2d2d2','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','https://example.com/images/beachhouse1.jpg','Front view',true);

-- Amenities
INSERT INTO amenity (amenity_id, name, description)
VALUES
('e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1','Wifi','High-speed wireless internet'),
('e2e2e2e2-e2e2-e2e2-e2e2-e2e2e2e2e2e2','Kitchen','Full kitchen with appliances');

-- Property Amenities
INSERT INTO property_amenity (property_id, amenity_id)
VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1'),
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','e2e2e2e2-e2e2-e2e2-e2e2-e2e2e2e2e2e2'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','e1e1e1e1-e1e1-e1e1-e1e1-e1e1e1e1e1e1');

-- Bookings
INSERT INTO booking (booking_id, property_id, guest_id, start_date, end_date, total_amount, status, created_at)
VALUES
('f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1','aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa','22222222-2222-2222-2222-222222222222','2025-11-01','2025-11-05',480.00,'confirmed', now()),
('f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2','bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb','22222222-2222-2222-2222-222222222222','2025-12-20','2025-12-27',2450.00,'pending', now());

-- Payments
INSERT INTO payment (payment_id, booking_id, amount, currency, method, status, transaction_id, paid_at)
VALUES
('p1p1p1p1-p1p1-p1p1-p1p1-p1p1p1p1p1p1','f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1',480.00,'USD','card','paid','txn_12345', now());

-- Reviews
INSERT INTO review (review_id, booking_id, reviewer_id, reviewee_id, rating, comment, created_at)
VALUES
('r1r1r1r1-r1r1-r1r1-r1r1-r1r1r1r1r1r1','f1f1f1f1-f1f1-f1f1-f1f1-f1f1f1f1f1f1','22222222-2222-2222-2222-222222222222','11111111-1111-1111-1111-111111111111',5,'Great stay, very cozy!', now());

-- Cancellations
INSERT INTO cancellation (cancellation_id, booking_id, cancelled_by, reason, created_at)
VALUES
('c1c1c1c1-c1c1-c1c1-c1c1-c1c1c1c1c1c1','f2f2f2f2-f2f2-f2f2-f2f2-f2f2f2f2f2f2','22222222-2222-2222-2222-222222222222','Change of plans', now());

-- Done
