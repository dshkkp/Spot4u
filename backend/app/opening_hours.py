import re
from datetime import datetime

WEEKDAY_NAMES = ("Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс")
UNKNOWN_SCHEDULE_VALUE = "unknown"
_TIME = re.compile(r"^(\d{1,2}):(\d{2})[–—-](\d{1,2}):(\d{2})$")


def _time_to_minutes(hour: str, minute: str) -> int | None:
    value = int(hour) * 60 + int(minute)
    if int(minute) > 59 or int(hour) > 24 or (int(hour) == 24 and int(minute) != 0):
        return None
    return value


def parse_opening_hours(value: str | None) -> dict[int, list[tuple[int, int]] | None]:
    schedule: dict[int, list[tuple[int, int]] | None] = {}
    if not value or value.strip().lower() == UNKNOWN_SCHEDULE_VALUE:
        return schedule
    for part in value.split(";"):
        part = part.strip()
        if not part or " " not in part:
            continue
        day, raw_interval = part.split(" ", 1)
        if day not in WEEKDAY_NAMES:
            continue
        index = WEEKDAY_NAMES.index(day)
        raw_interval = raw_interval.strip()
        if raw_interval.lower() == UNKNOWN_SCHEDULE_VALUE:
            schedule[index] = None
            continue
        if raw_interval.lower() in ("выходной", "закрыто"):
            schedule[index] = []
            continue
        match = _TIME.fullmatch(raw_interval)
        if not match:
            schedule[index] = None
            continue
        start = _time_to_minutes(match.group(1), match.group(2))
        end = _time_to_minutes(match.group(3), match.group(4))
        if start is None or end is None or start > 1440 or end > 1440:
            schedule[index] = None
        else:
            schedule[index] = [(start, end)]
    return schedule


def _intervals_contain_minute(
    intervals: list[tuple[int, int]] | None, minute: int, previous_day: bool = False
) -> bool | None:
    if intervals is None:
        return None
    offset = 1440 if previous_day else 0
    for start, end in intervals:
        adjusted_end = end + 1440 if end <= start and end != 1440 else end
        if start <= minute + offset < adjusted_end:
            return True
    return False


def opening_status(opening_hours: str | None, now: datetime) -> str:
    schedule = parse_opening_hours(opening_hours)
    minute = now.hour * 60 + now.minute
    today = now.weekday()
    yesterday = (today - 1) % 7

    if _intervals_contain_minute(schedule.get(today, []), minute):
        return "open"
    previous = _intervals_contain_minute(schedule.get(yesterday, []), minute, previous_day=True)
    if previous:
        return "open"
    if today not in schedule or schedule[today] is None or previous is None:
        return "unknown"
    return "closed"
