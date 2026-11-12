import os
from pathlib import Path

import psycopg
from psycopg.rows import dict_row


class Database:
    def __init__(self, dsn: str | None = None):
        self.dsn = dsn or os.getenv(
            "DATABASE_URL", "postgresql://spot4u:spot4u@localhost:5432/spot4u"
        )

    def connect(self):
        return psycopg.connect(self.dsn, row_factory=dict_row, connect_timeout=5)

    def ensure_schema(self) -> None:
        schema = Path(__file__).resolve().parents[1].joinpath("schema.sql").read_text()
        with self.connect() as connection:
            with connection.cursor() as cursor:
                cursor.execute(schema)

    def ping(self) -> None:
        with self.connect() as connection:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                cursor.fetchone()

    def campuses(self) -> list[dict]:
        with self.connect() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT id, name, address, latitude, longitude FROM campuses ORDER BY id"
                )
                return list(cursor.fetchall())

    def campus(self, campus_id: str) -> dict | None:
        with self.connect() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    "SELECT id, name, address, latitude, longitude FROM campuses WHERE id = %s",
                    (campus_id,),
                )
                return cursor.fetchone()

    def places(self, campus_id: str, categories: list[str]) -> list[dict]:
        with self.connect() as connection:
            with connection.cursor() as cursor:
                cursor.execute(
                    """
                    SELECT place_id, name, category, address, latitude, longitude,
                           opening_hours, rating, review_count, avg_check_rub,
                           wifi, sockets, laptop_friendly, student_discount,
                           website, phone, source, last_updated,
                           travel_time_min, travel_mode
                    FROM places
                    WHERE campus_id = %s AND category = ANY(%s)
                    ORDER BY place_id
                    """,
                    (campus_id, categories),
                )
                rows = list(cursor.fetchall())
        for row in rows:
            if row["last_updated"] is not None:
                row["last_updated"] = row["last_updated"].isoformat()
        return rows
