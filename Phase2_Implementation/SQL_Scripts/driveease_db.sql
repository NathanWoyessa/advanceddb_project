-- implementation script
-- DriveEase Car Rental Management Database

CREATE TABLE location (
    location_id SERIAL PRIMARY KEY,
    location_name VARCHAR(100) NOT NULL,
    city VARCHAR(80) NOT NULL,
    province VARCHAR(50) NOT NULL,
    address VARCHAR(200) NOT NULL
);

CREATE TABLE customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    phone VARCHAR(25),
    driver_license VARCHAR(50) UNIQUE NOT NULL,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE employee (
    employee_id SERIAL PRIMARY KEY,
    location_id INT NOT NULL REFERENCES location(location_id),
    first_name VARCHAR(60) NOT NULL,
    last_name VARCHAR(60) NOT NULL,
    job_title VARCHAR(80) NOT NULL,
    hire_date DATE NOT NULL
);

CREATE TABLE vehicle (
    vehicle_id SERIAL PRIMARY KEY,
    location_id INT NOT NULL REFERENCES location(location_id),
    make VARCHAR(60) NOT NULL,
    model VARCHAR(60) NOT NULL,
    vehicle_year INT NOT NULL CHECK (vehicle_year BETWEEN 2000 AND 2035),
    category VARCHAR(40) NOT NULL,
    daily_rate NUMERIC(10,2) NOT NULL CHECK (daily_rate > 0),
    vehicle_status VARCHAR(20) NOT NULL
        CHECK (vehicle_status IN
        ('Available', 'Reserved', 'Rented', 'Maintenance')),
    license_plate VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE reservation (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customer(customer_id),
    vehicle_id INT NOT NULL REFERENCES vehicle(vehicle_id),
    pickup_location_id INT NOT NULL REFERENCES location(location_id),
    return_location_id INT NOT NULL REFERENCES location(location_id),
    booking_date DATE NOT NULL DEFAULT CURRENT_DATE,
    pickup_date DATE NOT NULL,
    return_date DATE NOT NULL,
    reservation_status VARCHAR(20) NOT NULL
        CHECK (reservation_status IN
        ('Pending', 'Confirmed', 'Cancelled', 'Completed')),
    CHECK (return_date > pickup_date)
);

CREATE TABLE rental (
    rental_id SERIAL PRIMARY KEY,
    reservation_id INT UNIQUE NOT NULL
        REFERENCES reservation(reservation_id),
    employee_id INT REFERENCES employee(employee_id),
    actual_pickup TIMESTAMP,
    actual_return TIMESTAMP,
    odometer_start INT CHECK (odometer_start >= 0),
    odometer_end INT,
    rental_status VARCHAR(20) NOT NULL
        CHECK (rental_status IN ('Active', 'Completed', 'Overdue')),
    CHECK (odometer_end IS NULL OR
           odometer_start IS NULL OR odometer_end >= odometer_start),
    CHECK (actual_return IS NULL OR actual_pickup IS NULL OR
           actual_return >= actual_pickup)
);

CREATE TABLE payment (
    payment_id SERIAL PRIMARY KEY,
    rental_id INT NOT NULL REFERENCES rental(rental_id),
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL
        CHECK (payment_status IN
        ('Pending', 'Paid', 'Refunded', 'Failed'))
);

CREATE TABLE maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL REFERENCES vehicle(vehicle_id),
    employee_id INT REFERENCES employee(employee_id),
    service_date DATE NOT NULL,
    description TEXT NOT NULL,
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),
    maintenance_status VARCHAR(20) NOT NULL
        CHECK (maintenance_status IN
        ('Scheduled', 'In Progress', 'Completed'))
);

CREATE TABLE insurance (
    insurance_id SERIAL PRIMARY KEY,
    vehicle_id INT NOT NULL REFERENCES vehicle(vehicle_id),
    provider VARCHAR(100) NOT NULL,
    policy_number VARCHAR(80) UNIQUE NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    CHECK (end_date >= start_date)
);

-- Indexes for common searches and joins
CREATE INDEX idx_reservation_customer
    ON reservation(customer_id);

