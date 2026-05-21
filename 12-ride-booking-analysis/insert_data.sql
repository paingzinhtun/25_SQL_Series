-- Day 12 - Ride Booking Analysis
-- Sample data for PostgreSQL
--
-- All names and trip records are fictional.
-- The data is designed to support revenue, cancellation, route, peak-hour, and rating analysis.

INSERT INTO riders (first_name, last_name, email, phone_number, city, signup_date) VALUES
    ('Aung', 'Thu', 'aung.thu@example.com', '09-420001001', 'Yangon', '2025-10-03'),
    ('May', 'Sandi', 'may.sandi@example.com', '09-420001002', 'Yangon', '2025-10-10'),
    ('Ko', 'Htet', 'ko.htet@example.com', '09-420001003', 'Mandalay', '2025-10-15'),
    ('Su', 'Mon', 'su.mon@example.com', '09-420001004', 'Naypyidaw', '2025-11-01'),
    ('Nandar', 'Aye', 'nandar.aye@example.com', '09-420001005', 'Bago', '2025-11-08'),
    ('Thiri', 'Moe', 'thiri.moe@example.com', '09-420001006', 'Taunggyi', '2025-11-15'),
    ('Kyaw', 'Zin', 'kyaw.zin@example.com', '09-420001007', 'Mawlamyine', '2025-11-20'),
    ('Ei', 'Phyo', 'ei.phyo@example.com', '09-420001008', 'Yangon', '2025-12-02'),
    ('Zaw', 'Min', 'zaw.min@example.com', '09-420001009', 'Pathein', '2025-12-07'),
    ('Hnin', 'Wai', 'hnin.wai@example.com', '09-420001010', 'Mandalay', '2025-12-12'),
    ('Myo', 'Thant', 'myo.thant@example.com', '09-420001011', 'Yangon', '2025-12-18'),
    ('Yu', 'Waddy', 'yu.waddy@example.com', '09-420001012', 'Taunggyi', '2026-01-03'),
    ('Lin', 'Htet', 'lin.htet@example.com', '09-420001013', 'Naypyidaw', '2026-01-08'),
    ('Wai', 'Yan', 'wai.yan@example.com', '09-420001014', 'Bago', '2026-01-12'),
    ('Khin', 'Hlaing', 'khin.hlaing@example.com', '09-420001015', 'Mawlamyine', '2026-01-18'),
    ('Sai', 'Tun', 'sai.tun@example.com', '09-420001016', 'Taunggyi', '2026-01-22'),
    ('Mya', 'Hnin', 'mya.hnin@example.com', '09-420001017', 'Yangon', '2026-02-01'),
    ('Phyo', 'Paing', 'phyo.paing@example.com', '09-420001018', 'Mandalay', '2026-02-05'),
    ('Nyein', 'Chan', 'nyein.chan@example.com', '09-420001019', 'Pathein', '2026-02-12'),
    ('Su', 'Hnin', 'su.hnin@example.com', '09-420001020', 'Bago', '2026-02-18'),
    ('Yamin', 'Oo', 'yamin.oo@example.com', '09-420001021', 'Yangon', '2026-03-01'),
    ('Thiha', 'Zaw', 'thiha.zaw@example.com', '09-420001022', 'Yangon', '2026-03-06');

INSERT INTO drivers (first_name, last_name, phone_number, city, join_date, driver_status) VALUES
    ('Min', 'Ko', '09-430001001', 'Yangon', '2024-05-10', 'active'),
    ('Htet', 'Aung', '09-430001002', 'Mandalay', '2024-06-15', 'active'),
    ('Nyi', 'Nyi', '09-430001003', 'Naypyidaw', '2024-07-01', 'active'),
    ('Zaw', 'Lin', '09-430001004', 'Bago', '2024-08-12', 'active'),
    ('Kyaw', 'Kyaw', '09-430001005', 'Taunggyi', '2024-09-05', 'active'),
    ('Tun', 'Tun', '09-430001006', 'Mawlamyine', '2024-10-08', 'active'),
    ('Myo', 'Min', '09-430001007', 'Yangon', '2024-11-20', 'inactive'),
    ('Sai', 'Htun', '09-430001008', 'Taunggyi', '2024-12-01', 'active'),
    ('Aung', 'Naing', '09-430001009', 'Pathein', '2025-01-15', 'suspended'),
    ('Lin', 'Aung', '09-430001010', 'Yangon', '2025-02-05', 'active'),
    ('Nanda', 'Soe', '09-430001011', 'Mandalay', '2025-03-14', 'inactive'),
    ('Paing', 'Soe', '09-430001012', 'Bago', '2025-04-22', 'suspended');

