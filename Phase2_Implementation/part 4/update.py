key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()
#Get any ID
document_id = input("Enter the document ID")
print(document_id)

ref = db.collection("vehicle_damage_logs").document(document_id)

ref.set({'notes': 'Someone spilt coffee, not the customer'}, merge=True)

print("after merge=True:", ref.get().to_dict())