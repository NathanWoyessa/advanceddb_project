# DriveEase Car Rental Management Database: Phase 2

## 1. Project Overview

DriveEase is a car rental management database project that uses PostgreSQL for relational data and Google Cloud Firestore for NoSQL data. The project demonstrates relational database queries, NoSQL document storage, and object-oriented mapping with PostgreSQL JSONB.

## 2. Repository Structure

The Phase 2 implementation files are organized as follows:

```text
Phase2_Implementation/
├── SQL_Scripts/
├── Query_Portfolio/
├── NoSQL_Prototype/
├── OO_JSONB_Mapping/
│   ├── reservation_class.py
│   └── reservation_jsonb.sql
├── Implementation_Report/
├── Demo_Video_Link.txt
└── README.md
```

- **SQL_Scripts:** PostgreSQL schema creation and data-loading scripts.
- **Query_Portfolio:** SQL queries used to demonstrate database functionality.
- **NoSQL_Prototype:** Firestore seed script and related NoSQL implementation files.
- **OO_JSONB_Mapping:** Python reservation class and PostgreSQL JSONB demonstration.
- **Implementation_Report:** The Phase 2 implementation report and supporting evidence.
- **Demo_Video_Link.txt:** Link to the project demonstration video.

## 3. Dependencies and Environment

The project uses the following software:

- **PostgreSQL:** Relational database server.
- **Python 3:** Used for the object-oriented reservation example and Firestore seeding.
- **firebase-admin:** Python library for connecting to Google Cloud Firestore using Firebase Admin SDK credentials.
- **Google Cloud Firestore:** NoSQL document database.
- **Git:** Version control and collaboration.

Install the Firestore Python dependency in a terminal:

```bash
python -m pip install firebase-admin
```

It is recommended to use a Python virtual environment:

**Windows PowerShell**
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install firebase-admin
```

**macOS/Linux**
```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install firebase-admin
```

PostgreSQL must be installed and running locally, and a database must be created before the SQL scripts are executed.

## 4. PostgreSQL Setup

1. Install PostgreSQL and start the database server.
2. Create a local database for the project, for example `driveease`.
3. Connect to the database using `psql`, pgAdmin, or another PostgreSQL client.
4. Run the SQL scripts in `SQL_Scripts/` in the required order. Run schema creation scripts before scripts that insert data or execute queries.
5. Run the relevant queries in `Query_Portfolio/` to verify the implementation.

For example, using `psql`:

```bash
psql -U YOUR_LOCAL_DB_USER -d driveease
```

Replace `YOUR_LOCAL_DB_USER` with your local PostgreSQL username. Enter credentials when prompted rather than placing passwords in a committed script or command.

The database schema includes the core car rental entities, such as locations, customers, vehicles, reservations, rentals, and payments. Confirm the actual table names against the SQL scripts before running queries, because PostgreSQL treats quoted identifiers with case sensitivity.

### PostgreSQL Dataset

The PostgreSQL dataset represents the relational side of the DriveEase car rental system. It is loaded using the project's SQL schema and data scripts.

| Dataset detail | Description |
|---|---|
| Source | Project-created car rental schema and sample data |
| Generation method | SQL scripts define the tables and load the project data |
| Main entities | Locations, customers, vehicles, reservations, rentals, and payments |
| Dataset size | Record counts must be confirmed from the populated local database |

To check the number of records in each table, run a query similar to the following, adjusting the table names to match the actual schema:

```sql
SELECT 'Customer' AS table_name, COUNT(*) AS row_count
FROM Customer
UNION ALL
SELECT 'Vehicle', COUNT(*) FROM Vehicle
UNION ALL
SELECT 'reservation', COUNT(*) FROM reservation
UNION ALL
SELECT 'rental', COUNT(*) FROM rental
UNION ALL
SELECT 'payment', COUNT(*) FROM payment;
```

Include the verified row counts in the final dataset description.

## 5. Firestore Setup and Seeding

The Firestore prototype stores vehicle damage records and repair logs as NoSQL documents.

### Prerequisites

1. Have access to a Google Cloud project with Firestore enabled.
2. Create or select a Firestore database.
3. Obtain a Firebase service-account key for local development, following the project's access permissions.
4. Save the key locally, outside version control.
5. Install the `firebase-admin` Python package using the instructions above.

### Supply Credentials

Set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to the path of the local service-account JSON file.

**Windows PowerShell**
```powershell
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\firestore-key.json"
```

**macOS/Linux**
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/firestore-key.json"
```

