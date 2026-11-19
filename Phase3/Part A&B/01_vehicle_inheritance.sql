-- DriveEase Phase 3 - Part A: Class-table inheritance

-- It expects the Phase 2 tables: location and vehicle.

BEGIN;

-- 1. Add subtype tables. vehicle remains the authoritative superclass.
CREATE TABLE IF NOT EXISTS economy_vehicle (
    vehicle_id INT PRIMARY KEY REFERENCES vehicle(vehicle_id) ON DELETE CASCADE,
    fuel_efficiency_kmpl NUMERIC(5,2) NOT NULL CHECK (fuel_efficiency_kmpl > 0),
    eco_mode BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS compact_vehicle (
    vehicle_id INT PRIMARY KEY REFERENCES vehicle(vehicle_id) ON DELETE CASCADE,
    cargo_capacity_l NUMERIC(7,2) NOT NULL CHECK (cargo_capacity_l > 0),
    door_count SMALLINT NOT NULL CHECK (door_count BETWEEN 2 AND 5)
);

CREATE TABLE IF NOT EXISTS suv (
    vehicle_id INT PRIMARY KEY REFERENCES vehicle(vehicle_id) ON DELETE CASCADE,
    seating_capacity SMALLINT NOT NULL CHECK (seating_capacity BETWEEN 2 AND 12),
    four_wheel_drive BOOLEAN NOT NULL DEFAULT FALSE
);

-- 2. Populate subtype tables from the categories in the Phase 2 vehicle table.
-- Values below are representative generated specifications, not measured vehicle data.
INSERT INTO economy_vehicle (vehicle_id, fuel_efficiency_kmpl, eco_mode)
SELECT vehicle_id, 16.0 + (vehicle_id % 5) * 0.5, TRUE
FROM vehicle WHERE category = 'Economy'
ON CONFLICT (vehicle_id) DO NOTHING;

INSERT INTO compact_vehicle (vehicle_id, cargo_capacity_l, door_count)
SELECT vehicle_id, 350.0 + (vehicle_id % 6) * 15, 4
FROM vehicle WHERE category = 'Compact'
ON CONFLICT (vehicle_id) DO NOTHING;

INSERT INTO suv (vehicle_id, seating_capacity, four_wheel_drive)
SELECT vehicle_id, 5 + (vehicle_id % 3), (vehicle_id % 2 = 0)
FROM vehicle WHERE category = 'SUV'
ON CONFLICT (vehicle_id) DO NOTHING;

-- 3. Validate that every vehicle has exactly one matching subtype.
CREATE OR REPLACE FUNCTION validate_vehicle_subtype()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INT;
    v_category VARCHAR(40);
    subtype_count INT;
    subtype_category VARCHAR(40);
BEGIN
    IF TG_TABLE_NAME = 'vehicle' THEN
        v_id := COALESCE(NEW.vehicle_id, OLD.vehicle_id);
    ELSE
        v_id := COALESCE(NEW.vehicle_id, OLD.vehicle_id);
    END IF;

    SELECT category INTO v_category
    FROM vehicle
    WHERE vehicle_id = v_id;

    -- Parent may have been deleted; ON DELETE CASCADE handles its subtype.
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    SELECT
        (EXISTS (SELECT 1 FROM economy_vehicle WHERE vehicle_id = v_id))::INT
      + (EXISTS (SELECT 1 FROM compact_vehicle WHERE vehicle_id = v_id))::INT
      + (EXISTS (SELECT 1 FROM suv WHERE vehicle_id = v_id))::INT
    INTO subtype_count;

    IF subtype_count <> 1 THEN
        RAISE EXCEPTION
          'Vehicle % must have exactly one subtype row; found %',
          v_id, subtype_count;
    END IF;

    IF EXISTS (SELECT 1 FROM economy_vehicle WHERE vehicle_id = v_id) THEN
        subtype_category := 'Economy';
    ELSIF EXISTS (SELECT 1 FROM compact_vehicle WHERE vehicle_id = v_id) THEN
        subtype_category := 'Compact';
    ELSE
        subtype_category := 'SUV';
    END IF;

    IF v_category <> subtype_category THEN
        RAISE EXCEPTION
          'Vehicle % category (%) does not match subtype (%)',
          v_id, v_category, subtype_category;
    END IF;

    RETURN NULL;
END;
$$;

-- Immediate checks prevent inserting a subtype inconsistent with vehicle.category.
CREATE OR REPLACE FUNCTION check_subtype_category()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_category VARCHAR(40);
    expected_category VARCHAR(40);
BEGIN
    expected_category := CASE TG_TABLE_NAME
        WHEN 'economy_vehicle' THEN 'Economy'
        WHEN 'compact_vehicle' THEN 'Compact'
        WHEN 'suv' THEN 'SUV'
    END;

    SELECT category INTO v_category
    FROM vehicle
    WHERE vehicle_id = NEW.vehicle_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Parent vehicle % does not exist', NEW.vehicle_id;
    END IF;

    IF v_category <> expected_category THEN
        RAISE EXCEPTION
          'Cannot add % subtype to vehicle % with category %',
          expected_category, NEW.vehicle_id, v_category;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_economy_category ON economy_vehicle;
CREATE TRIGGER trg_economy_category
BEFORE INSERT OR UPDATE ON economy_vehicle
FOR EACH ROW EXECUTE FUNCTION check_subtype_category();

DROP TRIGGER IF EXISTS trg_compact_category ON compact_vehicle;
CREATE TRIGGER trg_compact_category
BEFORE INSERT OR UPDATE ON compact_vehicle
FOR EACH ROW EXECUTE FUNCTION check_subtype_category();

DROP TRIGGER IF EXISTS trg_suv_category ON suv;
CREATE TRIGGER trg_suv_category
BEFORE INSERT OR UPDATE ON suv
FOR EACH ROW EXECUTE FUNCTION check_subtype_category();

-- Deferred checks allow the parent and subtype to be inserted in one transaction.
DROP TRIGGER IF EXISTS trg_vehicle_subtype_complete ON vehicle;
CREATE CONSTRAINT TRIGGER trg_vehicle_subtype_complete
AFTER INSERT OR UPDATE OF category ON vehicle
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION validate_vehicle_subtype();

DROP TRIGGER IF EXISTS trg_economy_subtype_complete ON economy_vehicle;
CREATE CONSTRAINT TRIGGER trg_economy_subtype_complete
AFTER INSERT OR UPDATE OR DELETE ON economy_vehicle
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION validate_vehicle_subtype();

DROP TRIGGER IF EXISTS trg_compact_subtype_complete ON compact_vehicle;
CREATE CONSTRAINT TRIGGER trg_compact_subtype_complete
AFTER INSERT OR UPDATE OR DELETE ON compact_vehicle
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION validate_vehicle_subtype();

DROP TRIGGER IF EXISTS trg_suv_subtype_complete ON suv;
CREATE CONSTRAINT TRIGGER trg_suv_subtype_complete
AFTER INSERT OR UPDATE OR DELETE ON suv
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION validate_vehicle_subtype();

-- 4. Encapsulation: expose a unified view across the hierarchy.
CREATE OR REPLACE VIEW vw_vehicle_details AS
SELECT
    v.vehicle_id,
    v.location_id,
    v.make,
    v.model,
    v.vehicle_year,
    v.category,
    v.daily_rate,
    v.vehicle_status,
    v.license_plate,
    CASE
        WHEN ev.vehicle_id IS NOT NULL
            THEN 'Fuel efficiency: ' || ev.fuel_efficiency_kmpl::TEXT || ' km/L'
        WHEN cv.vehicle_id IS NOT NULL
            THEN 'Cargo capacity: ' || cv.cargo_capacity_l::TEXT || ' L; doors: ' || cv.door_count
        WHEN s.vehicle_id IS NOT NULL
            THEN 'Seats: ' || s.seating_capacity || '; 4WD: ' || s.four_wheel_drive
    END AS subtype_details
FROM vehicle v
LEFT JOIN economy_vehicle ev ON ev.vehicle_id = v.vehicle_id
LEFT JOIN compact_vehicle cv ON cv.vehicle_id = v.vehicle_id
LEFT JOIN suv s ON s.vehicle_id = v.vehicle_id;

-- 5. Database operations representing Vehicle class methods.
CREATE OR REPLACE FUNCTION calculate_vehicle_rental_cost(
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

    SELECT daily_rate INTO v_rate
    FROM vehicle
    WHERE vehicle_id = p_vehicle_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Vehicle % does not exist', p_vehicle_id;
    END IF;

    RETURN v_rate * p_days;
END;
$$;

CREATE OR REPLACE FUNCTION mark_vehicle_for_maintenance(p_vehicle_id INT)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE vehicle
    SET vehicle_status = 'Maintenance'
    WHERE vehicle_id = p_vehicle_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Vehicle % does not exist', p_vehicle_id;
    END IF;
END;
$$;

COMMIT;

-- 6. Verification queries. Run after the transaction.
SELECT category, COUNT(*) AS vehicle_count
FROM vehicle
GROUP BY category
ORDER BY category;

SELECT
    (SELECT COUNT(*) FROM vehicle) AS parent_vehicle_count,
    (SELECT COUNT(*) FROM economy_vehicle) AS economy_count,
    (SELECT COUNT(*) FROM compact_vehicle) AS compact_count,
    (SELECT COUNT(*) FROM suv) AS suv_count;

-- Polymorphism: one query works across the hierarchy and returns
-- different subclass-specific details for each vehicle type.
SELECT vehicle_id, make, model, category, subtype_details
FROM vw_vehicle_details
ORDER BY vehicle_id;

-- Demonstrate the Vehicle operations.
SELECT calculate_vehicle_rental_cost(1, 3) AS estimated_three_day_cost;
SELECT * FROM vw_vehicle_details WHERE vehicle_id = 1;

-- Optional maintenance operation test (changes vehicle 1's status):
-- SELECT mark_vehicle_for_maintenance(1);
-- SELECT vehicle_id, vehicle_status FROM vehicle WHERE vehicle_id = 1;
