# NOTAM-Aware Flight Route Planning for Indian Airspace (v2)

Ingests NOTAMs, parses the Q-line into circle geometries, classifies severity, stores everything in PostGIS,
retrieves only trip-relevant NOTAMs, rejects conflicting routes and shows the shortest feasible route on a map.
*Decision support for research only; not for operational use.*

## Quick start
```bash
cp .env.example .env
docker compose up -d
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn api.main:app --reload
```

## Ownership
Person A: `ingestion/` `parsing/` `classification/` `api/relevance.py` `db/`
Person B: `static_data/` `routing/` `api/` `web/`
Shared: `tests/` `evaluation/` `docs/`
