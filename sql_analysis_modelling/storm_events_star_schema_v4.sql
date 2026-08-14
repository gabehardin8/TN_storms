-- =====================================================================
-- STAR SCHEMA v4 (final): NOAA Storm Events (22-column file)
-- =====================================================================
-- Dialect: PostgreSQL.
--
-- GRAIN: fact_storm_events = one row per EVENT_ID (15,464 rows).
--
-- This is the leanest version of the file: no intensity fields, no
-- named-location text, just frequency/duration/damage/geography/impact.
--
-- FACT vs. DIMENSION SEPARATION -- the fact table below is grouped into
-- four clearly labeled sections so nothing sits there ambiguously:
--   1. grain            -- the natural key, one per event
--   2. dimension FKs     -- mandatory links out to the 3 dimension tables
--   3. degenerate dims   -- identifiers/descriptors with no extra
--                           attributes worth their own table (see note
--                           below each one for why)
--   4. measures          -- the actual numbers a BI tool sums/averages
--
-- A "degenerate dimension" is standard star-schema terminology (not a
-- shortcut) for exactly this case: a business identifier that lives on
-- the fact row because there's nothing else to normalize it against.
--   - episode_id: groups events into a shared weather episode, but with
--     the narrative text long gone, there's no other attribute left to
--     justify a dim_episode table -- it would just be a table of bare
--     IDs, which is a table that adds a join for no descriptive payoff.
--   - begin_time / end_time: time-of-day. Dimensionalizing time is a
--     real, common pattern (a dim_time table for hour/AM-PM/part-of-day
--     analysis) -- deliberately skipped here to keep this schema at the
--     "every join is mandatory, every table earns its place" level we
--     built up to. Add one later if you want to slice by time-of-day.
--
-- Lat/lon are kept in their own section, separate from the measures,
-- because they aren't really facts you'd sum or average -- they're a
-- geographic coordinate attached to the event, nullable for the ~35%
-- of rows with no precise point reported.
-- =====================================================================


