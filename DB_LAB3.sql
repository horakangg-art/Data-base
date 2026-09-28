-- 1. Выполняем структурные изменения и снимаем ограничения NOT NULL
ALTER TABLE airline_info RENAME TO airline;
ALTER TABLE booking RENAME COLUMN price TO ticket_price;
ALTER TABLE flights ALTER COLUMN departing_gate TYPE TEXT;
ALTER TABLE airline DROP COLUMN IF EXISTS info;

ALTER TABLE airport ALTER COLUMN state DROP NOT NULL;
ALTER TABLE airline ALTER COLUMN airline_code DROP NOT NULL;

-- 2. Очищаем все таблицы перед заполнением
TRUNCATE TABLE baggage_check, baggage, boarding_pass, booking_flight, booking, flights, passengers, airport, airline RESTART IDENTITY CASCADE;

-- 3. Генерация 200 записей для аэропортов
INSERT INTO airport (airport_id, airport_name, country, state, city, created_at, updated_at)
SELECT 
  i,
  'Airport ' || i,
  (ARRAY['Kazakhstan', 'Turkey', 'France', 'Brazil', 'Poland', 'UK', 'USA'])[floor(random() * 7 + 1)],
  CASE WHEN random() > 0.3 THEN 'State ' || i ELSE NULL END,
  (ARRAY['Astana', 'London', 'Tokyo', 'Mlawe', 'Kepuh', 'Almaty', 'Paris'])[floor(random() * 7 + 1)],
  NOW() - (random() * 1000 || ' days')::INTERVAL,
  NOW()
FROM generate_series(1, 200) AS i;

-- 4. Генерация 200 записей для авиакомпаний
INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
SELECT 
  i,
  CASE WHEN random() > 0.2 THEN 'AC' || i ELSE NULL END,
  'Airline ' || i,
  (ARRAY['Kazakhstan', 'Turkey', 'France', 'Brazil', 'Poland', 'Germany'])[floor(random() * 6 + 1)],
  NOW() - (random() * 1000 || ' days')::INTERVAL,
  NOW()
FROM generate_series(1, 200) AS i;

-- 5. Генерация 200 записей для пассажиров
INSERT INTO passengers (passenger_id, first_name, last_name, date_of_birth, gender, country_of_citizenship, country_of_residence, passport_number, created_at, updated_at)
SELECT 
  i,
  'First_' || i,
  'Last_' || i,
  '1990-01-01'::DATE + (random() * 10000 || ' days')::INTERVAL,
  CASE WHEN random() > 0.5 THEN 'Male' ELSE 'Female' END,
  'Kazakhstan',
  'Kazakhstan',
  'P' || (10000000 + i),
  NOW(),
  NOW()
FROM generate_series(1, 200) AS i;

-- 6. Генерация 200 рейсов
INSERT INTO flights (flight_id, sch_departure_time, sch_arrival_time, departing_airport_id, arriving_airport_id, departing_gate, arriving_gate, airline_id, act_departure_time, act_arrival_time, created_at, updated_at)
SELECT 
  i,
  '2023-01-01'::TIMESTAMP + (random() * 700 || ' days')::INTERVAL,
  '2023-01-01'::TIMESTAMP + (random() * 700 || ' days')::INTERVAL + INTERVAL '3 hours',
  (floor(random() * 200) + 1)::INT,
  (floor(random() * 200) + 1)::INT,
  'A' || (i % 10),
  'B' || (i % 10),
  (floor(random() * 200) + 1)::INT,
  '2023-01-01'::TIMESTAMP + (random() * 700 || ' days')::INTERVAL,
  '2023-01-01'::TIMESTAMP + (random() * 700 || ' days')::INTERVAL + INTERVAL '3 hours',
  NOW(),
  NOW()
FROM generate_series(1, 200) AS i;

-- 7. Генерация 200 бронирований
INSERT INTO booking (booking_id, flight_id, passenger_id, booking_platform, created_at, updated_at, status, ticket_price)
SELECT 
  i,
  (floor(random() * 200) + 1)::INT,
  (floor(random() * 200) + 1)::INT,
  'Website',
  NOW(),
  NOW(),
  'Confirmed',
  round((random() * 20000 + 1000)::numeric, 2)
FROM generate_series(1, 200) AS i;

-- 8. Генерация 200 проверок багажа
INSERT INTO baggage_check (baggage_check_id, check_result, created_at, updated_at, booking_id, passenger_id)
SELECT 
  i,
  CASE WHEN random() > 0.5 THEN 'Not checked' ELSE 'Checked' END,
  '2023-01-01'::TIMESTAMP + (random() * 500 || ' days')::INTERVAL,
  NOW(),
  (floor(random() * 200) + 1)::INT,
  (floor(random() * 200) + 1)::INT
FROM generate_series(1, 200) AS i;