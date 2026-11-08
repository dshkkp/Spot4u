import argparse
from datetime import date, datetime
from pathlib import Path

from openpyxl import load_workbook

CAMPUSES = (
    {
        "id": "leningradsky",
        "name": "Ленинградский проспект",
        "address": "Москва, Ленинградский проспект, 49/2",
        "latitude": 55.8003496,
        "longitude": 37.5288590,
        "expected_rows": 73,
    },
    {
        "id": "veshnyakovsky",
        "name": "Вешняковский проезд",
        "address": "Москва, 4-й Вешняковский проезд, 4, стр. 3",
        "latitude": 55.7183211,
        "longitude": 37.7956473,
        "expected_rows": 31,
    },
)
from .database import Database

FIELDS = [
    "place_id",
    "name",
    "category",
    "address",
    "latitude",
    "longitude",
    "opening_hours",
    "rating",
    "review_count",
    "avg_check_rub",
    "wifi",
    "sockets",
    "laptop_friendly",
    "student_discount",
    "website",
    "phone",
    "source",
    "last_updated",
    "travel_time_min",
    "travel_mode",
]
CATEGORIES = {"cafe", "coffee_shop", "library", "coworking", "anticafe"}
FLAGS = {"yes", "no", "unknown"}
FLAG_FIELDS = ("wifi", "sockets", "laptop_friendly", "student_discount")
INTEGER_FIELDS = ("review_count", "avg_check_rub", "travel_time_min")
NUMERIC_FIELDS = ("latitude", "longitude", "rating")
NULLABLE_TEXT_FIELDS = ("opening_hours", "website", "phone", "source", "travel_mode")


def _clean(value):
    if isinstance(value, str):
        value = value.strip()
        return None if not value or value.lower() == "unknown" else value
    return value


def load_dataset(path: str | Path, campus: dict) -> list[dict]:
    workbook = load_workbook(path, read_only=True, data_only=True)
    if workbook.sheetnames != ["places"]:
        raise ValueError(f"{path}: ожидался единственный лист places")
    sheet = workbook["places"]
    rows = sheet.iter_rows(values_only=True)
    header = list(next(rows))
    if header != FIELDS:
        raise ValueError(f"{path}: структура из 20 столбцов не совпадает с требуемой")

    result = []
    seen_ids = set()
    for line_number, values in enumerate(rows, start=2):
        if not any(value is not None for value in values):
            continue
        row = dict(zip(FIELDS, values))
        for field in NULLABLE_TEXT_FIELDS:
            row[field] = _clean(row[field])
        for field in INTEGER_FIELDS:
            value = _clean(row[field])
            row[field] = int(value) if value is not None else None
        for field in NUMERIC_FIELDS:
            value = _clean(row[field])
            row[field] = float(value) if value is not None else None
        for field in FLAG_FIELDS:
            value = row[field]
            row[field] = value.lower().strip() if isinstance(value, str) else value
        if isinstance(row["last_updated"], datetime):
            row["last_updated"] = row["last_updated"].date()
        if row["last_updated"] is not None and not isinstance(row["last_updated"], date):
            row["last_updated"] = date.fromisoformat(str(row["last_updated"]))

        required = ("place_id", "name", "category", "address")
        if any(row[field] is None for field in required):
            raise ValueError(f"{path}:{line_number}: отсутствует обязательное значение")
        if row["place_id"] in seen_ids:
            raise ValueError(f"{path}:{line_number}: дубликат {row['place_id']}")
        seen_ids.add(row["place_id"])
        if row["category"] not in CATEGORIES:
            raise ValueError(f"{path}:{line_number}: неизвестная категория")
        if row["latitude"] is None or not -90 <= row["latitude"] <= 90:
            raise ValueError(f"{path}:{line_number}: некорректная широта")
        if row["longitude"] is None or not -180 <= row["longitude"] <= 180:
            raise ValueError(f"{path}:{line_number}: некорректная долгота")
        if row["rating"] is not None and not 1 <= row["rating"] <= 5:
            raise ValueError(f"{path}:{line_number}: рейтинг вне диапазона 1–5")
        for field in INTEGER_FIELDS:
            if row[field] is not None and row[field] < 0:
                raise ValueError(f"{path}:{line_number}: отрицательное {field}")
        for field in FLAG_FIELDS:
            if row[field] is not None and row[field] not in FLAGS:
                raise ValueError(f"{path}:{line_number}: некорректный {field}")
        if row["travel_mode"] not in (None, "walking", "metro"):
            raise ValueError(f"{path}:{line_number}: некорректный travel_mode")
        row["campus_id"] = campus["id"]
        result.append(row)
    workbook.close()

    if len(result) != campus["expected_rows"]:
        raise ValueError(
            f"{path}: получено {len(result)} строк вместо {campus['expected_rows']}"
        )
    return result


def import_datasets(database: Database, datasets: dict[str, str | Path]) -> None:
    database.ensure_schema()
    campuses = {campus["id"]: campus for campus in CAMPUSES}
    loaded = {
        campus_id: load_dataset(path, campuses[campus_id])
        for campus_id, path in datasets.items()
    }
    if set(loaded) != set(campuses):
        raise ValueError("Нужно передать оба набора данных")

    columns = ["campus_id", *FIELDS]
    assignments = ", ".join(f"{field} = EXCLUDED.{field}" for field in FIELDS)
    sql = f"""
        INSERT INTO places ({', '.join(columns)})
        VALUES ({', '.join(['%s'] * len(columns))})
        ON CONFLICT (campus_id, place_id) DO UPDATE SET {assignments}, imported_at = now()
    """
    with database.connect() as connection:
        with connection.cursor() as cursor:
            for campus in CAMPUSES:
                cursor.execute(
                    """
                    INSERT INTO campuses (id, name, address, latitude, longitude)
                    VALUES (%(id)s, %(name)s, %(address)s, %(latitude)s, %(longitude)s)
                    ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name,
                        address = EXCLUDED.address, latitude = EXCLUDED.latitude,
                        longitude = EXCLUDED.longitude
                    """,
                    campus,
                )
                rows = loaded[campus["id"]]
                cursor.executemany(sql, [[row[field] for field in columns] for row in rows])
                cursor.execute(
                    "DELETE FROM places WHERE campus_id = %s AND NOT (place_id = ANY(%s))",
                    (campus["id"], [row["place_id"] for row in rows]),
                )
                print(f"{campus['id']}: импортировано {len(rows)} мест")


def main() -> None:
    parser = argparse.ArgumentParser(description="Импорт Excel Spot4u в PostgreSQL")
    parser.add_argument("--leningradsky", required=True)
    parser.add_argument("--veshnyakovsky", required=True)
    args = parser.parse_args()
    import_datasets(
        Database(),
        {
            "leningradsky": args.leningradsky,
            "veshnyakovsky": args.veshnyakovsky,
        },
    )


if __name__ == "__main__":
    main()