INSERT INTO vehicles (driver_id, vehicle_type, vehicle_model, plate_number) VALUES
    (1, 'private_car', 'Toyota Axio', 'YGN-1A-2301'),
    (2, 'taxi', 'Toyota Probox', 'MDY-2B-1302'),
    (3, 'premium', 'Toyota Crown', 'NPY-3C-4503'),
    (4, 'private_car', 'Honda Fit', 'BGO-4D-1104'),
    (5, 'taxi', 'Toyota Corolla', 'TGI-5E-9005'),
    (6, 'motorcycle', 'Honda Click', 'MLM-6F-7606'),
    (7, 'private_car', 'Nissan AD Van', 'YGN-7G-3307'),
    (8, 'premium', 'Toyota Harrier', 'TGI-8H-2208'),
    (9, 'taxi', 'Toyota Belta', 'PTN-9I-8809'),
    (10, 'private_car', 'Suzuki Swift', 'YGN-10J-6410'),
    (11, 'motorcycle', 'Yamaha Gear', 'MDY-11K-5511'),
    (12, 'taxi', 'Toyota Succeed', 'BGO-12L-4112');

INSERT INTO locations (location_name, city, location_type) VALUES
    ('Yangon Downtown', 'Yangon', 'business'),
    ('Yangon International Airport', 'Yangon', 'airport'),
    ('Junction City', 'Yangon', 'mall'),
    ('Hledan Center', 'Yangon', 'business'),
    ('Mandalay Palace Area', 'Mandalay', 'other'),
    ('Mandalay Highway Bus Station', 'Mandalay', 'bus_station'),
    ('Naypyidaw Hotel Zone', 'Naypyidaw', 'hotel'),
    ('Bago Market', 'Bago', 'business'),
    ('Taunggyi City Center', 'Taunggyi', 'business'),
    ('Mawlamyine Strand Road', 'Mawlamyine', 'business'),
    ('Pathein Riverfront', 'Pathein', 'other'),
    ('Yangon General Hospital', 'Yangon', 'other'),
    ('Thaketa Township', 'Yangon', 'residential'),
    ('Inya Lake Hotel Area', 'Yangon', 'hotel');

