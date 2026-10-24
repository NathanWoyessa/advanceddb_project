key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()

COLLECTIONS = [
    "vehicle_damage_logs",
    "vehicle_repairs_logs",
]
print("Connected to project:", db.project)
print("Collections to clear:", COLLECTIONS)

confirm = input(
    "Type DELETE to permanently clear these collections: "
)

if confirm == "DELETE":
    for collection_name in COLLECTIONS:
        collection = db.collection(collection_name)
        batch = db.batch()
        count = 0
        batch_count = 0

        for document in collection.stream():
            batch.delete(document.reference)
            count += 1
            batch_count += 1

            # Firestore batches support up to 500 operations
            if batch_count == 500:
                batch.commit()
                batch = db.batch()
                batch_count = 0

        # Commit any remaining deletions
        if batch_count > 0:
            batch.commit()

        print(f"{collection_name}: deleted {count} documents")

    print("Cleanup complete!")
else:
    print("Cancelled. No documents deleted.")