-- =====================================================================
-- 0. STAGING TABLE (mirrors this file's 22 columns)
-- =====================================================================
DROP TABLE IF EXISTS stg_storm_events;

CREATE TABLE stg_storm_events (
    begin_date         VARCHAR(9),
    begin_time         TIME,
    end_date           VARCHAR(9),
    end_time           TIME,
    episode_id         INTEGER,
    event_id           BIGINT,
    event_type         VARCHAR(50),
    cz_name            VARCHAR(100),
    cz_timezone        VARCHAR(10),
    injuries_direct    INTEGER,
    injuries_indirect  INTEGER,
    deaths_direct      INTEGER,
    deaths_indirect    INTEGER,
    damage_property    NUMERIC(15,2),
    damage_crops       NUMERIC(15,2),
    begin_lat          NUMERIC(8,5),
    begin_lon          NUMERIC(8,5),
    end_lat            NUMERIC(8,5),
    end_lon            NUMERIC(8,5),
    road_closures      BOOLEAN,
    power_outage       BOOLEAN,
    total_severity     NUMERIC(10,6)
);

-- \copy stg_storm_events FROM 'details_bi.csv' WITH (FORMAT csv, HEADER true)


-- =====================================================================
-- 1. DIMENSIONS
-- =====================================================================

-- ---- dim_date : swap this for the one you already built --------------
DROP TABLE IF EXISTS dim_date CASCADE;

CREATE TABLE dim_date (
    date_key      INTEGER PRIMARY KEY,        -- YYYYMMDD
    full_date     DATE NOT NULL UNIQUE,
    day_of_month  SMALLINT NOT NULL,
    day_name      VARCHAR(9) NOT NULL,
    day_of_week   SMALLINT NOT NULL,
    week_of_year  SMALLINT NOT NULL,
    month_num     SMALLINT NOT NULL,
    month_name    VARCHAR(9) NOT NULL,
    quarter       SMALLINT NOT NULL,
    year          SMALLINT NOT NULL,
    is_weekend    BOOLEAN NOT NULL
);

-- ---- dim_event_type ----------------------------------------------------
DROP TABLE IF EXISTS dim_event_type CASCADE;

CREATE TABLE dim_event_type (
    event_type_key   SERIAL PRIMARY KEY,
    event_type_name  VARCHAR(50) NOT NULL UNIQUE
);

-- ---- dim_location --------------------------------------------------------
DROP TABLE IF EXISTS dim_location CASCADE;

CREATE TABLE dim_location (
    location_key  SERIAL PRIMARY KEY,
    county_name   VARCHAR(100) NOT NULL,
    state_name    VARCHAR(50) NOT NULL,
    cz_timezone   VARCHAR(10) NOT NULL,
    UNIQUE (county_name, state_name, cz_timezone)
);


-- =====================================================================
-- 2. FACT TABLE
-- =====================================================================
DROP TABLE IF EXISTS fact_storm_events;

CREATE TABLE fact_storm_events (

    -- 1. grain ----------------------------------------------------------
    event_id           BIGINT PRIMARY KEY,

    -- 2. dimension foreign keys (mandatory, never null) -----------------
    event_type_key      INTEGER NOT NULL REFERENCES dim_event_type(event_type_key),
    location_key         INTEGER NOT NULL REFERENCES dim_location(location_key),
    begin_date_key         INTEGER NOT NULL REFERENCES dim_date(date_key),
    end_date_key             INTEGER NOT NULL REFERENCES dim_date(date_key),

    -- 3. degenerate dimensions (identifiers/time kept on the fact row,
    --    see header note for why each stays here) -----------------------
    episode_id           INTEGER,
    begin_time             TIME NOT NULL,
    end_time                 TIME NOT NULL,

    -- geographic point detail (nullable; not a summable measure) --------
    begin_lat    NUMERIC(8,5),
    begin_lon    NUMERIC(8,5),
    end_lat      NUMERIC(8,5),
    end_lon      NUMERIC(8,5),

    -- 4. measures (sum/average these in your BI tool) --------------------
    injuries_direct     INTEGER DEFAULT 0,
    injuries_indirect    INTEGER DEFAULT 0,
    deaths_direct          INTEGER DEFAULT 0,
    deaths_indirect          INTEGER DEFAULT 0,
    damage_property            NUMERIC(15,2) DEFAULT 0,
    damage_crops                 NUMERIC(15,2) DEFAULT 0,
    road_closures                   BOOLEAN DEFAULT FALSE,
    power_outage                      BOOLEAN DEFAULT FALSE,
    total_severity                      NUMERIC(10,6) NOT NULL
);

CREATE INDEX idx_fact_event_type ON fact_storm_events (event_type_key);
CREATE INDEX idx_fact_location   ON fact_storm_events (location_key);
CREATE INDEX idx_fact_begin_date ON fact_storm_events (begin_date_key);


-- =====================================================================
-- 3. ETL: populate dimensions and fact table from staging
-- =====================================================================

-- ---- dim_date : one row per day spanning the file's date range -------
INSERT INTO dim_date (
    date_key, full_date, day_of_month, day_name, day_of_week,
    week_of_year, month_num, month_name, quarter, year, is_weekend
)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,
    d,
    EXTRACT(DAY FROM d)::SMALLINT,
    TO_CHAR(d, 'FMDay'),
    EXTRACT(ISODOW FROM d)::SMALLINT,
    EXTRACT(WEEK FROM d)::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    TO_CHAR(d, 'FMMonth'),
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(YEAR FROM d)::SMALLINT,
    EXTRACT(ISODOW FROM d) IN (6, 7)
FROM (
    SELECT generate_series(
        (SELECT MIN(TO_DATE(begin_date, 'DD-MON-YY')) FROM stg_storm_events),
        (SELECT MAX(TO_DATE(end_date,   'DD-MON-YY')) FROM stg_storm_events),
        INTERVAL '1 day'
    )::DATE AS d
) days
ON CONFLICT (date_key) DO NOTHING;

-- ---- dim_event_type ----------------------------------------------------
INSERT INTO dim_event_type (event_type_name)
SELECT DISTINCT event_type
FROM stg_storm_events
ON CONFLICT (event_type_name) DO NOTHING;

-- ---- dim_location --------------------------------------------------------
INSERT INTO dim_location (county_name, state_name, cz_timezone)
SELECT DISTINCT
    TRIM(SPLIT_PART(cz_name, ',', 1)),
    TRIM(SPLIT_PART(cz_name, ',', 2)),
    cz_timezone
FROM stg_storm_events
ON CONFLICT (county_name, state_name, cz_timezone) DO NOTHING;

-- ---- fact_storm_events -----------------------------------------------------
INSERT INTO fact_storm_events (
    event_id, event_type_key, location_key, begin_date_key, end_date_key,
    episode_id, begin_time, end_time,
    begin_lat, begin_lon, end_lat, end_lon,
    injuries_direct, injuries_indirect, deaths_direct, deaths_indirect,
    damage_property, damage_crops, road_closures, power_outage,
    total_severity
)
SELECT
    s.event_id,
    et.event_type_key,
    loc.location_key,
    TO_CHAR(TO_DATE(s.begin_date, 'DD-MON-YY'), 'YYYYMMDD')::INTEGER,
    TO_CHAR(TO_DATE(s.end_date,   'DD-MON-YY'), 'YYYYMMDD')::INTEGER,
    s.episode_id, s.begin_time, s.end_time,
    s.begin_lat, s.begin_lon, s.end_lat, s.end_lon,
    COALESCE(s.injuries_direct, 0), COALESCE(s.injuries_indirect, 0),
    COALESCE(s.deaths_direct, 0), COALESCE(s.deaths_indirect, 0),
    COALESCE(s.damage_property, 0), COALESCE(s.damage_crops, 0),
    COALESCE(s.road_closures, FALSE), COALESCE(s.power_outage, FALSE),
    s.total_severity
FROM stg_storm_events s
JOIN dim_event_type et ON et.event_type_name = s.event_type
JOIN dim_location loc  ON loc.county_name = TRIM(SPLIT_PART(s.cz_name, ',', 1))
                       AND loc.state_name  = TRIM(SPLIT_PART(s.cz_name, ',', 2))
                       AND loc.cz_timezone = s.cz_timezone
ON CONFLICT (event_id) DO NOTHING;


-- =====================================================================
-- 4. Example query
-- =====================================================================
-- SELECT dd.year, et.event_type_name, COUNT(*) AS event_count,
--        SUM(f.damage_property + f.damage_crops) AS total_damage,
--        AVG(f.total_severity) AS avg_severity
-- FROM fact_storm_events f
-- JOIN dim_date dd       ON dd.date_key = f.begin_date_key
-- JOIN dim_event_type et ON et.event_type_key = f.event_type_key
-- GROUP BY dd.year, et.event_type_name
-- ORDER BY dd.year, total_damage DESC;
