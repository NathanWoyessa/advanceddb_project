import sys

from pathlib import Path
import numpy as np
from datetime import date

print("Python:", sys.executable)
assert sys.version_info >= (3, 10), "This needs Python 3.10 or newer. Pick another kernel (top right)."

try:
    import pandas as pd
    from sentence_transformers import SentenceTransformer
except ModuleNotFoundError as e:
    print(f"'{e.name}' is not installed in this Python, so installing sentence-transformers and pandas now.")
    print("This can take several minutes. To skip it, pick the .venv kernel you created with requirements.txt.")
    get_ipython().run_line_magic("pip", "install -q sentence-transformers pandas") # type: ignore
    import pandas as pd
    from sentence_transformers import SentenceTransformer

MODEL_NAME = "sentence-transformers/all-MiniLM-L6-v2"
REVISION = "1110a243fdf4706b3f48f1d95db1a4f5529b4d41"   # the version the course uses
try:
    model = SentenceTransformer(MODEL_NAME, revision=REVISION)
except Exception:
    try:
        model = SentenceTransformer(MODEL_NAME)
        print("Could not load the course's model version, so loaded the latest one instead.")
    except Exception as e:
        raise SystemExit(
            "The model could not be loaded.\n"
            f"  Error: {type(e).__name__}: {str(e)[:300]}\n"
            "  The first download needs huggingface.co, which some campus networks block:\n"
            "  try home Wi-Fi or a phone hotspot. On a Mac, if the error mentions certificates,\n"
            "  run 'Install Certificates.command' in Applications > Python 3.x.")

get_dim = getattr(model, "get_embedding_dimension", None) or model.get_sentence_embedding_dimension
DIM = get_dim()
assert DIM == 384, f"Expected 384 dimensions, got {DIM}. Wrong model?"
print(f"Model ready: all-MiniLM-L6-v2, {DIM} dimensions.")



HERE = Path.cwd()
CSV = HERE / "vehicles_ids_with_descriptions.csv"
assert CSV.exists(), (f"{CSV} is not in {HERE}.\n"
                      "Keep it in the same folder as this notebook, and open that folder in VS Code.")
titles = pd.read_csv(CSV)

need = ["id", "description"]
missing = [c for c in need if c not in titles.columns]
assert not missing, f"ca3_titles.csv is missing these columns: {missing}"
assert titles["id"].is_unique, "Two rows share the same title_id. Each title needs its own id."
titles["description"] = titles["description"].fillna("").astype(str).str.strip()
assert (titles["description"] != "").all(), "Some titles have an empty description. Fill them in and run this cell again."
print(f"Loaded {len(titles)} titles.")


OUT = HERE / "my_sql"
OUT.mkdir(exist_ok=True)

title_vecs = np.asarray(model.encode(titles["description"].tolist(), normalize_embeddings=True,
                                     show_progress_bar=True), dtype="float32")
ok = bool(np.allclose(np.linalg.norm(title_vecs, axis=1), 1, atol=1e-4))
print(f"{title_vecs.shape[0]} vectors × {title_vecs.shape[1]} numbers, every one unit length: {ok}")

# Quick check. Cosine distance = 1 - dot product (pgvector's <=> operator). 0 = same meaning.
d = 1 - title_vecs @ title_vecs[0]

def vec(v):
    return "[" + ",".join(f"{x:.6f}".rstrip("0").rstrip(".") for x in v) + "]"

def q(s):
    return "'" + str(s).replace("'", "''") + "'"

def num(x):
    return "NULL" if pd.isna(x) else str(int(x))

rows = [f"({int(r.id)},"
        f"{q(r.description)},"
        f"{q(vec(title_vecs[i]))})"
        for i, r in enumerate(titles.itertuples(index=False))]

sql = f"""
-- Made in VS Code on {date.today().isoformat()} with all-MiniLM-L6-v2 (384 dimensions).
-- Safe to run again: existing vehicle_vectors are updated, not duplicated.

CREATE EXTENSION IF NOT EXISTS vector;

CREATE TABLE IF NOT EXISTS vehicle_vectors (
    id     integer PRIMARY KEY,
    description  text    NOT NULL,
    embedding    vector(384)
);

INSERT INTO vehicle_vectors (id, description, embedding) VALUES
""" + ",\n".join(rows) + """
ON CONFLICT (id) DO UPDATE SET
    description = EXCLUDED.description, 
    embedding = EXCLUDED.embedding;

-- Vector index for cosine distance (the <=> operator).
CREATE INDEX IF NOT EXISTS vectors_embedding_idx ON vehicle_vectors USING hnsw (embedding vector_cosine_ops);

-- Self-check. Expect: vehicle_vectors = with_vectors, and dimensions = 384.
SELECT count(*) AS vehicle_vectors, count(embedding) AS with_vectors, max(vector_dims(embedding)) AS dimensions
FROM vehicle_vectors;
"""

(OUT / "vehicle_description_vectors.sql").write_text(sql, encoding="utf-8")
print(f"\nWrote {OUT / 'vehicle_description_vectors.sql'}")