Use the actual local path to the key file. Keep the key on your own machine and do not upload it to GitHub.

### Seed the Firestore Collections

1. Open the `NoSQL_Prototype/` directory.
2. Confirm that the seed script initializes Firebase Admin and points to the intended Firestore project.
3. Activate the Python virtual environment and ensure `firebase-admin` is installed.
4. Set `GOOGLE_APPLICATION_CREDENTIALS` as shown above.
5. Run the seed script from the terminal, replacing `seed_firestore.py` with the actual filename if it differs:

```bash
python seed_firestore.py
```

6. Open the Firestore console and check the resulting collections and document counts.

**Important:** Check whether the seed script inserts the same data more than once before running it repeatedly. Unless the script uses stable document IDs, duplicate prevention, or cleanup logic, each run may create additional documents.

### Firestore Dataset

| Dataset detail | Description |
|---|---|
| Source | Sample records defined in the project's Python seed script |
| Generation method | Python dictionaries are inserted into Firestore collections |
| Damage data | Vehicle damage logs |
| Repair data | Vehicle repair logs |
| Dataset size | Verify the actual document count in each collection after seeding |

Record the final number of damage-log and repair-log documents from the Firestore console after checking the seed script and confirming that the collections contain the intended data.

## 6. Object-Oriented and JSONB Demonstration

The `OO_JSONB_Mapping/` directory contains the Python reservation class and the SQL script demonstrating PostgreSQL JSONB.

- `reservation_class.py` represents a reservation as a Python object and demonstrates composition through its pickup-location object.
- `reservation_jsonb.sql` stores a reservation document in a PostgreSQL JSONB column and demonstrates queries against nested JSON fields.

Run the Python example with:

```bash
python reservation_class.py
```

Run `reservation_jsonb.sql` against the local PostgreSQL database to create the demonstration table, insert the example document, and query its fields.

The JSONB example demonstrates flexible document-style storage inside PostgreSQL. It does not replace the normalized relational schema or automatically enforce foreign-key relationships for identifiers embedded in JSON.

## 7. Credentials and Security

**Never commit secrets to the repository.** This includes:

- Database passwords.
- API keys or private access tokens.
- Connection strings containing credentials.
- Firebase service-account JSON key files.

Add the following entries to the repository's `.gitignore` file:

```gitignore
# Python
__pycache__/
*.py[cod]
.venv/
venv/

# Environment files
.env
.env.*
!.env.example

# Firebase credentials
firestore-key.json
service-account*.json
```

Keep local credentials in environment variables or in local configuration files excluded by `.gitignore`. If the project uses a `.env` file, load it locally with an appropriate library and commit only a placeholder `.env.example` containing variable names without real values.

If a secret is accidentally committed, removing the file in a later commit is not sufficient. Revoke or rotate the exposed credential and address the secret in the repository history.

## 8. Final Verification Checklist

Before submitting Phase 2:

- PostgreSQL schema and data scripts run successfully on a local database.
- PostgreSQL table row counts have been verified and documented.
- Firestore seed script runs using local credentials.
- Damage and repair collection counts have been verified.
- Repeated seeding does not unintentionally create duplicate records.
- The Python reservation example runs successfully.
- The JSONB SQL script and example queries run successfully.
- Required implementation files and report evidence are included.
- No passwords, API keys, credential-bearing connection strings, or service-account key files are committed.
- `Demo_Video_Link.txt` contains the demonstration link when available.
