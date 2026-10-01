# Interface Contract (Person A <-> Person B)
`relevant_notams(src, dst, etd_utc, eta_utc, fl_lo, fl_hi, corridor_nm)` returns GeoJSON features with:
severity, category, lower_fl, upper_fl, valid_during, geom, e_text.
`POST /plan {src, dst, etd_utc, fl}` returns best route, rejected routes with reasons, relevant NOTAMs.
Until real data is ready, Person B develops against `data/seed/seed_notams.json`.
