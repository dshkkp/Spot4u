from __future__ import annotations

import csv
import json
import math
import os
import re
import sys
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

import requests

ROOT = Path(__file__).resolve().parent
DATA = ROOT / "data"
RAW = DATA / "raw"
KEY_FILE = ROOT / ".2gis_key"

SEARCH_URL = "https://catalog.api.2gis.com/3.0/items"
BYID_URL = "https://catalog.api.2gis.com/3.0/items/byid"

TARGET = 50
PAGE_SIZE = 10          # demo key: max 10
MAX_PAGES = 5           # demo key: max page 5

ANCHORS = [
    ("Финансовый университет", 55.7184, 37.7957, 2000),
    ("Текстильщики", 55.70881677, 37.73242901, 700),
    ("Кузьминки", 55.70549, 37.76640443, 700),
    ("Рязанский проспект", 55.716944, 37.793333, 700),
    ("Выхино", 55.71545536, 37.81860885, 700),
    ("Лермонтовский проспект", 55.701389, 37.8525, 700),
]

SEARCHES = [
    ("coffee_shop", "кофейня"),
    ("cafe", "кафе"),
    ("library", "библиотека"),
    ("coworking", "коворкинг"),
    ("anticafe", "антикафе"),
]

EXCLUDE_WORDS = [
    "чайхана", "чай-хана",
    "кальян", "hookah",
    "караоке", "karaoke",
    "ночной клуб",
    "стриптиз",
    "банкетный зал",
]

DISCOVERY_FIELDS = "items.point,items.rubrics,items.full_address_name"
DETAIL_FIELDS = ",".join([
    "items.point",
    "items.address",
    "items.full_address_name",
    "items.rubrics",
    "items.schedule",
    "items.reviews",
    "items.attribute_groups",
    "items.dates",
    "items.has_discount",
    "items.is_deleted",
])

HEADERS = {"User-Agent": "Spot4u-student-project/2.1", "Accept": "application/json"}


def get_key() -> str:
    env = os.environ.get("TWOGIS_API_KEY", "").strip()
    if env:
        return env
    if KEY_FILE.exists():
        key = KEY_FILE.read_text(encoding="utf-8").strip()
        if key:
            return key
    print("Вставьте НОВЫЙ demo/API key 2ГИС и нажмите Enter.")
    print("Ключ будет сохранён только локально в .2gis_key.")
    key = input("2GIS key: ").strip()
    if not key:
        raise RuntimeError("Ключ не введён.")
    KEY_FILE.write_text(key, encoding="utf-8")
    return key


def api_get(url: str, params: dict[str, Any]) -> dict[str, Any]:
    last = None
    for attempt in range(1, 4):
        try:
            r = requests.get(url, params=params, headers=HEADERS, timeout=(15, 60))
            try:
                data = r.json()
            except Exception:
                data = None

            if r.status_code == 200 and isinstance(data, dict):
                meta = data.get("meta") or {}
                code = int(meta.get("code") or 200)
                if code == 200:
                    return data
                err = meta.get("error") or {}
                raise RuntimeError(
                    f"2GIS meta.code={code}; "
                    f"type={err.get('type','?')}; message={err.get('message','?')}"
                )

            if isinstance(data, dict):
                meta = data.get("meta") or {}
                err = meta.get("error") or {}
                msg = (
                    f"HTTP {r.status_code}; meta.code={meta.get('code','?')}; "
                    f"type={err.get('type','?')}; message={err.get('message','?')}"
                )
            else:
                msg = f"HTTP {r.status_code}: {(r.text or '')[:300]}"

            last = RuntimeError(msg)
            if r.status_code in (429, 500, 502, 503, 504):
                time.sleep(2 * attempt)
                continue
            raise last

        except Exception as e:
            last = e
            if attempt < 3:
                time.sleep(2 * attempt)

    raise RuntimeError(str(last))


def diagnostic(key: str) -> None:
    # Intentionally minimal official-style request.
    params = {
        "key": key,
        "q": "кафе",
        "location": f"{ANCHORS[0][2]},{ANCHORS[0][1]}",
        "type": "branch",
        "page_size": 3,
        "locale": "ru_RU",
    }
    print("Проверяю ключ и базовый запрос 2ГИС...")
    data = api_get(SEARCH_URL, params)
    n = len(((data.get("result") or {}).get("items") or []))
    print(f"OK: 2ГИС отвечает, тестовых результатов: {n}")