CREATE INDEX idx_reservation_vehicle_dates
    ON reservation(vehicle_id, pickup_date, return_date);

CREATE INDEX idx_rental_status
    ON rental(rental_status);

CREATE INDEX idx_payment_rental_status
    ON payment(rental_id, payment_status);

CREATE INDEX idx_maintenance_vehicle_date
    ON maintenance(vehicle_id, service_date);

CREATE INDEX idx_vehicle_location_status
    ON vehicle(location_id, vehicle_status);


-- Insert sample data
-- 1. Locations: 5 records
INSERT INTO location
    (location_name, city, province, address)
VALUES
    ('Downtown Calgary', 'Calgary', 'Alberta', '100 Centre Street'),
    ('Calgary Airport', 'Calgary', 'Alberta', '200 Airport Road'),
    ('Edmonton Central', 'Edmonton', 'Alberta', '300 Jasper Avenue'),
    ('Red Deer Branch', 'Red Deer', 'Alberta', '400 Gaetz Avenue'),
    ('Banff Branch', 'Banff', 'Alberta', '500 Banff Avenue');

-- 2. Customers: 200 records
INSERT INTO customer
    (first_name, last_name, email, phone, driver_license)
SELECT
    'Customer' || n,
    'Test',
    'customer' || n || '@example.com',
    '403555' || LPAD(n::text, 4, '0'),
    'DL' || LPAD(n::text, 6, '0')
FROM generate_series(1, 200) AS s(n);

-- 3. Employees: 100 records
INSERT INTO employee
    (location_id, first_name, last_name, job_title, hire_date)
SELECT
    ((n - 1) % 5) + 1,
    'Employee' || n,
    'Staff',
    CASE WHEN n % 4 = 0 THEN 'Manager'
         ELSE 'Rental Agent' END,
    DATE '2020-01-01' + (n % 1800)
FROM generate_series(1, 100) AS s(n);

-- 4. Vehicles: 150 records
INSERT INTO vehicle
    (location_id, make, model, vehicle_year,
     category, daily_rate, vehicle_status, license_plate)
SELECT
    ((n - 1) % 5) + 1,
    CASE WHEN n % 3 = 0 THEN 'Toyota'
         WHEN n % 3 = 1 THEN 'Honda'
         ELSE 'Ford' END,
    CASE WHEN n % 3 = 0 THEN 'Corolla'
         WHEN n % 3 = 1 THEN 'Civic'
         ELSE 'Escape' END,
    2020 + (n % 7),
    CASE WHEN n % 3 = 0 THEN 'Economy'
         WHEN n % 3 = 1 THEN 'Compact'
         ELSE 'SUV' END,
    45 + (n % 8) * 10,
    CASE WHEN n % 10 = 0 THEN 'Maintenance'
         ELSE 'Available' END,
    'AB' || LPAD(n::text, 5, '0')
FROM generate_series(1, 150) AS s(n);

-- 5. Reservations: 200 records
INSERT INTO reservation
    (customer_id, vehicle_id, pickup_location_id,
     return_location_id, booking_date, pickup_date,
     return_date, reservation_status)
SELECT
    ((n - 1) % 200) + 1,
    ((n - 1) % 150) + 1,
    ((n - 1) % 5) + 1,
    ((n) % 5) + 1,
    DATE '2026-01-01' + (n % 200),
    DATE '2026-02-01' + (n % 250),
    DATE '2026-02-01' + (n % 250) + 1 + (n % 6),
    CASE WHEN n % 10 = 0 THEN 'Cancelled'
         WHEN n % 3 = 0 THEN 'Completed'
         ELSE 'Confirmed' END
FROM generate_series(1, 200) AS s(n);

-- 6. Rentals: 160 records
INSERT INTO rental
    (reservation_id, employee_id, actual_pickup,
     actual_return, odometer_start, odometer_end, rental_status)
SELECT
    n,
    ((n - 1) % 100) + 1,
    TIMESTAMP '2026-03-01 09:00:00' + n * INTERVAL '1 day',
    TIMESTAMP '2026-03-01 09:00:00'
        + n * INTERVAL '1 day'
        + INTERVAL '2 days',
    10000 + n * 100,
    10000 + n * 100 + 250,
    'Completed'
