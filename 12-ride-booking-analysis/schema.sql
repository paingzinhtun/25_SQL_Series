-- Day 12 - Ride Booking Analysis
-- PostgreSQL schema

DROP TABLE IF EXISTS trip_ratings;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS trips;
DROP TABLE IF EXISTS locations;
DROP TABLE IF EXISTS vehicles;
DROP TABLE IF EXISTS drivers;
DROP TABLE IF EXISTS riders;

CREATE TABLE riders (
    rider_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    phone_number VARCHAR(30),
    city VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone_number VARCHAR(30) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    join_date DATE NOT NULL,
    driver_status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_drivers_status
        CHECK (driver_status IN ('active', 'inactive', 'suspended'))
);

CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    driver_id INTEGER NOT NULL UNIQUE,
    vehicle_type VARCHAR(30) NOT NULL,
    vehicle_model VARCHAR(80) NOT NULL,
    plate_number VARCHAR(30) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_vehicles_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers (driver_id),

    CONSTRAINT chk_vehicles_type
        CHECK (vehicle_type IN ('taxi', 'private_car', 'motorcycle', 'premium'))
);

CREATE TABLE locations (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(120) NOT NULL,
    city VARCHAR(80) NOT NULL,
    location_type VARCHAR(30) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_locations_type
        CHECK (location_type IN ('residential', 'business', 'airport', 'mall', 'hotel', 'bus_station', 'other')),

    CONSTRAINT uq_locations_name_city
        UNIQUE (location_name, city)
);

CREATE TABLE trips (
    trip_id SERIAL PRIMARY KEY,
    rider_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    pickup_location_id INTEGER NOT NULL,
    dropoff_location_id INTEGER NOT NULL,
    booking_time TIMESTAMPTZ NOT NULL,
    pickup_time TIMESTAMPTZ,
    dropoff_time TIMESTAMPTZ,
    trip_status VARCHAR(20) NOT NULL,
    cancelled_by VARCHAR(20),
    cancellation_reason VARCHAR(150),
    distance_km NUMERIC(6, 2),
    duration_minutes INTEGER,
    fare_amount NUMERIC(10, 2) NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_trips_rider
        FOREIGN KEY (rider_id)
        REFERENCES riders (rider_id),

    CONSTRAINT fk_trips_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers (driver_id),

    CONSTRAINT fk_trips_pickup_location
        FOREIGN KEY (pickup_location_id)
        REFERENCES locations (location_id),

    CONSTRAINT fk_trips_dropoff_location
        FOREIGN KEY (dropoff_location_id)
        REFERENCES locations (location_id),

    CONSTRAINT chk_trips_status
        CHECK (trip_status IN ('completed', 'cancelled', 'requested', 'in_progress')),

    CONSTRAINT chk_trips_cancelled_by
        CHECK (cancelled_by IS NULL OR cancelled_by IN ('rider', 'driver', 'system')),

    CONSTRAINT chk_trips_distance
        CHECK (distance_km IS NULL OR distance_km >= 0),

    CONSTRAINT chk_trips_duration
        CHECK (duration_minutes IS NULL OR duration_minutes >= 0),

    CONSTRAINT chk_trips_fare
        CHECK (fare_amount >= 0),

    CONSTRAINT chk_trips_cancelled_fields
        CHECK (
            (
                trip_status = 'cancelled'
                AND cancelled_by IS NOT NULL
                AND cancellation_reason IS NOT NULL
            )
            OR
            (
                trip_status <> 'cancelled'
                AND cancelled_by IS NULL
                AND cancellation_reason IS NULL
            )
        ),

    CONSTRAINT chk_trips_completed_values
        CHECK (
            trip_status <> 'completed'
            OR
            (
                pickup_time IS NOT NULL
                AND dropoff_time IS NOT NULL
                AND distance_km IS NOT NULL
                AND duration_minutes IS NOT NULL
                AND fare_amount > 0
            )
        ),

    CONSTRAINT chk_trips_different_locations
        CHECK (pickup_location_id <> dropoff_location_id)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL UNIQUE,
    payment_date DATE NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,

    CONSTRAINT fk_payments_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips (trip_id),

    CONSTRAINT chk_payments_method
        CHECK (payment_method IN ('cash', 'card', 'mobile_wallet', 'bank_transfer')),

    CONSTRAINT chk_payments_status
        CHECK (payment_status IN ('paid', 'unpaid', 'refunded', 'failed')),

    CONSTRAINT chk_payments_amount
        CHECK (amount >= 0)
);

CREATE TABLE trip_ratings (
    rating_id SERIAL PRIMARY KEY,
    trip_id INTEGER NOT NULL UNIQUE,
    rider_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    rider_rating NUMERIC(2, 1) NOT NULL,
    driver_rating NUMERIC(2, 1) NOT NULL,
    review_text TEXT,
    rating_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_trip_ratings_trip
        FOREIGN KEY (trip_id)
        REFERENCES trips (trip_id),

    CONSTRAINT fk_trip_ratings_rider
        FOREIGN KEY (rider_id)
        REFERENCES riders (rider_id),

    CONSTRAINT fk_trip_ratings_driver
        FOREIGN KEY (driver_id)
        REFERENCES drivers (driver_id),

    CONSTRAINT chk_trip_ratings_rider_rating
        CHECK (rider_rating BETWEEN 1 AND 5),

    CONSTRAINT chk_trip_ratings_driver_rating
        CHECK (driver_rating BETWEEN 1 AND 5)
);
