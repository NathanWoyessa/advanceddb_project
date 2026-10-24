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
            "vehicle_id": "3",
            "rental_id": "105",
            "date": "2026-01-24",
            "estimated_cost": 750,
            "damage": ["Door Dent", "Scratched Paint"],
            "severity": "Moderate",
            "status": "Reported",
            "notes": "Customer indicated damage may have occurred in parking structure."
        },
        {
            "vehicle_id": "3",
            "rental_id": "105",
            "date": "2026-06-24",
            "severity": "Moderate",
            "status": "Reported",
            "notes": "Hail damage"
        },
        {
            "vehicle_id": "6",
            "rental_id": "106",
            "date": "2026-01-28",
            "estimated_cost": 2200,
            "damage": ["Transmission Issue"],
            "severity": "Severe",
            "status": "Under Investigation",
            "notes": "Driver reported unusual grinding noise during highway travel."
        },
        {
            "vehicle_id": "7",
            "rental_id": "107",
            "date": "2026-02-02",
            "estimated_cost": 325,
            "damage": ["Flat Tire"],
            "severity": "Minor",
            "status": "Resolved",
            "notes": "Puncture caused by nail. Temporary replacement installed."
        },
        {
            "vehicle_id": "8",
            "rental_id": "108",
            "date": "2026-02-04",
            "estimated_cost": 1800,
            "damage": ["Rear Bumper Crack", "Broken Tail Light"],
            "severity": "Moderate",
            "status": "Reported",
            "notes": "Minor collision reported by renter during vehicle return."
        },
        {
            "vehicle_id": "10",
            "rental_id": "109",
            "date": "2026-02-08",
            "estimated_cost": 4800,
            "damage": ["Engine Failure"],
            "severity": "Critical",
            "status": "Under Repair",
            "notes": "Engine warning light ignored for approximately 200 km."
        },
        {
            "vehicle_id": "2",
            "rental_id": "110",
            "date": "2026-02-11",
            "estimated_cost": 90,
            "damage": ["Coffee Spill"],
            "severity": "Minor",
            "status": "Resolved",
            "notes": "Detailing required for front passenger seat."
        },
        {
            "vehicle_id": "9",
            "rental_id": "111",
            "date": "2026-02-13",
            "estimated_cost": 1400,
            "damage": ["Suspension Damage"],
            "severity": "Severe",
            "status": "Reported",
            "notes": "Large pothole impact suspected."
        },
        {
            "vehicle_id": "4",
            "rental_id": "112",
            "date": "2026-02-17",
            "estimated_cost": 650,
            "damage": ["Side Mirror Broken"],
            "severity": "Moderate",
            "status": "Awaiting Parts",
            "notes": "Replacement mirror on backorder."
        }
    ],

    "vehicle_repairs_logs": [
        {
            "vehicle_id": "3",
            "date": "2026-01-26",
            "cost": 720,
            "repair_shop": "Downtown Collision",
            "repair": ["Paint Correction", "Dent Removal"],
            "repair_status": "Completed",
            "repair_location": "Calgary",
            "completion_date": "2026-01-29"
        },
        {
            "vehicle_id": "6",
            "date": "2026-01-30",
            "cost": 2100,
            "repair_shop": "Advanced Transmission",
            "repair": ["Transmission Rebuild"],
            "repair_location": "Edmonton",
            "repair_status": "In Progress",
            "completion_date": None
        },
        {
            "vehicle_id": "7",
            "date": "2026-02-02",
            "cost": 140,
            "repair_shop": "Quick Tire Service",
            "repair": ["Tire Replacement"],
            "repair_status": "Completed",
            "completion_date": "2026-02-02"
        },
        {
            "vehicle_id": "8",
            "date": "2026-02-06",
            "cost": 1750,
            "repair_shop": "Northside Body Works",
            "repair": ["Rear Bumper Repair", "Tail Light Replacement"],
            "repair_status": "Scheduled",
            "completion_date": None
        },
        {
            "vehicle_id": "10",
            "date": "2026-02-10",
            "cost": 5100,
            "repair_shop": "Elite Auto Diagnostics",
            "repair": ["Engine Replacement"],
            "repair_status": "In Progress",
            "completion_date": None
        },
        {
            "vehicle_id": "9",
            "date": "2026-02-15",
            "cost": 1525,
            "repair_shop": "Precision Auto Care",
            "repair": ["Suspension Inspection", "Control Arm Replacement"],
            "repair_status": "Awaiting Approval",
            "completion_date": None
        },
        {
            "vehicle_id": "4",
            "date": "2026-02-19",
            "cost": 675,
            "repair_shop": "OEM Parts Centre",
            "repair": ["Mirror Assembly Replacement"],
            "repair_status": "Waiting For Parts",
            "completion_date": None
        }
    ]
}

