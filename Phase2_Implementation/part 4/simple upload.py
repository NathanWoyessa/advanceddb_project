#pip -q install firebase-admin
key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()
print("Connected to project:", db.project)

data = {
            "vehicle_id": "0",
            "rental_id": 0,
            "date": "2025-01-01",
            "damage": ["Test1","Test2", "Test3", "Test4"],
            "severity": "Moderate",
            "status": "Reported",
            "notes": "Damage discovered after rental"
        }

print(data)

db.collection("vehicle_damage_logs").add(data)

print("Data one document")