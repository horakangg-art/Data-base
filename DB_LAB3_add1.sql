--- Task 1 & 2: Добавляем KazAir
BEGIN;
DELETE FROM airline WHERE airline_id = 201;

INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES (201, 'KZA', 'KazAir', 'Kazakhstan', NOW(), NOW());

SELECT * FROM airline WHERE airline_name = 'KazAir';
COMMIT;


--- Task 3: Обновляем KazAir на Turkey
UPDATE airline 
SET airline_country = 'Turkey', updated_at = NOW()
WHERE airline_name = 'KazAir';

SELECT * FROM airline WHERE airline_name = 'KazAir';


--- Task 4: Добавляем 3 компании
BEGIN;
DELETE FROM airline WHERE airline_id IN (202, 203, 204);

INSERT INTO airline (airline_id, airline_code, airline_name, airline_country, created_at, updated_at)
VALUES 
  (202, 'EASY', 'AirEasy', 'France', NOW(), NOW()),
  (203, 'HIGH', 'FlyHigh', 'Brazil', NOW(), NOW()),
  (204, 'FLY', 'FlyFly', 'Poland', NOW(), NOW());

SELECT * FROM airline WHERE airline_id IN (202, 203, 204);
COMMIT;


--- Task 5: Удаление рейсов 2024 года (со всеми зависимостями)
BEGIN;

-- 1. Удаляем все связанные с этими рейсами дочерние записи
DELETE FROM baggage_check WHERE booking_id IN (SELECT booking_id FROM booking WHERE flight_id IN (SELECT flight_id FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024));
DELETE FROM baggage WHERE booking_id IN (SELECT booking_id FROM booking WHERE flight_id IN (SELECT flight_id FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024));
DELETE FROM boarding_pass WHERE booking_id IN (SELECT booking_id FROM booking WHERE flight_id IN (SELECT flight_id FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024));
DELETE FROM booking_flight WHERE flight_id IN (SELECT flight_id FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024);

-- 2. Удаляем бронирования
DELETE FROM booking WHERE flight_id IN (SELECT flight_id FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024);

-- 3. Удаляем сами рейсы
DELETE FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024;

-- 4. Проверка (таблица будет пустой)
SELECT * FROM flights WHERE EXTRACT(YEAR FROM sch_arrival_time) = 2024;

ROLLBACK;


--- Task 11: Вставка и RETURNING
BEGIN;
DELETE FROM baggage_check WHERE baggage_check_id = 205;

INSERT INTO baggage_check (baggage_check_id, check_result, created_at, updated_at, booking_id, passenger_id)
VALUES (205, 'Not checked', NOW(), NOW(), 1, 1)
RETURNING baggage_check_id, created_at;
COMMIT;


--- Task 14: Capital District
UPDATE airport 
SET state = 'Capital District' 
WHERE city IN ('Astana', 'London', 'Tokyo');

SELECT * FROM airport WHERE city IN ('Astana', 'London', 'Tokyo');