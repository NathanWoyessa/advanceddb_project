key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()

collection_name = input(
    "Enter collection (vehicle_damage_logs or vehicle_repairs_logs): "
)

if collection_name not in ["vehicle_damage_logs", "vehicle_repairs_logs"]:
    print("Invalid collection name.")
else:
    document_id = input("Enter document ID: ")

    doc = db.collection(collection_name).document(document_id).get()

    if doc.exists:
        print("Document found!")
        print("Document ID:", doc.id)
        print("Data:", doc.to_dict())
    else:
        print("Document not found.")