def haversine_m(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    rr = 6371000.0
    p1, p2 = math.radians(lat1), math.radians(lat2)
    dp = math.radians(lat2-lat1)
    dl = math.radians(lon2-lon1)
    a = math.sin(dp/2)**2 + math.cos(p1)*math.cos(p2)*math.sin(dl/2)**2
    return 2*rr*math.atan2(math.sqrt(a), math.sqrt(1-a))


def get_point(item: dict[str, Any]) -> tuple[float | None, float | None]:
    p = item.get("point") or {}
    try:
        return float(p["lat"]), float(p["lon"])
    except Exception:
        return None, None


def item_name(item: dict[str, Any]) -> str:
    return str(item.get("name") or "").strip()


def rubrics(item: dict[str, Any]) -> list[str]:
    out = []
    for r in item.get("rubrics") or []:
        if isinstance(r, dict) and r.get("name"):
            out.append(str(r["name"]))
    return out


def flat_strings(x: Any) -> list[str]:
    out = []
    if isinstance(x, str):
        out.append(x)
    elif isinstance(x, list):
        for y in x:
            out.extend(flat_strings(y))
    elif isinstance(x, dict):
        for k, v in x.items():
            if isinstance(k, str):
                out.append(k)
            out.extend(flat_strings(v))
    return out


def excluded(item: dict[str, Any]) -> tuple[bool, str]:
    text = " ".join([item_name(item), *rubrics(item), *flat_strings(item.get("attribute_groups") or [])])
    text = text.lower().replace("ё", "е")
    for w in EXCLUDE_WORDS:
        if w.replace("ё", "е") in text:
            return True, w
    if item.get("is_deleted") is True:
        return True, "deleted"
    return False, ""


def address(item: dict[str, Any]) -> str:
    for k in ("full_address_name", "address_name"):
        v = item.get(k)
        if isinstance(v, str) and v.strip():
            return v.strip()
    a = item.get("address")
    if isinstance(a, str):
        return a.strip()
    if isinstance(a, dict):
        for k in ("name", "full_name", "address_name"):
            v = a.get(k)
            if isinstance(v, str) and v.strip():
                return v.strip()
    return ""


def schedule_text(schedule: Any) -> str:
    if not isinstance(schedule, dict):
        return ""
    order = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    ru = {"Mon":"Пн","Tue":"Вт","Wed":"Ср","Thu":"Чт","Fri":"Пт","Sat":"Сб","Sun":"Вс"}
    parts = []
    for d in order:
        entry = schedule.get(d)
        if not isinstance(entry, dict):
            continue
        intervals = []
        for h in entry.get("working_hours") or []:
            if isinstance(h, dict) and h.get("from") and h.get("to"):
                intervals.append(f"{h['from']}–{h['to']}")
        if intervals:
            parts.append(f"{ru[d]} {'; '.join(intervals)}")
    return "; ".join(parts)


def detect_yes(text: str, keys: list[str]) -> str:
    t = text.lower().replace("ё","е")
    return "yes" if any(k.replace("ё","е") in t for k in keys) else ""


def parse_check(text: str) -> str:
    t = text.lower().replace("\xa0"," ")
    for pat in [
        r"средн(?:ий|его)\s+чек[^0-9]{0,25}(\d{2,5})",
        r"чек[^0-9]{0,25}(\d{2,5})\s*₽",
    ]:
        m = re.search(pat, t, re.I)
        if m:
            return m.group(1)
    return ""


def category_from(item: dict[str, Any], found_as: set[str]) -> str:
    txt = (" ".join(rubrics(item)) + " " + item_name(item)).lower().replace("ё","е")
    if "антикаф" in txt:
        return "anticafe"
    if "коворкинг" in txt:
        return "coworking"
    if "библиотек" in txt:
        return "library"
    if "кофейн" in txt or "кофе" in txt:
        return "coffee_shop"
    if "кафе" in txt:
        return "cafe"
    for c in ("coworking","library","coffee_shop","anticafe","cafe"):
        if c in found_as:
            return c
    return "cafe"


def enrich_row(item: dict[str, Any], meta: dict[str, Any]) -> dict[str, Any]:
    lat, lon = get_point(item)
    attrs = " | ".join(flat_strings(item.get("attribute_groups") or []))
    rv = item.get("reviews") or {}
    if not isinstance(rv, dict):
        rv = {}

    row = {
        "2gis_id": str(item.get("id") or ""),
        "name": item_name(item),
        "category": category_from(item, meta["found_as"]),
        "address": address(item),
        "lat": lat if lat is not None else "",
        "lon": lon if lon is not None else "",
        "zones": ";".join(sorted(meta["zones"])),
        "nearest_zone": meta["nearest_zone"],
        "distance_to_nearest_zone_m": round(meta["nearest_dist"]),
        "opening_hours": schedule_text(item.get("schedule")),
        "rating": rv.get("rating") or rv.get("general_rating") or rv.get("org_rating") or "",
        "review_count": rv.get("review_count") or rv.get("general_review_count") or rv.get("org_review_count") or "",
        "avg_check_rub": parse_check(attrs),
        "wifi": detect_yes(attrs, ["wi-fi","wifi","вай-фай"]),
        "sockets": detect_yes(attrs, ["розетк"]),
        "laptop_friendly": detect_yes(attrs, ["можно с ноутбуком","работа с ноутбуком","ноутбук"]),
        "has_discount": item.get("has_discount") if item.get("has_discount") is not None else "",
        "student_discount": detect_yes(attrs, ["студенческ","скидка студент"]),
        "rubrics": "; ".join(rubrics(item)),
        "source": "2GIS Places API",
        "collected_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat(),
    }
    return row


def pre_score(meta: dict[str, Any], item: dict[str, Any]) -> float:
    found = meta["found_as"]
    base = 0
    if "coworking" in found: base = max(base, 5)
    if "library" in found: base = max(base, 4.7)
    if "coffee_shop" in found: base = max(base, 4.3)
    if "anticafe" in found: base = max(base, 4.0)
    if "cafe" in found: base = max(base, 3.0)
    # closer to one of our anchor zones is preferred
    base += max(0.0, 1.0 - meta["nearest_dist"]/2500.0)
    return base


def choose_balanced(candidates: dict[str, dict[str, Any]], n: int) -> list[str]:
    zone_order = [a[0] for a in ANCHORS]
    buckets: dict[str, list[tuple[float,str]]] = {z: [] for z in zone_order}
    for pid, x in candidates.items():
        z = x["nearest_zone"]
        buckets.setdefault(z, []).append((pre_score(x, x["item"]), pid))
    for z in buckets:
        buckets[z].sort(reverse=True)

    selected, used = [], set()
    while len(selected) < n:
        added = False
        for z in zone_order:
            bucket = buckets.get(z, [])
            while bucket and bucket[0][1] in used:
                bucket.pop(0)
            if bucket and len(selected) < n:
                _, pid = bucket.pop(0)
                selected.append(pid)
                used.add(pid)
                added = True
        if not added:
            break

    if len(selected) < n:
        rest = []
        for pid, x in candidates.items():
            if pid not in used:
                rest.append((pre_score(x, x["item"]), pid))
        rest.sort(reverse=True)
        for _, pid in rest:
            if len(selected) >= n:
                break
            selected.append(pid)
            used.add(pid)
    return selected[:n]


def main() -> int:
    DATA.mkdir(parents=True, exist_ok=True)
    RAW.mkdir(parents=True, exist_ok=True)
    key = get_key()

    # If this fails, the script prints the exact 2GIS error instead of 30 vague 400s.
    diagnostic(key)

    pool: dict[str, dict[str, Any]] = {}
    errors: list[str] = []

    req = 0
    total_max = len(ANCHORS)*len(SEARCHES)*MAX_PAGES

    for zone_name, lat0, lon0, radius in ANCHORS:
        for found_as, q in SEARCHES:
            for page in range(1, MAX_PAGES+1):
                req += 1
                print(f"[{req}/{total_max}] {zone_name} / {q} / стр. {page}")
                params = {
                    "key": key,
                    "q": q,
                    # Use official location-based discovery. We filter exact radius ourselves.
                    "location": f"{lon0},{lat0}",
                    "type": "branch",
                    "page": page,
                    "page_size": PAGE_SIZE,
                    "locale": "ru_RU",
                    "fields": DISCOVERY_FIELDS,
                }
                try:
                    data = api_get(SEARCH_URL, params)
                except Exception as e:
                    msg = f"{zone_name}/{q}/page={page}: {e}"
                    print("   WARNING:", msg)
                    errors.append(msg)
                    break

                (RAW / f"{re.sub(r'[^a-zа-я0-9]+','_',zone_name.lower())}_{found_as}_{page}.json").write_text(
                    json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8"
                )

                items = ((data.get("result") or {}).get("items") or [])
                if not items:
                    break

                accepted_this_page = 0
                for item in items:
                    if item.get("type") != "branch":
                        continue
                    pid = str(item.get("id") or "")
                    if not pid:
                        continue
                    plat, plon = get_point(item)
                    if plat is None or plon is None:
                        continue
                    dist = haversine_m(lat0, lon0, plat, plon)
                    if dist > radius:
                        continue
                    bad, why = excluded(item)
                    if bad:
                        continue

                    accepted_this_page += 1
                    if pid not in pool:
                        pool[pid] = {
                            "item": item,
                            "zones": set(),
                            "found_as": set(),
                            "nearest_zone": zone_name,
                            "nearest_dist": dist,
                        }
                    pool[pid]["zones"].add(zone_name)
                    pool[pid]["found_as"].add(found_as)
                    if dist < pool[pid]["nearest_dist"]:
                        pool[pid]["nearest_dist"] = dist
                        pool[pid]["nearest_zone"] = zone_name

                # If this page already went mostly outside our strict radius,
                # later pages are even farther; stop paging this query.
                if accepted_this_page == 0 and page >= 2:
                    break

                time.sleep(0.15)

    if not pool:
        raise RuntimeError("2ГИС ответил, но после фильтрации в заданных радиусах не осталось кандидатов.")

    ids = choose_balanced(pool, min(TARGET, len(pool)))
    print(f"\nНайдено кандидатов: {len(pool)}. Получаю подробности для {len(ids)} выбранных мест...")

    result = []
    for i, pid in enumerate(ids, 1):
        print(f"  [{i}/{len(ids)}] {pool[pid]['item'].get('name','')}")
        params = {
            "key": key,
            "id": pid,
            "locale": "ru_RU",
            "fields": DETAIL_FIELDS,
        }
        try:
            data = api_get(BYID_URL, params)
            items = ((data.get("result") or {}).get("items") or [])
            item = items[0] if items else pool[pid]["item"]
        except Exception as e:
            print("     WARNING details:", e)
            item = pool[pid]["item"]

        bad, why = excluded(item)
        if bad:
            # safety: if detailed rubrics reveal чайхана etc., do not include it
            continue

        result.append(enrich_row(item, pool[pid]))
        time.sleep(0.15)

    fields = [
        "2gis_id","name","category","address","lat","lon","zones","nearest_zone",
        "distance_to_nearest_zone_m","opening_hours","rating","review_count","avg_check_rub",
        "wifi","sockets","laptop_friendly","has_discount","student_discount","rubrics",
        "source","collected_at"
    ]

    out = DATA / "places_2gis_50.csv"
    with out.open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader()
        w.writerows(result)

    summary = [
        "Spot4u — прямой сбор через 2ГИС v2",
        f"Кандидатов в строгих зонах: {len(pool)}",
        f"Итоговых мест: {len(result)}",
        f"Ошибок discovery: {len(errors)}",
        "",
        "Исключаются: " + ", ".join(EXCLUDE_WORDS),
        "Пустое wifi/sockets/laptop_friendly/student_discount = неизвестно.",
        "has_discount = любая скидка, НЕ обязательно студенческая.",
    ]
    if errors:
        summary += ["", "Ошибки:"] + errors
    (DATA / "collection_summary.txt").write_text("\n".join(summary), encoding="utf-8")

    print("\nГОТОВО")
    print(f"Итоговых мест: {len(result)}")
    print(f"Файл: {out}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as e:
        print("\nОШИБКА:", e)
        print("Если это ошибка 2ГИС, теперь выше будет показан её точный type/message.")
        raise SystemExit(1)
