from collections.abc import AsyncIterator
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse

from .database import Database
from .models import Campus, SearchRequest, SearchResponse
from .search import search_places

database = Database()


@asynccontextmanager
async def prepare_database(_: FastAPI) -> AsyncIterator[None]:
    database.ensure_schema()
    yield


app = FastAPI(title="Spot4u API", version="0.5.0", lifespan=prepare_database)


@app.get("/", include_in_schema=False)
def api_info() -> dict:
    return {"name": "Spot4u API", "version": "0.5.0", "docs": "/docs"}


@app.get("/health")
def database_health():
    try:
        database.ping()
    except Exception:
        return JSONResponse(status_code=503, content={"status": "unavailable"})
    return {"status": "ok"}


@app.get("/api/v1/campuses", response_model=list[Campus])
def campuses() -> list[dict]:
    return database.campuses()


@app.post("/api/v1/search", response_model=SearchResponse)
def search(request: SearchRequest) -> dict:
    campus = database.campus(request.origin_id)
    if campus is None:
        raise HTTPException(status_code=404, detail="Корпус не найден")
    source_places = database.places(request.origin_id, request.categories)
    places = search_places(source_places, request.filters, request.priority)
    return {
        "origin": campus,
        "priority": request.priority,
        "count": len(places),
        "places": places,
    }