for p in DATA["vehicle_damage_logs"]:
    db.collection("vehicle_damage_logs").add(p)

for s in DATA["vehicle_repairs_logs"]:
    db.collection("vehicle_repairs_logs").add(s)


{
    "vehicle_damage_logs": [
        {
            "vehicle_id": "11",
            "rental_id": "113",
            "date": "2026-02-20",
            "damage": ["scratch on door"],
            "severity": "minor",
            "status": "Pending Review",
            "notes": ""
        },
        {
            "vehicle_id": "12",
            "rental_id": "114",
            "date": "",
            "estimated_cost": "850",
            "damage": ["Broken Mirror"],
            "severity": "MODERATE",
            "status": "reported",
            "notes": "Mirror hanging loose"
        },
        {
            "vehicle_id": "13",
            "rental_id": "115",
            "estimated_cost": 600,
            "damage": ["Windshield Crack"],
            "status": "Reported"
        },
        {
            "vehicle_id": "2",
            "rental_id": "116",
            "date": "2026/02/21",
            "estimated_cost": -50,
            "damage": [],
            "severity": "Minor",
            "status": "Closed",
        },
        {
            "rental_id": "117",
            "date": "2026-02-22",
            "estimated_cost": 1250,
            "damage": ["Transmission issue", "oil leak"],
            "severity": "Severe",
            "status": "Repair Started",
            "notes": "Customer mentioned issue existed before rental."
        },
        {
            "vehicleID": "14",
            "rental_id": "118",
            "date": "22-Feb-2026",
            "estimated_cost": 320,
            "damage": ["seat stain"],
            "severity": "Low",
            "status": "resolved",
            "notes": "Professional detailing completed."
        },
        {
            "vehicle_id": "15",
            "rental_id": "119",
            "date": "2026-02-25",
            "estimated_cost": 4400,
            "damage": ["ENGINE FAILURE"],
            "severity": "Critical",
            "status": "Under Repair",
            "notes": "Tow truck required.",
            "insurance_claim": "Filed"
        },
        {
            "vehicle_id": "15",
            "rental_id": "119",
            "date": "2026-02-25",
            "estimated_cost": 4400,
            "damage": ["ENGINE FAILURE"],
            "severity": "Critical",
            "status": "Under Repair",
            "notes": "Tow truck required."
        }
    ],

    "vehicle_repairs_logs": [
        {
            "vehicle_id": "11",
            "date": "2026-02-23",
            "repair_shop": "Quick Fix Auto",
            "repair": ["Paint Touchup"],
            "repair_status": "Scheduled",
            "completion_date": None
        },
        {
            "vehicle_id": "12",
            "date": "2026-02-24",
            "cost": "900",
            "repair_shop": "",
            "repair": ["Mirror Replacement"],
            "repair_status": "complete",
            "completion_date": "2026-02-25"
        },
        {
            "vehicle_id": "13",
            "date": "24/02/2026",
            "cost": 575,
            "repair_shop": "Glass Masters",
            "repair": "Windshield Replacement",
            "repair_status": "Completed",
            "completion_date": "2026-02-24"
        },
        {
            "vehicle_id": "2",
            "date": "2026-02-25",
            "cost": -10,
            "repair_shop": "Unknown",
            "repair": [],
            "repair_status": "Cancelled",
            "completion_date": None
        },
        {
            "vehicle": "14",
            "date": "2026-02-26",
            "cost": 350,
            "repair_shop": "Interior Experts",
            "repair": ["Deep Cleaning"],
            "repair_status": "done",
            "completion_date": "2026-02-26"
        },
        {
            "vehicle_id": "15",
            "date": "2026-02-28",
            "cost": 4950,
            "repair_shop": "Engine Works Ltd",
            "repair": [
                "Engine Replacement",
                "Oil System Inspection"
            ],
            "repair_status": "In Progress"
        }
    ]
}

for p in DATA["vehicle_damage_logs"]:
    db.collection("vehicle_damage_logs").add(p)

for s in DATA["vehicle_repairs_logs"]:
    db.collection("vehicle_repairs_logs").add(s)

print("data uploaded")