FROM generate_series(1, 160) AS s(n)
WHERE EXISTS (
    SELECT 1 FROM reservation r
    WHERE r.reservation_id = n
      AND r.reservation_status = 'Completed'
);

-- 7. Payments: one payment for each created rental
INSERT INTO payment
    (rental_id, payment_date, amount,
     payment_method, payment_status)
SELECT
    r.rental_id,
    CURRENT_TIMESTAMP - (r.rental_id * INTERVAL '1 hour'),
    100 + (r.rental_id % 10) * 25,
    CASE WHEN r.rental_id % 2 = 0
         THEN 'Credit Card' ELSE 'Debit Card' END,
    'Paid'
FROM rental r;

-- 8. Maintenance: 120 records
INSERT INTO maintenance
    (vehicle_id, employee_id, service_date,
     description, cost, maintenance_status)
SELECT
    ((n - 1) % 150) + 1,
    ((n - 1) % 100) + 1,
    DATE '2025-01-01' + n,
    CASE WHEN n % 2 = 0 THEN 'Oil change'
         ELSE 'Vehicle inspection' END,
    75 + (n % 10) * 20,
    'Completed'
FROM generate_series(1, 120) AS s(n);

-- 9. Insurance: one policy for each vehicle
INSERT INTO insurance
    (vehicle_id, provider, policy_number, start_date, end_date)
SELECT
    vehicle_id,
    'DriveEase Insurance Partner',
    'POL' || LPAD(vehicle_id::text, 6, '0'),
    DATE '2026-01-01',
    DATE '2027-01-01'
FROM vehicle;

-- Verify the sample data

SELECT 'location' AS table_name, COUNT(*) AS total_rows FROM location
UNION ALL
SELECT 'customer', COUNT(*) FROM customer
UNION ALL
SELECT 'employee', COUNT(*) FROM employee
UNION ALL
SELECT 'vehicle', COUNT(*) FROM vehicle
UNION ALL
SELECT 'reservation', COUNT(*) FROM reservation
UNION ALL
SELECT 'rental', COUNT(*) FROM rental
UNION ALL
SELECT 'payment', COUNT(*) FROM payment
UNION ALL
SELECT 'maintenance', COUNT(*) FROM maintenance
UNION ALL
SELECT 'insurance', COUNT(*) FROM insurance
ORDER BY table_name;

--Query 1 — Display reservations with customer and vehicle information
--Which customers booked which vehicles, and when?

SELECT
    r.reservation_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    v.make,
    v.model,
    r.pickup_date,
    r.return_date,
    r.reservation_status
FROM reservation r
JOIN customer c ON r.customer_id = c.customer_id
JOIN vehicle v ON r.vehicle_id = v.vehicle_id
ORDER BY r.pickup_date;

--Query 2 — Calculate total revenue by rental
--How much money has each rental generated from successful payments?

SELECT
    r.rental_id,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM rental r
LEFT JOIN payment p
    ON r.rental_id = p.rental_id
    AND p.payment_status = 'Paid'
GROUP BY r.rental_id
ORDER BY total_paid DESC;

--Query 3 — Find the most frequently rented vehicles
--Which vehicles have the highest rental demand?

SELECT
    v.vehicle_id,
    v.make,
    v.model,
    COUNT(r.rental_id) AS total_rentals
FROM vehicle v
LEFT JOIN reservation b ON v.vehicle_id = b.vehicle_id
LEFT JOIN rental r ON b.reservation_id = r.reservation_id
GROUP BY v.vehicle_id, v.make, v.model
ORDER BY total_rentals DESC
LIMIT 10;

--Query 4 — Find customers who have made above-average payments
--Which customers have paid more than the average customer payment total?

