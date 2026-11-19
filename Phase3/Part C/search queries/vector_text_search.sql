WITH params AS (
    SELECT
        search AS query_text,
        embedding AS query_embedding
    FROM searches
    WHERE id = 1
),
vector_search AS (
    SELECT
        v.id,
        v.description,
        1 - (v.embedding <=> p.query_embedding) AS vector_similarity,
        ROW_NUMBER() OVER (ORDER BY v.embedding <=> p.query_embedding) AS vec_rank
    FROM vehicle_vectors v
    CROSS JOIN params p
    ORDER BY v.embedding <=> p.query_embedding
    LIMIT 50
),
text_search AS (
    SELECT
        v.id,
        v.description,
        ts_rank(
            to_tsvector('english', v.description),
            plainto_tsquery('english', p.query_text)
        ) AS text_rank,
        ROW_NUMBER() OVER (
            ORDER BY ts_rank(
                to_tsvector('english', v.description),
                plainto_tsquery('english', p.query_text)
            ) DESC
        ) AS fts_rank
    FROM vehicle_vectors v
    CROSS JOIN params p
    WHERE to_tsvector('english', v.description)
          @@ plainto_tsquery('english', p.query_text)
    ORDER BY text_rank DESC
    LIMIT 50
)
SELECT
    COALESCE(vs.id, ts.id) AS id,
    COALESCE(vs.description, ts.description) AS description,
    vs.vector_similarity,
    ts.text_rank,
    (
        COALESCE(1.0 / (60 + vs.vec_rank), 0.0) +
        COALESCE(1.0 / (60 + ts.fts_rank), 0.0)
    ) AS hybrid_score
FROM vector_search vs
FULL OUTER JOIN text_search ts ON vs.id = ts.id
ORDER BY hybrid_score DESC
LIMIT 10;