from datetime import datetime
from zoneinfo import ZoneInfo

from .models import SearchFilters
from .opening_hours import opening_status
TIME_NORMALIZATION_MINUTES = 60
COST_NORMALIZATION_RUB = 1000
RATING_PRIOR_REVIEWS = 20
RATING_PRIOR_VALUE = 4.0
WEIGHTS = {
    "time": 0.30,
    "cost": 0.25,
    "sockets": 0.20,
    "wifi": 0.15,
    "rating": 0.10,
}


def clip(value: float, minimum: float = 0.0, maximum: float = 1.0) -> float:
    return max(minimum, min(maximum, value))


def _time_score(minutes: int | None) -> float:
    if minutes is None:
        return 0.5
    return clip(1 - minutes / TIME_NORMALIZATION_MINUTES)


def _cost_score(cost: int | None) -> float:
    if cost is None:
        return 0.5
    return clip(1 - cost / COST_NORMALIZATION_RUB)


def _flag_score(value: str | None) -> float:
    if value == "yes":
        return 1.0
    if value == "no":
        return 0.0
    return 0.5


def _rating_score(rating: float | None, review_count: int | None) -> float:
    if rating is None or review_count is None:
        return 0.5
    smoothed = (
        review_count * rating + RATING_PRIOR_REVIEWS * RATING_PRIOR_VALUE
    ) / (review_count + RATING_PRIOR_REVIEWS)
    return clip((smoothed - 1) / 4)


def calculate_study_score(place: dict) -> float:
    features = {
        "time": _time_score(place.get("travel_time_min")),
        "cost": _cost_score(place.get("avg_check_rub")),
        "sockets": _flag_score(place.get("sockets")),
        "wifi": _flag_score(place.get("wifi")),
        "rating": _rating_score(place.get("rating"), place.get("review_count")),
    }
    return round(100 * sum(features[name] * WEIGHTS[name] for name in WEIGHTS), 2)

MOSCOW_TIMEZONE = ZoneInfo("Europe/Moscow")


def _matches_filters(place: dict, filters: SearchFilters, open_status: str) -> bool:
    for field in ("wifi", "sockets", "laptop_friendly", "student_discount"):
        if getattr(filters, field) and place.get(field) != "yes":
            return False
    if filters.open_now and open_status != "open":
        return False
    if filters.max_avg_check_rub is not None:
        cost = place.get("avg_check_rub")
        if cost is None or cost > filters.max_avg_check_rub:
            return False
    if filters.max_travel_time_min is not None:
        minutes = place.get("travel_time_min")
        if minutes is None or minutes > filters.max_travel_time_min:
            return False
    return True


def search_places(
    rows: list[dict],
    filters: SearchFilters,
    priority: str,
    now: datetime | None = None,
) -> list[dict]:
    current_time = now or datetime.now(MOSCOW_TIMEZONE)
    matches = []
    for row in rows:
        status = opening_status(row.get("opening_hours"), current_time)
        if not _matches_filters(row, filters, status):
            continue
        place = dict(row)
        place["open_status"] = status
        place["study_score"] = calculate_study_score(place)
        matches.append(place)

    if priority == "nearest":
        matches.sort(
            key=lambda place: (
                place["travel_time_min"] is None,
                place["travel_time_min"] if place["travel_time_min"] is not None else 0,
                place["place_id"],
            )
        )
    elif priority == "cheapest":
        matches.sort(
            key=lambda place: (
                place["avg_check_rub"] is None,
                place["avg_check_rub"] if place["avg_check_rub"] is not None else 0,
                place["place_id"],
            )
        )
    else:
        matches.sort(key=lambda place: (-place["study_score"], place["place_id"]))
    return matches