WITH customer_totals AS (
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        COALESCE(SUM(p.amount)
            FILTER (WHERE p.payment_status = 'Paid'), 0) AS total_paid
    FROM customer c
    LEFT JOIN reservation b ON c.customer_id = b.customer_id
    LEFT JOIN rental r ON b.reservation_id = r.reservation_id
    LEFT JOIN payment p ON r.rental_id = p.rental_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *
FROM customer_totals
WHERE total_paid > (
    SELECT AVG(total_paid) FROM customer_totals
)
ORDER BY total_paid DESC;

--Query 5 — Calculate revenue by rental location
--Which pickup locations generate the most paid revenue?

SELECT
    l.location_name,
    l.city,
    COALESCE(SUM(p.amount), 0) AS total_revenue
FROM location l
LEFT JOIN reservation b
    ON l.location_id = b.pickup_location_id
LEFT JOIN rental r
    ON b.reservation_id = r.reservation_id
LEFT JOIN payment p
    ON r.rental_id = p.rental_id
    AND p.payment_status = 'Paid'
GROUP BY l.location_id, l.location_name, l.city
ORDER BY total_revenue DESC;

--Query 6 — Identify vehicles with above-average maintenance costs
--Which vehicles have maintenance costs higher than the average vehicle maintenance cost?

SELECT
    v.vehicle_id,
    v.make,
    v.model,
    SUM(m.cost) AS total_maintenance_cost
FROM vehicle v
JOIN maintenance m ON v.vehicle_id = m.vehicle_id
GROUP BY v.vehicle_id, v.make, v.model
HAVING SUM(m.cost) > (
    SELECT AVG(vehicle_cost)
    FROM (
        SELECT SUM(cost) AS vehicle_cost
        FROM maintenance
        GROUP BY vehicle_id
    ) costs
)
ORDER BY total_maintenance_cost DESC;

--Query 7 — Create a revenue summary view
--Can managers quickly access the total paid revenue for every rental?

CREATE OR REPLACE VIEW vw_rental_revenue AS
SELECT
    r.rental_id,
    r.rental_status,
    COALESCE(SUM(p.amount)
        FILTER (WHERE p.payment_status = 'Paid'), 0) AS total_paid
FROM rental r
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY r.rental_id, r.rental_status;

-- Test the view
SELECT *
FROM vw_rental_revenue
ORDER BY total_paid DESC;

--Query 8 — Create a trigger to flag vehicles needing maintenance
--Can the database automatically update a vehicle's status when maintenance begins?

CREATE OR REPLACE FUNCTION flag_vehicle_maintenance()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.maintenance_status = 'In Progress' THEN
        UPDATE vehicle
        SET vehicle_status = 'Maintenance'
        WHERE vehicle_id = NEW.vehicle_id;
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_flag_vehicle_maintenance
AFTER INSERT OR UPDATE OF maintenance_status
ON maintenance
FOR EACH ROW
EXECUTE FUNCTION flag_vehicle_maintenance();


INSERT INTO maintenance
    (vehicle_id, service_date, description, cost, maintenance_status)
VALUES
    (1, CURRENT_DATE, 'Brake inspection test', 150.00, 'In Progress');

SELECT vehicle_id, vehicle_status
FROM vehicle
WHERE vehicle_id = 1;

--Query 9 — Create a stored function to calculate rental cost
--How much should a customer be charged based on the number of rental days and the vehicle's daily rate?

CREATE OR REPLACE FUNCTION calculate_rental_cost(
    p_vehicle_id INT,
    p_days INT
)
RETURNS NUMERIC(10,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rate NUMERIC(10,2);
BEGIN
    IF p_days <= 0 THEN
        RAISE EXCEPTION 'Rental days must be greater than zero';
    END IF;

    SELECT daily_rate
    INTO v_rate
    FROM vehicle
    WHERE vehicle_id = p_vehicle_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Vehicle does not exist';
    END IF;

    RETURN v_rate * p_days;
END;
$$;

-- Test the function
SELECT calculate_rental_cost(1, 3) AS estimated_cost;

--Query 10 — Demonstrate a transaction
--How can the company make sure a payment record is inserted safely?

BEGIN;

INSERT INTO payment
    (rental_id, amount, payment_method, payment_status)
VALUES
    (1, 150.00, 'Credit Card', 'Paid');

-- Check the inserted payment before committing
SELECT *
FROM payment
WHERE rental_id = 1
ORDER BY payment_id DESC;

-- Use COMMIT to save, or ROLLBACK to cancel.
COMMIT;
