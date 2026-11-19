SELECT
    v.id,
    v.description,
    1 - (v.embedding <=> s.embedding) AS similarity
FROM vehicle_vectors v
CROSS JOIN (
    SELECT embedding
    FROM searches
    WHERE id = 1
) s
ORDER BY v.embedding <=> s.embedding
LIMIT 10;