INSERT INTO trips (
    rider_id,
    driver_id,
    pickup_location_id,
    dropoff_location_id,
    booking_time,
    pickup_time,
    dropoff_time,
    trip_status,
    cancelled_by,
    cancellation_reason,
    distance_km,
    duration_minutes,
    fare_amount
) VALUES
    (1, 1, 1, 2, '2026-01-05 07:45:00+06:30', '2026-01-05 07:50:00+06:30', '2026-01-05 08:20:00+06:30', 'completed', NULL, NULL, 15.20, 30, 18500.00),
    (2, 1, 3, 4, '2026-01-05 08:20:00+06:30', '2026-01-05 08:25:00+06:30', '2026-01-05 08:43:00+06:30', 'completed', NULL, NULL, 4.80, 18, 6500.00),
    (3, 2, 5, 6, '2026-01-06 09:15:00+06:30', '2026-01-06 09:21:00+06:30', '2026-01-06 09:43:00+06:30', 'completed', NULL, NULL, 6.20, 22, 8200.00),
    (4, 3, 7, 8, '2026-01-06 10:30:00+06:30', '2026-01-06 10:37:00+06:30', '2026-01-06 11:12:00+06:30', 'completed', NULL, NULL, 18.40, 35, 21000.00),
    (5, 4, 8, 7, '2026-01-07 11:45:00+06:30', NULL, NULL, 'cancelled', 'rider', 'Rider changed travel plan', NULL, NULL, 0.00),
    (1, 2, 1, 3, '2026-01-07 17:10:00+06:30', '2026-01-07 17:17:00+06:30', '2026-01-07 17:48:00+06:30', 'completed', NULL, NULL, 8.90, 31, 12500.00),
    (6, 5, 9, 10, '2026-01-08 18:05:00+06:30', '2026-01-08 18:12:00+06:30', '2026-01-08 18:40:00+06:30', 'completed', NULL, NULL, 12.50, 28, 15000.00),
    (7, 6, 10, 9, '2026-01-08 19:40:00+06:30', '2026-01-08 19:46:00+06:30', '2026-01-08 20:18:00+06:30', 'completed', NULL, NULL, 11.80, 32, 14600.00),
    (8, 7, 13, 1, '2026-01-09 20:15:00+06:30', NULL, NULL, 'requested', NULL, NULL, NULL, NULL, 0.00),
    (9, 8, 14, 3, '2026-01-10 06:30:00+06:30', '2026-01-10 06:37:00+06:30', '2026-01-10 06:57:00+06:30', 'completed', NULL, NULL, 7.20, 20, 9200.00),
    (10, 9, 11, 6, '2026-01-10 12:30:00+06:30', '2026-01-10 12:38:00+06:30', '2026-01-10 13:18:00+06:30', 'completed', NULL, NULL, 14.50, 40, 17800.00),
    (11, 10, 2, 1, '2026-01-11 22:15:00+06:30', '2026-01-11 22:21:00+06:30', '2026-01-11 22:48:00+06:30', 'completed', NULL, NULL, 15.10, 27, 19000.00),
    (2, 1, 4, 3, '2026-01-12 07:50:00+06:30', '2026-01-12 07:55:00+06:30', '2026-01-12 08:14:00+06:30', 'completed', NULL, NULL, 5.00, 19, 6800.00),
    (12, 5, 9, 7, '2026-01-12 08:35:00+06:30', '2026-01-12 08:45:00+06:30', '2026-01-12 09:40:00+06:30', 'completed', NULL, NULL, 25.00, 55, 32000.00),
    (13, 3, 7, 14, '2026-01-13 09:45:00+06:30', NULL, NULL, 'cancelled', 'driver', 'Driver reported vehicle issue', NULL, NULL, 0.00),
    (14, 4, 8, 5, '2026-01-13 16:25:00+06:30', '2026-01-13 16:33:00+06:30', NULL, 'in_progress', NULL, NULL, NULL, NULL, 0.00),
    (1, 1, 1, 2, '2026-01-14 18:10:00+06:30', '2026-01-14 18:16:00+06:30', '2026-01-14 18:50:00+06:30', 'completed', NULL, NULL, 15.00, 34, 18800.00),
    (15, 6, 10, 11, '2026-01-15 18:45:00+06:30', '2026-01-15 18:52:00+06:30', '2026-01-15 19:17:00+06:30', 'completed', NULL, NULL, 10.20, 25, 13000.00),
    (16, 9, 11, 10, '2026-01-15 21:00:00+06:30', '2026-01-15 21:07:00+06:30', '2026-01-15 21:31:00+06:30', 'completed', NULL, NULL, 9.90, 24, 12400.00),
    (3, 2, 5, 6, '2026-01-16 08:05:00+06:30', '2026-01-16 08:10:00+06:30', '2026-01-16 08:30:00+06:30', 'completed', NULL, NULL, 6.00, 20, 8000.00),
    (17, 8, 14, 13, '2026-01-16 08:45:00+06:30', NULL, NULL, 'cancelled', 'system', 'No nearby driver accepted the trip', NULL, NULL, 0.00),
    (18, 10, 2, 12, '2026-01-17 13:10:00+06:30', '2026-01-17 13:17:00+06:30', '2026-01-17 14:00:00+06:30', 'completed', NULL, NULL, 19.60, 43, 24500.00),
    (19, 5, 9, 10, '2026-01-18 15:35:00+06:30', '2026-01-18 15:41:00+06:30', '2026-01-18 16:10:00+06:30', 'completed', NULL, NULL, 12.70, 29, 15200.00),
    (20, 12, 8, 7, '2026-01-18 17:20:00+06:30', NULL, NULL, 'cancelled', 'rider', 'Fare was higher than expected', NULL, NULL, 0.00),
    (22, 1, 3, 4, '2026-01-19 17:55:00+06:30', '2026-01-19 18:01:00+06:30', '2026-01-19 18:17:00+06:30', 'completed', NULL, NULL, 4.50, 16, 6200.00),
    (2, 1, 1, 2, '2026-02-01 07:30:00+06:30', '2026-02-01 07:36:00+06:30', '2026-02-01 08:08:00+06:30', 'completed', NULL, NULL, 15.30, 32, 18700.00),
    (4, 3, 7, 8, '2026-02-01 08:15:00+06:30', '2026-02-01 08:24:00+06:30', '2026-02-01 08:58:00+06:30', 'completed', NULL, NULL, 18.10, 34, 20800.00),
    (5, 4, 8, 7, '2026-02-02 10:50:00+06:30', '2026-02-02 10:58:00+06:30', '2026-02-02 11:32:00+06:30', 'completed', NULL, NULL, 18.00, 34, 20500.00),
    (6, 5, 9, 10, '2026-02-02 11:35:00+06:30', '2026-02-02 11:42:00+06:30', '2026-02-02 12:10:00+06:30', 'completed', NULL, NULL, 12.40, 28, 14900.00),
    (1, 2, 5, 6, '2026-02-03 12:20:00+06:30', '2026-02-03 12:25:00+06:30', '2026-02-03 12:46:00+06:30', 'completed', NULL, NULL, 6.10, 21, 8200.00),
    (7, 6, 10, 9, '2026-02-03 13:05:00+06:30', '2026-02-03 13:12:00+06:30', '2026-02-03 13:45:00+06:30', 'completed', NULL, NULL, 11.90, 33, 14700.00),
    (8, 7, 13, 1, '2026-02-04 14:40:00+06:30', '2026-02-04 14:47:00+06:30', '2026-02-04 15:18:00+06:30', 'completed', NULL, NULL, 9.20, 31, 11800.00),
    (9, 8, 14, 3, '2026-02-04 16:05:00+06:30', '2026-02-04 16:12:00+06:30', '2026-02-04 16:34:00+06:30', 'completed', NULL, NULL, 7.40, 22, 9400.00),
    (10, 9, 11, 6, '2026-02-05 17:25:00+06:30', '2026-02-05 17:32:00+06:30', '2026-02-05 18:12:00+06:30', 'completed', NULL, NULL, 14.60, 40, 17900.00),
    (11, 10, 2, 1, '2026-02-05 18:30:00+06:30', '2026-02-05 18:36:00+06:30', '2026-02-05 19:05:00+06:30', 'completed', NULL, NULL, 15.20, 29, 19200.00),
    (12, 5, 9, 7, '2026-02-06 19:15:00+06:30', '2026-02-06 19:25:00+06:30', '2026-02-06 20:20:00+06:30', 'completed', NULL, NULL, 25.40, 55, 32500.00),
    (13, 3, 7, 14, '2026-02-07 20:25:00+06:30', '2026-02-07 20:34:00+06:30', '2026-02-07 21:10:00+06:30', 'completed', NULL, NULL, 17.80, 36, 21400.00),
    (14, 4, 8, 5, '2026-02-07 21:05:00+06:30', NULL, NULL, 'cancelled', 'system', 'Payment authorization failed', NULL, NULL, 0.00),
    (15, 6, 10, 11, '2026-02-08 22:20:00+06:30', '2026-02-08 22:28:00+06:30', '2026-02-08 22:54:00+06:30', 'completed', NULL, NULL, 10.30, 26, 13200.00),
    (16, 9, 11, 10, '2026-02-09 06:50:00+06:30', '2026-02-09 06:56:00+06:30', '2026-02-09 07:20:00+06:30', 'completed', NULL, NULL, 9.80, 24, 12300.00),
    (1, 1, 1, 2, '2026-03-01 07:55:00+06:30', '2026-03-01 08:00:00+06:30', '2026-03-01 08:33:00+06:30', 'completed', NULL, NULL, 15.10, 33, 18900.00),
    (2, 2, 5, 6, '2026-03-01 08:25:00+06:30', '2026-03-01 08:31:00+06:30', '2026-03-01 08:52:00+06:30', 'completed', NULL, NULL, 6.20, 21, 8300.00),
    (3, 3, 7, 8, '2026-03-02 09:10:00+06:30', '2026-03-02 09:18:00+06:30', '2026-03-02 09:54:00+06:30', 'completed', NULL, NULL, 18.20, 36, 21100.00),
    (4, 4, 8, 7, '2026-03-02 10:15:00+06:30', '2026-03-02 10:23:00+06:30', '2026-03-02 10:58:00+06:30', 'completed', NULL, NULL, 18.10, 35, 20700.00),
    (5, 5, 9, 10, '2026-03-03 11:20:00+06:30', '2026-03-03 11:27:00+06:30', '2026-03-03 11:56:00+06:30', 'completed', NULL, NULL, 12.60, 29, 15100.00),
    (6, 6, 10, 9, '2026-03-03 12:30:00+06:30', '2026-03-03 12:38:00+06:30', '2026-03-03 13:12:00+06:30', 'completed', NULL, NULL, 12.00, 34, 14800.00),
    (7, 7, 13, 1, '2026-03-04 13:30:00+06:30', NULL, NULL, 'cancelled', 'driver', 'Driver cancelled from app issue', NULL, NULL, 0.00),
    (8, 8, 14, 3, '2026-03-04 14:45:00+06:30', '2026-03-04 14:52:00+06:30', '2026-03-04 15:16:00+06:30', 'completed', NULL, NULL, 7.30, 24, 9300.00),
    (9, 9, 11, 6, '2026-03-05 15:50:00+06:30', '2026-03-05 15:58:00+06:30', '2026-03-05 16:40:00+06:30', 'completed', NULL, NULL, 14.70, 42, 18100.00),
    (20, 12, 8, 7, '2026-03-05 16:15:00+06:30', NULL, NULL, 'requested', NULL, NULL, NULL, NULL, 0.00),
    (10, 10, 2, 1, '2026-03-06 17:00:00+06:30', '2026-03-06 17:06:00+06:30', '2026-03-06 17:36:00+06:30', 'completed', NULL, NULL, 15.30, 30, 19300.00),
    (11, 1, 3, 4, '2026-03-06 18:05:00+06:30', '2026-03-06 18:11:00+06:30', '2026-03-06 18:29:00+06:30', 'completed', NULL, NULL, 4.70, 18, 6500.00),
    (12, 2, 5, 6, '2026-03-07 18:45:00+06:30', '2026-03-07 18:52:00+06:30', '2026-03-07 19:14:00+06:30', 'completed', NULL, NULL, 6.30, 22, 8500.00),
    (13, 3, 7, 14, '2026-03-07 19:20:00+06:30', '2026-03-07 19:28:00+06:30', '2026-03-07 20:05:00+06:30', 'completed', NULL, NULL, 17.90, 37, 21500.00),
    (14, 12, 8, 5, '2026-03-08 20:00:00+06:30', NULL, NULL, 'cancelled', 'driver', 'Driver did not respond after assignment', NULL, NULL, 0.00),
    (15, 4, 8, 7, '2026-03-08 20:35:00+06:30', '2026-03-08 20:43:00+06:30', '2026-03-08 21:18:00+06:30', 'completed', NULL, NULL, 18.20, 35, 20900.00),
    (16, 5, 9, 10, '2026-03-09 21:10:00+06:30', '2026-03-09 21:17:00+06:30', '2026-03-09 21:47:00+06:30', 'completed', NULL, NULL, 12.80, 30, 15400.00),
    (17, 6, 10, 9, '2026-03-09 22:00:00+06:30', '2026-03-09 22:08:00+06:30', '2026-03-09 22:44:00+06:30', 'completed', NULL, NULL, 12.10, 36, 15000.00),
    (18, 8, 14, 13, '2026-03-10 07:20:00+06:30', '2026-03-10 07:27:00+06:30', '2026-03-10 07:53:00+06:30', 'completed', NULL, NULL, 8.60, 26, 11200.00),
    (19, 9, 11, 6, '2026-03-10 08:10:00+06:30', NULL, NULL, 'cancelled', 'rider', 'Rider waited too long', NULL, NULL, 0.00),
    (20, 11, 1, 12, '2026-03-11 08:35:00+06:30', '2026-03-11 08:43:00+06:30', NULL, 'in_progress', NULL, NULL, NULL, NULL, 0.00),
    (22, 1, 1, 2, '2026-03-11 17:15:00+06:30', '2026-03-11 17:21:00+06:30', '2026-03-11 17:55:00+06:30', 'completed', NULL, NULL, 15.40, 34, 19100.00),
    (22, 2, 3, 4, '2026-03-12 17:45:00+06:30', '2026-03-12 17:51:00+06:30', '2026-03-12 18:10:00+06:30', 'completed', NULL, NULL, 4.60, 19, 6400.00),
    (18, 12, 8, 7, '2026-03-12 18:10:00+06:30', '2026-03-12 18:18:00+06:30', NULL, 'in_progress', NULL, NULL, NULL, NULL, 0.00),
    (19, 11, 5, 6, '2026-03-13 19:00:00+06:30', NULL, NULL, 'requested', NULL, NULL, NULL, NULL, 0.00);

