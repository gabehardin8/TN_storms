--flat file import as source data

CREATE TABLE storms (
	begin_date 			date,
	begin_time			time,
	end_date 			date,
	end_time 			time,
	episode_id 			integer,
	event_id 			integer,
	event_type 			character varying(36),
	cz_name 			character varying(36),
	cz_timezone 		character varying (10),
	injuries_direct 	integer,
	injuries_indirect 	smallint,
	deaths_direct 		integer,
	deaths_indirect 	integer,
	damage_property 	integer,
	damage_crops 		integer,
	begin_lat 			numeric,
	begin_lon 			numeric,
	end_lat 			numeric,
	end_lon 			numeric,
	road_closures 		boolean,
	power_outages 		boolean,
	total_severity 		numeric
)

SELECT end_range
FROM storms
WHERE end_range > 5
ORDER BY end_range DESC

DROP TABLE storms

-- creating the calendar table here

CREATE TABLE dim_date (
    date_key      INTEGER PRIMARY KEY,        -- YYYYMMDD
    full_date     DATE NOT NULL UNIQUE,
    year          SMALLINT NOT NULL,
	month_num     SMALLINT NOT NULL,
    month_name    VARCHAR(9) NOT NULL,
    day			  SMALLINT NOT NULL
);

DROP TABLE dim_date


-- here i'm inserting data into the date table based using the GENERATE SERIES function and the range of dates found in my storms table.
SELECT *
FROM storms

INSERT INTO dim_date (date_key, full_date, year, month_num, month_name, day)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,
    d,
    EXTRACT(YEAR FROM d)::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    TO_CHAR(d, 'FMMonth'),
    EXTRACT(DAY FROM d)::SMALLINT
FROM (
    SELECT generate_series(
        (SELECT MIN(begin_date) FROM storms),
        (SELECT MAX(end_date)   FROM storms),
        INTERVAL '1 day'
    )::DATE AS d
) days
ON CONFLICT (date_key) DO NOTHING;

SELECT *
FROM dim_date


-- making event type dimensions table

CREATE TABLE dim_event_type(
	event_type_key SERIAL PRIMARY KEY
	,event_type_name VARCHAR(50) NOT NULL UNIQUE
);

--inserting data from storms table
INSERT INTO dim_event_type (event_type_name)
SELECT DISTINCT event_type
FROM storms
ON CONFLICT (event_type_name) DO NOTHING;

--* checking
SELECT * FROM dim_event_type



-- creating location dimension
CREATE TABLE dim_location(
	dim_loc_key SERIAL PRIMARY KEY
	,county_name VARCHAR(50)
	,county_timezone VARCHAR (10),
	UNIQUE (county_name,county_timezone)
)

DROP TABLE dim_location

--inserting data
INSERT INTO dim_location (county_name,county_timezone)
SELECT DISTINCT
	cz_name
	,cz_timezone
FROM storms
ON CONFLICT(county_name, county_timezone) DO NOTHING;

--* sanity check
SELECT * FROM dim_location



-- creating the center fact table
CREATE TABLE storm_facts(
	event_id 			BIGINT PRIMARY KEY
	,event_type_key		INTEGER NOT NULL REFERENCES dim_event_type(event_type_key)
	,location_key		INTEGER NOT NULL REFERENCES dim_location(dim_loc_key)
	,begin_date_key		INTEGER NOT NULL REFERENCES dim_date(date_key)
	,end_date_key		INTEGER NOT NULL REFERENCES dim_date(date_key)
	,episode_id 		INTEGER
	,begin_time 		TIME NOT NULL
	,end_time 			TIME NOT NULL
	,begin_lat			NUMERIC(8,5) 
	,begin_lon			NUMERIC(8,5)
	,end_lat			NUMERIC(8,5)
	,end_lon			NUMERIC(8,5)
	,death_direct		INTEGER DEFAULT 0
	,deaths_indirect	INTEGER DEFAULT 0
	,injuries_direct	INTEGER DEFAULT 0
	,injuries_indirect	INTEGER DEFAULT 0
	,damage_property	INTEGER DEFAULT 0
	,damage_crops		INTEGER DEFAULT 0
	,road_closures		BOOLEAN DEFAULT FALSE
	,power_outages		BOOLEAN DEFAULT FALSE
	,damage_severity	NUMERIC(10,6) NOT NULL
);

CREATE INDEX idx_event_type ON storm_facts (event_type_key);
CREATE INDEX idx_location ON storm_facts	(location_key);
CREATE INDEX idx_begin_date ON storm_facts (begin_date_key);
CREATE INDEX idx_end_date ON storm_facts (end_date_key);

SELECT * FROM storm_facts

DROP TABLE storm_facts

-- now I have to insert a bunch of stuff into my fact table
INSERT INTO storm_facts (
    event_id, event_type_key, location_key, begin_date_key, end_date_key,
    episode_id, begin_time, end_time,
    begin_lat, begin_lon, end_lat, end_lon,
    injuries_direct, injuries_indirect, death_direct, deaths_indirect,
    damage_property, damage_crops, road_closures, power_outages,
    damage_severity
)
SELECT
	s.event_id
	,et.event_type_key
	,loc.dim_loc_key
	,TO_CHAR(s.begin_date, 'YYYYMMDD')::INTEGER
	,TO_CHAR(s.end_date, 'YYYYMMDD')::INTEGER
	,s.episode_id, s.begin_time, s.end_time
	,s.begin_lat,s.begin_lon, s.end_lat, s.end_lon
	,COALESCE(s.injuries_direct, 0), COALESCE(s.injuries_indirect, 0),
    COALESCE(s.deaths_direct, 0), COALESCE(s.deaths_indirect, 0),
    COALESCE(s.damage_property, 0), COALESCE(s.damage_crops, 0),
    COALESCE(s.road_closures, FALSE), COALESCE(s.power_outages, FALSE),
    s.total_severity
FROM storms s
JOIN dim_event_type et ON event_type_name = event_type
JOIN dim_location loc ON county_name = cz_name
ON CONFLICT (event_id) DO NOTHING;


SELECT dd.year, et.event_type_name, COUNT(*) AS event_count,
       SUM(f.damage_property + f.damage_crops) AS total_damage,
       AVG(f.damage_severity) AS avg_severity
FROM storm_facts f
JOIN dim_date dd ON dd.date_key = f.begin_date_key
JOIN dim_event_type et ON et.event_type_key = f.event_type_key
GROUP BY dd.year, et.event_type_name
ORDER BY total_damage DESC
LIMIT 10;

SELECT * FROM storm_facts

SELECT * FROM dim_event_type;

SELECT * FROM dim_location

SELECT * FROM storms

SELECT * FROM storm_facts

SELECT current_user

SE

ALTER USER postgres WITH PASSWORD 'postgres';