


-- ===== Task 2: 
DELETE FROM airline WHERE airline_id = 201;          

INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES (201, 'KZA', 'KazAir', 'Kazakhstan', NOW(), NOW());

SELECT * FROM airline WHERE airline_name = 'KazAir';


-- ===== Task 3:
INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES (201, 'KZA', 'KazAir', 'Kazakhstan', NOW(), NOW())
ON CONFLICT (airline_id) DO UPDATE
SET airline_name = 'KazAir', airline_country = 'Kazakhstan';

UPDATE airline
SET airline_country = 'Turkey', updated_at = NOW()
WHERE airline_name = 'KazAir';

SELECT * FROM airline WHERE airline_name = 'KazAir';


-- ===== Task 4: 
DELETE FROM airline WHERE airline_id IN (202, 203, 204);  

INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES
  (202, 'EASY', 'AirEasy', 'France', NOW(), NOW()),
  (203, 'HIGH', 'FlyHigh', 'Brazil', NOW(), NOW()),
  (204, 'FLY',  'FlyFly',  'Poland', NOW(), NOW());

SELECT * FROM airline WHERE airline_id IN (202, 203, 204);


-- ===== Task 5:
BEGIN;

CREATE TEMP TABLE tmp_flights ON COMMIT DROP AS
  SELECT flight_id FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024;
CREATE TEMP TABLE tmp_bookings ON COMMIT DROP AS
  SELECT booking_id FROM booking WHERE flight_id IN (SELECT flight_id FROM tmp_flights);

DELETE FROM baggage_check  WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM baggage        WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM boarding_pass  WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM booking_flight WHERE booking_id IN (SELECT booking_id FROM tmp_bookings)
                              OR flight_id  IN (SELECT flight_id  FROM tmp_flights);
DELETE FROM booking        WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM flights        WHERE flight_id  IN (SELECT flight_id  FROM tmp_flights);

-- Проверка:
SELECT COUNT(*) AS flights_2024_left
FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024;

COMMIT;


-- ===== Task 6: 
CREATE TABLE IF NOT EXISTS booking_price_backup AS
  SELECT booking_id, ticket_price AS original_price FROM booking;

UPDATE booking b
SET ticket_price = ROUND(bp.original_price * 1.15, 2),
    updated_at   = NOW()
FROM booking_price_backup bp
WHERE bp.booking_id = b.booking_id;

SELECT b.booking_id, bp.original_price, b.ticket_price
FROM booking b
JOIN booking_price_backup bp ON bp.booking_id = b.booking_id
ORDER BY b.booking_id
LIMIT 10;


-- ===== Task 7:
BEGIN;

CREATE TEMP TABLE tmp_bookings ON COMMIT DROP AS
  SELECT booking_id FROM booking WHERE ticket_price < 10000;

DELETE FROM baggage_check  WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM baggage        WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM boarding_pass  WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM booking_flight WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM booking        WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);

-- Проверка: должно быть 0
SELECT COUNT(*) AS cheap_tickets_left FROM booking WHERE ticket_price < 10000;

COMMIT;


-- ===== Task 8: 
UPDATE airline
SET airline_code = 'UNK', updated_at = NOW()
WHERE airline_code IS NULL;

ALTER TABLE airline ALTER COLUMN airline_code SET DEFAULT 'UNK';   -

SELECT COUNT(*) AS null_codes_left FROM airline WHERE airline_code IS NULL;
SELECT * FROM airline WHERE airline_code = 'UNK' LIMIT 10;


-- ===== Task 9: 
DELETE FROM baggage_check
WHERE created_at < DATE '2023-06-01'
  AND check_result = 'Not checked';

-- Проверка:
SELECT COUNT(*) AS left_rows
FROM baggage_check
WHERE created_at < DATE '2023-06-01' AND check_result = 'Not checked';


-- ===== Task 10:
BEGIN;

CREATE TEMP TABLE tmp_airports ON COMMIT DROP AS
  SELECT airport_id FROM airport
  WHERE state IS NULL AND city IN ('Mlawe', 'Kepuh');
CREATE TEMP TABLE tmp_flights ON COMMIT DROP AS
  SELECT flight_id FROM flights
  WHERE departing_airport_id IN (SELECT airport_id FROM tmp_airports)
     OR arriving_airport_id  IN (SELECT airport_id FROM tmp_airports);
CREATE TEMP TABLE tmp_bookings ON COMMIT DROP AS
  SELECT booking_id FROM booking WHERE flight_id IN (SELECT flight_id FROM tmp_flights);

DELETE FROM baggage_check  WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM baggage        WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM boarding_pass  WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM booking_flight WHERE booking_id IN (SELECT booking_id FROM tmp_bookings)
                              OR flight_id  IN (SELECT flight_id  FROM tmp_flights);
DELETE FROM booking        WHERE booking_id IN (SELECT booking_id FROM tmp_bookings);
DELETE FROM flights        WHERE flight_id  IN (SELECT flight_id  FROM tmp_flights);
DELETE FROM airport        WHERE airport_id IN (SELECT airport_id FROM tmp_airports);

-- Проверка: 
SELECT COUNT(*) AS airports_left
FROM airport WHERE state IS NULL AND city IN ('Mlawe', 'Kepuh');

COMMIT;


-- ===== Task 11: 
INSERT INTO baggage_check (baggage_check_id, check_result, created_at, updated_at, booking_id, passenger_id)
SELECT (SELECT COALESCE(MAX(baggage_check_id), 0) + 1 FROM baggage_check),
       'Not checked', NOW(), NOW(), booking_id, passenger_id
FROM booking
ORDER BY booking_id
LIMIT 1
RETURNING baggage_check_id, created_at;


-- ===== Task 12: 
UPDATE airline
SET airline_country = UPPER(airline_country),
    updated_at = NOW();

SELECT DISTINCT airline_country FROM airline;


-- ===== Task 13:
UPDATE airline
SET airline_name    = 'Global Airways',
    airline_country = 'United Kingdom',
    updated_at      = NOW()
WHERE airline_id = 5;

SELECT * FROM airline WHERE airline_id = 5;


-- ===== Task 14: 
UPDATE airport
SET state = 'Capital District', updated_at = NOW()
WHERE city IN ('Astana', 'London', 'Tokyo');

SELECT * FROM airport WHERE city IN ('Astana', 'London', 'Tokyo') LIMIT 20;


-- ===== Task 15:
UPDATE baggage_check
SET check_result = 'Checked', updated_at = NOW()
WHERE check_result = 'Not checked'
  AND created_at >= DATE '2024-03-01'
  AND created_at <  DATE '2024-04-01';

-- Проверка: 
SELECT COUNT(*) AS still_not_checked_march_2024
FROM baggage_check
WHERE check_result = 'Not checked'
  AND created_at >= DATE '2024-03-01' AND created_at < DATE '2024-04-01';