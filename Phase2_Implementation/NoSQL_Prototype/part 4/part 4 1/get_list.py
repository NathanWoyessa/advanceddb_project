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

if collection_name in ["vehicle_damage_logs", "vehicle_repairs_logs"]:
    for doc in db.collection(collection_name).stream():
        print("Document ID:", doc.id)
        print("Data:", doc.to_dict())
        print("------------------------")
else:
    print("Invalid collection name.")
    #allows us to veiw both damadge and repair records.