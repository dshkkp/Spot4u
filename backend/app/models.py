from typing import Literal

from pydantic import BaseModel, Field, field_validator

Category = Literal["cafe", "coffee_shop", "library", "coworking", "anticafe"]
Priority = Literal["balanced", "nearest", "cheapest"]
Flag = Literal["yes", "no", "unknown"] | None
TravelMode = Literal["walking", "metro"] | None
OpenStatus = Literal["open", "closed", "unknown"]


class SearchFilters(BaseModel):
    wifi: bool = False
    sockets: bool = False
    laptop_friendly: bool = False
    student_discount: bool = False
    open_now: bool = False
    max_avg_check_rub: int | None = Field(default=None, ge=0, le=100000)
    max_travel_time_min: int | None = Field(default=None, ge=0, le=1440)


class SearchRequest(BaseModel):
    origin_id: str = Field(min_length=1, max_length=64)
    categories: list[Category] = Field(min_length=1, max_length=5)
    priority: Priority = "balanced"
    filters: SearchFilters = SearchFilters()

    @field_validator("categories")
    @classmethod
    def unique_categories(cls, value: list[Category]) -> list[Category]:
        if len(set(value)) != len(value):
            raise ValueError("Категории не должны повторяться")
        return value


class Campus(BaseModel):
    id: str
    name: str
    address: str
    latitude: float
    longitude: float


class Place(BaseModel):
    place_id: str
    name: str
    category: Category
    address: str
    latitude: float
    longitude: float
    opening_hours: str | None
    rating: float | None
    review_count: int | None
    avg_check_rub: int | None
    wifi: Flag
    sockets: Flag
    laptop_friendly: Flag
    student_discount: Flag
    website: str | None
    phone: str | None
    source: str | None
    last_updated: str | None
    travel_time_min: int | None
    travel_mode: TravelMode
    open_status: OpenStatus
    study_score: float


class SearchResponse(BaseModel):
    origin: Campus
    priority: Priority
    count: int
    places: list[Place]
