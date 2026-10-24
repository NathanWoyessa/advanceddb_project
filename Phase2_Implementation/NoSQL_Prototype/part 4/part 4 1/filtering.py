key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()

whichCollection = input("Which collection, ex 'vehicle_damage_logs':")
collection = db.collection(whichCollection)

searchAttribute = input("Enter attribute (e.g. vehicle_id, severity, status): ")
specificValue = input("Enter value: ")

if searchAttribute in ["estimated_cost", "cost"]:
    specificValue = float(specificValue)

docs = collection.where(
    filter=FieldFilter(searchAttribute, "==", specificValue)
).stream()

found = False

for doc in docs:
    found = True
    print(doc.id, doc.to_dict())

if not found:
    print("No matching records found.")