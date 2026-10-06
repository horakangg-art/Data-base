--- Task 1
SELECT UPPER(airline_name) AS airline_name
FROM airline;

--- Task 2
SELECT airline_id, airline_name,
       REPLACE(airline_name, 'Air', 'Aero') AS new_name
FROM airline;

-- Task 3
SELECT flight_id FROM flights WHERE airline_id = 1
INTERSECT
SELECT flight_id FROM flights WHERE airline_id = 2;

--- Task 4
SELECT airport_id, airport_name, city
FROM airport
WHERE airport_name ILIKE '%Reginal%'
  AND airport_name ILIKE '%Air%';

-- Task 5
SELECT first_name, last_name,
       TO_CHAR(date_of_birth, 'FMMonth DD, YYYY') AS birth_date
FROM passengers;

-- Task 6
SELECT flight_id, act_arrival_time - sch_arrival_time AS delay
FROM flights
WHERE act_arrival_time > sch_arrival_time;

-- Task 7
SELECT flight_id, sch_arrival_time, act_arrival_time,
       ROUND(EXTRACT(EPOCH FROM (act_arrival_time - sch_arrival_time)) / 60) AS late_minutes
FROM flights
WHERE act_arrival_time > sch_arrival_time
ORDER BY late_minutes DESC;

-- task 8
SELECT airline_id, airline_name, airline_country, created_at
FROM airline
WHERE UPPER(airline_country) IN ('FRANCE', 'PORTUGAL', 'POLAND')
  AND created_at BETWEEN '2023-11-01' AND '2024-03-31 23:59:59';

-- Task 9
SELECT baggage_id, booking_id, weight_in_kg
FROM baggage
WHERE weight_in_kg > 25
ORDER BY weight_in_kg DESC
LIMIT 3;

-- task 10
SELECT first_name || ' ' || last_name AS full_name, date_of_birth
FROM passengers
WHERE date_of_birth = (SELECT MAX(date_of_birth) FROM passengers);

-- rask 11
SELECT booking_platform, MIN(ticket_price) AS cheapest_price
FROM booking
GROUP BY booking_platform;

-- Task 12
SELECT airline_id, airline_code, airline_name
FROM airline
WHERE airline_code ~ '[0-9]';

-- Task 13
SELECT airline_id, airline_name, created_at
FROM airline
ORDER BY created_at DESC
LIMIT 5;

-- Task 14
SELECT *
FROM baggage_check
WHERE booking_id BETWEEN 200 AND 300
  AND check_result <> 'Checked';

-- Task15
SELECT *
FROM baggage_check
WHERE DATE_TRUNC('month', updated_at) = DATE_TRUNC('month', created_at)
  AND updated_at < created_at;
