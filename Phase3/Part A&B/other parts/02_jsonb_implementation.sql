-- DriveEase Phase 3 - Part B: JSONB

BEGIN;

-- 1. Add flexible specifications to the existing vehicle table.
ALTER TABLE vehicle
ADD COLUMN IF NOT EXISTS specifications JSONB;

-- Fill existing Phase 2 vehicles with illustrative synthetic feature data.

UPDATE vehicle
SET specifications = jsonb_build_object(
    'comfort', jsonb_build_object(
        'air_conditioning', TRUE,
        'heated_seats', (vehicle_id % 2 = 0),
        'sunroof', (vehicle_id % 5 = 0)
    ),
    'technology', jsonb_build_object(
        'gps', (vehicle_id % 4 <> 0),
        'bluetooth', TRUE,
        'backup_camera', (vehicle_id % 3 <> 0)
    ),
    'safety', jsonb_build_array(
        jsonb_build_object('feature_code', 'AIRBAG', 'available', TRUE),
        jsonb_build_object('feature_code', 'ABS', 'available', TRUE),
        jsonb_build_object('feature_code', 'REAR_CAMERA',
                           'available', (vehicle_id % 3 <> 0))
    )
)
WHERE specifications IS NULL;

ALTER TABLE vehicle
ALTER COLUMN specifications SET DEFAULT
'{"comfort":{"air_conditioning":true,"heated_seats":false,"sunroof":false},
  "technology":{"gps":false,"bluetooth":true,"backup_camera":false},
  "safety":[]}'::jsonb;

ALTER TABLE vehicle
ALTER COLUMN specifications SET NOT NULL;

-- 2. Validate required JSON keys and their data types.
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'vehicle_specifications_shape_chk'
          AND conrelid = 'vehicle'::regclass
    ) THEN
        ALTER TABLE vehicle
        ADD CONSTRAINT vehicle_specifications_shape_chk
        CHECK (
            jsonb_typeof(specifications) = 'object'
            AND specifications ? 'comfort'
            AND jsonb_typeof(specifications -> 'comfort') = 'object'
            AND specifications ? 'technology'
            AND jsonb_typeof(specifications -> 'technology') = 'object'
            AND specifications ? 'safety'
            AND jsonb_typeof(specifications -> 'safety') = 'array'
            AND COALESCE(jsonb_typeof(specifications #> '{technology,gps}') = 'boolean', FALSE)
        );
    END IF;
END $$;

-- 3. Relational catalogue used to demonstrate joining JSON array elements.
CREATE TABLE IF NOT EXISTS vehicle_feature_catalog (
    feature_code VARCHAR(30) PRIMARY KEY,
    feature_name VARCHAR(100) NOT NULL,
    feature_description TEXT NOT NULL
);

INSERT INTO vehicle_feature_catalog
    (feature_code, feature_name, feature_description)
VALUES
    ('AIRBAG', 'Airbags', 'Airbag safety system'),
    ('ABS', 'Anti-lock Braking System', 'Helps prevent wheel lock during braking'),
    ('REAR_CAMERA', 'Rear Camera', 'Camera to assist with reversing')
ON CONFLICT (feature_code) DO UPDATE
SET feature_name = EXCLUDED.feature_name,
    feature_description = EXCLUDED.feature_description;

-- 4. GIN index. Default jsonb_ops supports @>, @? and other JSONB operators.
CREATE INDEX IF NOT EXISTS idx_vehicle_specifications_gin
ON vehicle USING GIN (specifications);

COMMIT;

ANALYZE vehicle;

-- ================================================================
-- Required JSONB statements
-- ================================================================

-- Query 1: Containment query (@>)
-- Find vehicles with GPS and Bluetooth enabled.
SELECT vehicle_id, make, model, category, specifications
FROM vehicle
WHERE specifications @> '{"technology":{"gps":true,"bluetooth":true}}'::jsonb
ORDER BY vehicle_id;

-- Query 2: JSON path query (@?)
-- Find vehicles whose safety array contains an available ABS feature.
SELECT vehicle_id, make, model, category
FROM vehicle
WHERE specifications @? '$.safety[*] ? (@.feature_code == "ABS" && @.available == true)'
ORDER BY vehicle_id;

-- Query 3: Expand JSON array to rows and join to a relational table.
-- One output row per safety feature, with its catalogue description.
SELECT
    v.vehicle_id,
    v.make,
    v.model,
    c.feature_code,
    c.feature_name,
    c.feature_description,
    (f.feature ->> 'available')::boolean AS available
FROM vehicle AS v
CROSS JOIN LATERAL jsonb_array_elements(v.specifications -> 'safety')
    AS f(feature)
JOIN vehicle_feature_catalog AS c
    ON c.feature_code = f.feature ->> 'feature_code'
ORDER BY v.vehicle_id, c.feature_code;

-- Query 4: Update one nested JSON value using jsonb_set.
-- Example: enable GPS for vehicle_id 1.
UPDATE vehicle
SET specifications = jsonb_set(
    specifications,
    '{technology,gps}',
    'true'::jsonb,
    TRUE
)
WHERE vehicle_id = 1
RETURNING vehicle_id, specifications;

-- ================================================================
-- EXPLAIN plan for the containment query (required by assignment)
-- ================================================================
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT vehicle_id
FROM vehicle
WHERE specifications @> '{"technology":{"gps":true,"bluetooth":true}}'::jsonb;

-- enable_seqscan=off for normal performance measurements.
SET enable_seqscan = OFF;
EXPLAIN (ANALYZE, BUFFERS, VERBOSE)
SELECT vehicle_id
FROM vehicle
WHERE specifications @> '{"technology":{"gps":true,"bluetooth":true}}'::jsonb;
RESET enable_seqscan;

-- Verify the JSONB column and index.
SELECT vehicle_id, jsonb_pretty(specifications)
FROM vehicle
ORDER BY vehicle_id
LIMIT 5;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'vehicle'
  AND indexname = 'idx_vehicle_specifications_gin';
