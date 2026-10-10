--airline -- flights -- airport -- passengers -- booking -- baggage --baggage_check

--зд 1
SELECT passenger_id, first_name, last_name, date_of_birth
FROM passengers
WHERE date_of_birth > CURRENT_DATE - INTERVAL '10 years';
------------------------------------------------------------
UPDATE passengers
SET date_of_birth = DATE '2000-01-01'
WHERE date_of_birth > CURRENT_DATE - INTERVAL '10 years';

ALTER TABLE passengers
ADD CONSTRAINT chk_passenger_age
CHECK (date_of_birth <= CURRENT_DATE - INTERVAL '10 years');
---------------------------------------------------------------

--зд 2 
ALTER TABLE booking
ADD CONSTRAINT chk_ticket_price
CHECK (ticket_price >= 0 AND ticket_price <= 50000);

--зд 3
ALTER TABLE baggage
ADD CONSTRAINT check_baggage_weight
CHECK (weight_in_kg BETWEEN 1 AND 23);
------------------------------------------------------
SELECT *
FROM baggage
WHERE weight_in_kg < 1 OR weight_in_kg > 23;

--зд 4 Добавьте ограничение CHECK, чтобы все значения в airport_name имели не менее 10 символов.   
---------
ALTER TABLE airport
ADD CONSTRAINT check_airport_name_length
CHECK (LENGTH(airport_name) >= 10);
----зд 5 dd UNIQUE ограничение для некоторых столбцов в каждой таблице базы данных


ALTER TABLE airline ADD CONSTRAINT uq_airline_name UNIQUE (airline_name);
ALTER TABLE airport ADD CONSTRAINT uq_airport_name UNIQUE (airport_name);
ALTER TABLE passengers ADD CONSTRAINT uq_passport UNIQUE (passport_number);


----------зд 6

ALTER TABLE passengers
ADD CONSTRAINT check_passenger_gender_age
CHECK (
    (gender = 'Male' AND date_of_birth <= DATE '2008-10-10')
    OR
    (gender = 'Female' AND date_of_birth <= DATE '2007-10-10')
)
NOT VALID;
-----------------------------------------
--зд 7
ALTER TABLE passengers
ADD CONSTRAINT check_passenger_citizenship_age
CHECK (
    (country_of_citizenship = 'Kazakhstan'
        AND date_of_birth <= DATE '2008-10-10')
    OR
    (country_of_citizenship = 'France'
        AND date_of_birth <= DATE '2009-10-10')
    OR
    (country_of_citizenship NOT IN ('Kazakhstan', 'France')
        AND date_of_birth <= DATE '2007-10-10')
)
NOT VALID;

-- зд 8
---это по условию добовление колонны 
ALTER TABLE booking ADD COLUMN ticket_discount DECIMAL(8,2);
 
UPDATE booking
SET ticket_discount = CASE
  WHEN created_at >= DATE '2024-01-01' THEN ROUND(ticket_price * 0.05, 2)
  ELSE ROUND(ticket_price * 0.10, 2)
END;
----испр ошибк

UPDATE booking
SET ticket_discount =
    CASE
        WHEN created_at > DATE '2024-01-01'
            THEN ROUND(ticket_price * 0.05, 2)
        WHEN created_at < DATE '2024-01-01'
            THEN ROUND(ticket_price * 0.10, 2)
        ELSE 0
    END;
----------------добовление условия повторяется структура как и в 7 и 6
ALTER TABLE booking
ADD CONSTRAINT check_ticket_discount
CHECK (
    (created_at > DATE '2024-01-01'
        AND ticket_discount = ROUND(ticket_price * 0.05, 2))
    OR
    (created_at < DATE '2024-01-01'
        AND ticket_discount = ROUND(ticket_price * 0.10, 2))
    OR
    (created_at = DATE '2024-01-01'
        AND ticket_discount = 0)
);
------зд 9
ALTER TABLE booking
ALTER COLUMN status SET DEFAULT 'Confirmed';

INSERT INTO booking (
    booking_id,
    flight_id,
    passenger_id,
    booking_platform,
    created_at,
    updated_at,
	ticket_price,
	ticket_discount,
    price
)
VALUES (
    1001,
    1,
    1,
    'Online',
    NOW(),
    NOW(),
	500.00,
	25.00,
    500.00
);


SELECT booking_id, status
FROM booking
ORDER BY booking_id DESC
LIMIT 1;

------------зд 10 
ALTER TABLE booking ALTER COLUMN created_at SET DEFAULT CURRENT_DATE;




