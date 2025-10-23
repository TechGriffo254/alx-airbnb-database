-- Schema for ALX Airbnb-like application (PostgreSQL)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users
CREATE TABLE IF NOT EXISTS "user" (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    phone TEXT,
    password_hash TEXT NOT NULL,
    is_host BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Properties
CREATE TABLE IF NOT EXISTS property (
    property_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    host_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    address_line1 TEXT NOT NULL,
    address_line2 TEXT,
    city TEXT NOT NULL,
    state TEXT,
    country TEXT NOT NULL,
    postal_code TEXT,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6),
    property_type TEXT,
    room_count INTEGER DEFAULT 1,
    bathroom_count INTEGER DEFAULT 1,
    max_guests INTEGER DEFAULT 1,
    price_per_night NUMERIC(10,2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Property images
CREATE TABLE IF NOT EXISTS property_image (
    image_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL REFERENCES property(property_id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    caption TEXT,
    is_primary BOOLEAN DEFAULT FALSE
);

-- Amenities
CREATE TABLE IF NOT EXISTS amenity (
    amenity_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT
);

-- Bridge table for property amenities
CREATE TABLE IF NOT EXISTS property_amenity (
    property_id UUID NOT NULL REFERENCES property(property_id) ON DELETE CASCADE,
    amenity_id UUID NOT NULL REFERENCES amenity(amenity_id) ON DELETE CASCADE,
    PRIMARY KEY (property_id, amenity_id)
);

-- Bookings
CREATE TABLE IF NOT EXISTS booking (
    booking_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    property_id UUID NOT NULL REFERENCES property(property_id) ON DELETE CASCADE,
    guest_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    CONSTRAINT chk_dates CHECK (end_date >= start_date)
);

-- Payments
CREATE TABLE IF NOT EXISTS payment (
    payment_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES booking(booking_id) ON DELETE CASCADE,
    amount NUMERIC(12,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'USD',
    method TEXT,
    status TEXT NOT NULL DEFAULT 'pending',
    transaction_id TEXT,
    paid_at TIMESTAMP WITH TIME ZONE
);

-- Reviews
CREATE TABLE IF NOT EXISTS review (
    review_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES booking(booking_id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    reviewee_id UUID NOT NULL REFERENCES "user"(user_id) ON DELETE CASCADE,
    rating SMALLINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Cancellations
CREATE TABLE IF NOT EXISTS cancellation (
    cancellation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    booking_id UUID NOT NULL REFERENCES booking(booking_id) ON DELETE CASCADE,
    cancelled_by UUID NOT NULL REFERENCES "user"(user_id) ON DELETE SET NULL,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_email ON "user" (email);
CREATE INDEX IF NOT EXISTS idx_property_city_price ON property (city, price_per_night);
CREATE INDEX IF NOT EXISTS idx_booking_dates ON booking (start_date, end_date);

-- Trigger to update updated_at on changes
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_user
BEFORE UPDATE ON "user"
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TRIGGER set_timestamp_property
BEFORE UPDATE ON property
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

CREATE TRIGGER set_timestamp_booking
BEFORE UPDATE ON booking
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();
