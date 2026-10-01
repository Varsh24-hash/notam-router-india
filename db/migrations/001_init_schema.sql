CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgrouting;

CREATE TABLE data_source (source_id SERIAL PRIMARY KEY, name TEXT, access_type TEXT, active BOOLEAN);
CREATE TABLE ingestion_run (run_id BIGSERIAL PRIMARY KEY, source_id INT REFERENCES data_source,
  started_at TIMESTAMPTZ, finished_at TIMESTAMPTZ, records_fetched INT, status TEXT);
CREATE TABLE raw_notam (raw_id BIGSERIAL PRIMARY KEY, run_id BIGINT REFERENCES ingestion_run,
  notam_id TEXT, raw_text TEXT, fetched_at TIMESTAMPTZ, content_hash TEXT UNIQUE);

CREATE TABLE fir (icao_code TEXT PRIMARY KEY, name TEXT, boundary GEOMETRY(MultiPolygon,4326));
CREATE TABLE airport (icao_code TEXT PRIMARY KEY, iata_code TEXT, name TEXT, city TEXT,
  fir_code TEXT REFERENCES fir, location GEOMETRY(Point,4326));

CREATE TABLE notam_event (
  event_id BIGSERIAL PRIMARY KEY, raw_id BIGINT REFERENCES raw_notam,
  notam_id TEXT, action CHAR(1), replaces_event_id BIGINT REFERENCES notam_event,
  fir_code TEXT REFERENCES fir, icao_location TEXT,
  q_code TEXT, lower_fl INT, upper_fl INT,
  valid_during TSTZRANGE,
  geom GEOMETRY(Polygon,4326), radius_nm NUMERIC,
  category TEXT, severity TEXT, classifier_conf REAL, e_text TEXT);
CREATE INDEX ON notam_event USING GIST (geom);
CREATE INDEX ON notam_event USING GIST (valid_during);
CREATE INDEX ON notam_event (icao_location, fir_code);

CREATE TABLE waypoint (waypoint_id SERIAL PRIMARY KEY, ident TEXT, location GEOMETRY(Point,4326));
CREATE TABLE airway (airway_id SERIAL PRIMARY KEY, designator TEXT);
CREATE TABLE airway_edge (edge_id SERIAL PRIMARY KEY, airway_id INT REFERENCES airway,
  from_waypoint_id INT REFERENCES waypoint, to_waypoint_id INT REFERENCES waypoint,
  dist_nm REAL, lower_fl INT, upper_fl INT, geom GEOMETRY(LineString,4326));

CREATE TABLE route_request (request_id BIGSERIAL PRIMARY KEY, origin_icao TEXT REFERENCES airport,
  dest_icao TEXT REFERENCES airport, etd_utc TIMESTAMPTZ, cruise_fl INT, cruise_tas_kt INT);
CREATE TABLE candidate_route (route_id BIGSERIAL PRIMARY KEY, request_id BIGINT REFERENCES route_request,
  total_dist_nm REAL, est_time_min REAL, is_feasible BOOLEAN, is_selected BOOLEAN,
  reject_reason TEXT, path GEOMETRY(LineString,4326));
CREATE TABLE route_conflict (conflict_id BIGSERIAL PRIMARY KEY, route_id BIGINT REFERENCES candidate_route,
  event_id BIGINT REFERENCES notam_event, conflict_type TEXT, explanation TEXT);

CREATE INDEX ON fir USING GIST (boundary);
CREATE INDEX ON airport USING GIST (location);
CREATE INDEX ON airway_edge USING GIST (geom);
