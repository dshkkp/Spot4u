CREATE TABLE IF NOT EXISTS campuses (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL
);

CREATE TABLE IF NOT EXISTS places (
    campus_id TEXT NOT NULL REFERENCES campuses(id) ON DELETE CASCADE,
    place_id TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    address TEXT NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    opening_hours TEXT,
    rating DOUBLE PRECISION,
    review_count INTEGER,
    avg_check_rub INTEGER,
    wifi TEXT,
    sockets TEXT,
    laptop_friendly TEXT,
    student_discount TEXT,
    website TEXT,
    phone TEXT,
    source TEXT,
    last_updated DATE,
    travel_time_min INTEGER,
    travel_mode TEXT,
    imported_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (campus_id, place_id),
    CHECK (rating IS NULL OR rating BETWEEN 1 AND 5),
    CHECK (review_count IS NULL OR review_count >= 0),
    CHECK (avg_check_rub IS NULL OR avg_check_rub >= 0),
    CHECK (travel_time_min IS NULL OR travel_time_min >= 0),
    CHECK (category IN ('cafe', 'coffee_shop', 'library', 'coworking', 'anticafe')),
    CHECK (wifi IN ('yes', 'no', 'unknown') OR wifi IS NULL),
    CHECK (sockets IN ('yes', 'no', 'unknown') OR sockets IS NULL),
    CHECK (laptop_friendly IN ('yes', 'no', 'unknown') OR laptop_friendly IS NULL),
    CHECK (student_discount IN ('yes', 'no', 'unknown') OR student_discount IS NULL),
    CHECK (travel_mode IN ('walking', 'metro') OR travel_mode IS NULL)
);

CREATE INDEX IF NOT EXISTS places_campus_category_idx ON places (campus_id, category);
