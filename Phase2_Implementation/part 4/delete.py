#pip -q install firebase-admin
key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()
print("Connected to project:", db.project)

collection_name = input(
    "Enter collection (vehicle_damage_logs or vehicle_repairs_logs): "
)

if collection_name not in ["vehicle_damage_logs", "vehicle_repairs_logs"]:
    print("Invalid collection name.")
else:
    document_id = input("Enter document ID: ")

    ref = db.collection(collection_name).document(document_id)

    if ref.get().exists:
        confirm = input("Are you sure you want to delete? (yes/no): ")

        if confirm.lower() == "yes":
            ref.delete()
            print("Document deleted successfully!")
        else:
            print("Deletion cancelled.")
    else:
        print("Document not found.")