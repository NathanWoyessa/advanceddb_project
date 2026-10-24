#pip -q install firebase-admin
key_file = "firestore-key.json"

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter

if not firebase_admin._apps:
    firebase_admin.initialize_app(credentials.Certificate(key_file))
db = firestore.client()
print("Connected to project:", db.project)

DATA = {
    "vehicle_damage_logs": [
        {
            "vehicle_id": "1",
            "rental_id": "101",
            "date": "2026-01-01",
            "estimated_cost": 500,
            "damage": ["Stained Seat", "Cracked Windshield"],
            "severity": "Moderate",
            "status": "Reported",
            "notes": "Damage discovered after rental"
        },
        {
            "vehicle_id": "2",
            "rental_id": "102",
            "date": "2026-01-01",
            "estimated_cost": 100,
            "damage": ["Stained Seat"],
            "severity": "Minor",
            "status": "Resolved",
            "notes": "Interior cleaning required"
        },
        {
            "vehicle_id": "5",
            "rental_id": "103",
            "date": "2026-01-11",
            "estimated_cost": 1500,
            "damage": ["Brake Failure"],
            "severity": "Severe",
            "status": "Under Repair",
            "notes": "Vehicle removed from service"
        },
        {
            "vehicle_id": "4",
            "rental_id": "104",
            "date": "2026-01-21",
            "estimated_cost": 1000,
            "damage": ["Stained Seat", "Broken Windshield"],
            "severity": "Moderate",
            "status": "Reported",
            "notes": "Hail damage"
        }
    ],

    "vehicle_repairs_logs": [
        {
            "vehicle_id": "1",
            "date": "2026-01-10",
            "cost": 500,
            "repair_shop": "Tires Center",
            "repair": ["Windshield Replacement"],
            "repair_status": "Completed",
            "completion_date": "2026-01-10"
        },
        {
            "vehicle_id": "2",
            "date": "2026-01-10",
            "cost": 100,
            "repair_shop": "Vacuum Center",
            "repair": ["Seat Cleaning"],
            "repair_status": "Completed",
            "completion_date": "2026-01-10"
        },
        {
            "vehicle_id": "5",
            "date": "2026-01-15",
            "cost": 1500,
            "repair_shop": "Master Mechanics",
            "repair": ["Brake Replacement"],
            "repair_status": "In Progress",
            "completion_date": None
        }
    ]
}

for p in DATA["vehicle_damage_logs"]:
    db.collection("vehicle_damage_logs").add(p)

for s in DATA["vehicle_repairs_logs"]:
    db.collection("vehicle_repairs_logs").add(s)

print("data uploaded")