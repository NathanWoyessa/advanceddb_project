
from dataclasses import dataclass, asdict
from datetime import datetime
import json


@dataclass
class Location:
    location_id: int
    location_name: str
    city: str


@dataclass
class Reservation:
    reservation_id: int
    customer_id: int
    vehicle_id: int
    reservation_start: str
    reservation_end: str
    reservation_status: str
    pickup_location: Location

    def to_json(self):
        return json.dumps(asdict(self), indent=2)


if __name__ == "__main__":
    location = Location(
        location_id=1,
        location_name="Downtown",
        city="Calgary"
    )

    reservation = Reservation(
        reservation_id=1001,
        customer_id=25,
        vehicle_id=3,
        reservation_start="2026-11-01T09:00:00",
        reservation_end="2026-11-04T09:00:00",
        reservation_status="Confirmed",
        pickup_location=location
    )

    print(reservation.to_json())