-- One payment row is generated for every trip.
-- Revenue queries count only trips where trip_status = 'completed' and payment_status = 'paid'.
INSERT INTO payments (trip_id, payment_date, payment_method, payment_status, amount)
SELECT
    t.trip_id,
    COALESCE(t.dropoff_time::date, t.booking_time::date) AS payment_date,
    CASE
        WHEN t.trip_id % 4 = 0 THEN 'card'
        WHEN t.trip_id % 4 = 1 THEN 'mobile_wallet'
        WHEN t.trip_id % 4 = 2 THEN 'bank_transfer'
        ELSE 'cash'
    END AS payment_method,
    CASE
        WHEN t.trip_status = 'completed' AND t.trip_id IN (18, 39) THEN 'failed'
        WHEN t.trip_status = 'completed' THEN 'paid'
        WHEN t.trip_status = 'cancelled' AND t.trip_id % 2 = 0 THEN 'refunded'
        WHEN t.trip_status = 'cancelled' THEN 'failed'
        ELSE 'unpaid'
    END AS payment_status,
    CASE
        WHEN t.trip_status = 'completed' AND t.trip_id NOT IN (18, 39) THEN t.fare_amount
        WHEN t.trip_status = 'cancelled' AND t.trip_id % 2 = 0 THEN t.fare_amount
        ELSE 0
    END AS amount
FROM trips AS t;

-- Ratings are generated for completed trips.
-- Drivers 6 and 9 intentionally have lower ratings to support low-rating analysis.
INSERT INTO trip_ratings (
    trip_id,
    rider_id,
    driver_id,
    rider_rating,
    driver_rating,
    review_text,
    rating_date
)
SELECT
    t.trip_id,
    t.rider_id,
    t.driver_id,
    CASE
        WHEN t.rider_id IN (20, 21) THEN 3.0
        WHEN t.trip_id % 5 = 0 THEN 4.0
        ELSE 4.5
    END AS rider_rating,
    CASE
        WHEN t.driver_id = 6 THEN 2.8
        WHEN t.driver_id = 9 THEN 3.1
        WHEN t.trip_id % 6 = 0 THEN 4.0
        ELSE 4.6
    END AS driver_rating,
    CASE
        WHEN t.driver_id IN (6, 9) THEN 'Trip completed, but service quality needs improvement.'
        WHEN t.trip_id % 6 = 0 THEN 'Good trip with minor delay.'
        ELSE 'Smooth ride and professional service.'
    END AS review_text,
    t.dropoff_time::date AS rating_date
FROM trips AS t
WHERE t.trip_status = 'completed';
