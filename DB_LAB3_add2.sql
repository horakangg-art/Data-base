ALTER TABLE airport ALTER COLUMN state DROP NOT NULL;
ALTER TABLE airline ALTER COLUMN airline_code DROP NOT NULL;

DROP TABLE IF EXISTS booking_price_backup;

TRUNCATE TABLE security_check, baggage_check, baggage, boarding_pass,
               booking_flight, booking, flights, passengers, airport, airline CASCADE;

-- airport
INSERT INTO airport (airport_id, airport_name, country, state, city, created_at, updated_at)
SELECT
  i,
  'Airport ' || i,
  (ARRAY['Kazakhstan','Turkey','France','Brazil','Poland','UK','USA'])[floor(random()*7+1)],
  CASE WHEN random() > 0.3 THEN 'State ' || i ELSE NULL END,
  (ARRAY['Astana','London','Tokyo','Mlawe','Kepuh','Almaty','Paris'])[floor(random()*7+1)],
  NOW() - (random()*1000 || ' days')::INTERVAL,
  NOW()
FROM generate_series(1, 200) AS i;

-- airline
INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
SELECT
  i,
  CASE WHEN random() > 0.2 THEN 'AC' || i ELSE NULL END,
  'Airline ' || i,
  (ARRAY['Kazakhstan','Turkey','France','Brazil','Poland','Germany'])[floor(random()*6+1)],
  NOW() - (random()*1000 || ' days')::INTERVAL,
  NOW()
FROM generate_series(1, 200) AS i;

-- passengers
INSERT INTO passengers (passenger_id, first_name, last_name, date_of_birth, gender,
                        country_of_citizenship, country_of_residence, passport_number,
                        created_at, updated_at)
SELECT
  i,
  'First_' || i,
  'Last_' || i,
  (DATE '1970-01-01' + floor(random()*12000)::INT),
  CASE WHEN random() > 0.5 THEN 'Male' ELSE 'Female' END,
  'Kazakhstan',
  'Kazakhstan',
  'P' || (10000000 + i),
  NOW(),
  NOW()
FROM generate_series(1, 200) AS i;

-- flights
INSERT INTO flights (flight_id, sch_departure_time, sch_arrival_time,
                     departing_airport_id, arriving_airport_id,
                     departing_gate, arriving_gate, airline_id,
                     act_departure_time, act_arrival_time, created_at, updated_at)
SELECT
  i,
  dep,
  dep + dur,
  dep_ap,
  ((dep_ap + shift) % 200) + 1,
  'A' || (i % 10),
  'B' || (i % 10),
  al,
  dep + delay,
  dep + dur + delay,
  NOW(),
  NOW()
FROM (
  SELECT i,
         TIMESTAMP '2023-01-01' + random()*700 * INTERVAL '1 day' AS dep,
         (random()*9 + 1) * INTERVAL '1 hour'                       AS dur,
         floor(random()*200)::INT + 1                              AS dep_ap,
         floor(random()*199)::INT                                  AS shift,
         floor(random()*200)::INT + 1                              AS al,
         (random()*60) * INTERVAL '1 minute'                       AS delay
  FROM generate_series(1, 200) AS i
) f;

-- booking
INSERT INTO booking (booking_id, flight_id, passenger_id, booking_platform,
                     created_at, updated_at, status, ticket_price)
SELECT
  i,
  floor(random()*200)::INT + 1,
  floor(random()*200)::INT + 1,
  (ARRAY['Website','Mobile App','Agency'])[floor(random()*3+1)],
  NOW(),
  NOW(),
  (ARRAY['Confirmed','Pending','Cancelled'])[floor(random()*3+1)],
  round((random()*20000 + 1000)::numeric, 2)
FROM generate_series(1, 200) AS i;

-- booking_flight
INSERT INTO booking_flight (booking_flight_id, booking_id, flight_id, created_at, updated_at)
SELECT b.booking_id, b.booking_id, b.flight_id, NOW(), NOW()
FROM booking b;

-- boarding_pass
INSERT INTO boarding_pass (boarding_pass_id, booking_id, seat, boarding_time, created_at, updated_at)
SELECT
  b.booking_id,
  b.booking_id,
  (floor(random()*40)+1)::INT::TEXT || (ARRAY['A','B','C','D','E','F'])[floor(random()*6+1)],
  f.sch_departure_time - INTERVAL '1 hour',
  NOW(),
  NOW()
FROM booking b
JOIN flights f ON f.flight_id = b.flight_id;

-- baggage
INSERT INTO baggage (baggage_id, weight_in_kg, created_at, updated_at, booking_id)
SELECT
  b.booking_id,
  round((random()*30 + 2)::numeric, 2),
  NOW(),
  NOW(),
  b.booking_id
FROM booking b;

-- baggage_check
INSERT INTO baggage_check (baggage_check_id, check_result, created_at, updated_at, booking_id, passenger_id)
SELECT
  b.booking_id,
  CASE WHEN b.booking_id % 10 IN (0,1) OR random() > 0.5 THEN 'Not checked' ELSE 'Checked' END,
  CASE
    WHEN b.booking_id % 10 = 0 THEN TIMESTAMP '2024-03-01' + random()*30 * INTERVAL '1 day'
    WHEN b.booking_id % 10 = 1 THEN TIMESTAMP '2023-01-01' + random()*140 * INTERVAL '1 day'
    ELSE TIMESTAMP '2023-01-01' + random()*500 * INTERVAL '1 day'
  END,
  NOW(),
  b.booking_id,
  b.passenger_id
FROM booking b;

-- security_check
INSERT INTO security_check (security_check_id, check_result, created_at, updated_at, passenger_id)
SELECT
  i,
  CASE WHEN random() > 0.1 THEN 'Passed' ELSE 'Failed' END,
  NOW(),
  NOW(),
  i
FROM generate_series(1, 200) AS i;

-- check
SELECT 'airport' AS tbl, COUNT(*) FROM airport
UNION ALL SELECT 'airline',         COUNT(*) FROM airline
UNION ALL SELECT 'passengers',      COUNT(*) FROM passengers
UNION ALL SELECT 'flights',         COUNT(*) FROM flights
UNION ALL SELECT 'booking',         COUNT(*) FROM booking
UNION ALL SELECT 'booking_flight',  COUNT(*) FROM booking_flight
UNION ALL SELECT 'boarding_pass',   COUNT(*) FROM boarding_pass
UNION ALL SELECT 'baggage',         COUNT(*) FROM baggage
UNION ALL SELECT 'baggage_check',   COUNT(*) FROM baggage_check
UNION ALL SELECT 'security_check',  COUNT(*) FROM security_check;