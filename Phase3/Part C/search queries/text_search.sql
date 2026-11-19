SELECT *,
       ts_rank(
         to_tsvector('english', description),
         plainto_tsquery('english', 'family suv')
       ) AS rank
FROM vehicle_vectors
WHERE to_tsvector('english', description)
      @@ plainto_tsquery('english', 'family suv')
ORDER BY rank DESC;