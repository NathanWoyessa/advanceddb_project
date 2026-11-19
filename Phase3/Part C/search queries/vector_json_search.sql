WITH search_query AS (
    SELECT embedding
    FROM searches
    WHERE id = 1
)
SELECT 
    veh.vehicle_id,
    veh.make,
    veh.model,
    veh.category,
    veh.specifications,
    v.description,
    1 - (v.embedding <=> s.embedding) AS similarity
FROM vehicle veh
JOIN vehicle_vectors v ON veh.vehicle_id = v.id
CROSS JOIN search_query s
WHERE veh.specifications @> '{"technology":{"gps":true,"bluetooth":true}}'::jsonb
ORDER BY v.embedding <=> s.embedding
LIMIT 10;