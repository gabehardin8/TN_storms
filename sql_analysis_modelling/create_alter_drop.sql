-- Table: public.fatalities

-- DROP TABLE IF EXISTS public.fatalities;

CREATE TABLE IF NOT EXISTS public.fatalities
(
    fat_date date,
    fat_id integer,
    event_id integer,
    fat_type character varying(5) COLLATE pg_catalog."default",
    fat_age numeric(8,4),
    fat_sex character varying(5) COLLATE pg_catalog."default",
    fat_loc character varying(50) COLLATE pg_catalog."default"
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.fatalities
    OWNER to postgres;

ALTER TABLE fatalities
ALTER COLUMN fat_age TYPE NUMERIC(3);

DROP TABLE FATALITIES

SELECT *
FROM fatalities

DROP TABLE storms7

CREATE TABLE locations (
	"date" date,
	episode_id integer,
	event_id integer,
	loc_index integer,
	range numeric(6,2),
	azimuth character varying(5),
	loc character varying(50),
	lat numeric(5,2),
	long numeric(5,2),
	lat2 numeric(8),
	long2 numeric(8)
)

DROP TABLE locations

CREATE TABLE locations (
	"date" character varying(6),
	episode_id integer,
	event_id integer,
	loc_index integer,
	range numeric(6,2),
	azimuth character varying(5),
	loc character varying(50),
	lat numeric(5,2),
	long numeric(5,2)
)

SELECT *
FROM locations

DROP TABLE locations

CREATE TABLE locations (
	"date" character varying(6),
	episode_id integer,
	event_id integer,
	loc_index integer,
	range numeric(6,2),
	azimuth character varying(5),
	loc character varying(50),
	lat numeric(7,4),
	long numeric(7,4)
)

SELECT *
FROM locations

CREATE TABLE storms (
begin_date_time date,
end_date_time date,
episode_id integer,
              event_id integer,
            event_type character varying(36),
               cz_type character varying(5),
               cz_fips integer,
               cz_name character varying(36),
                  wfo character varying(5),
           cz_timezone character varying (10),
      injuries_direct integer,
    injuries_indirect integer,
        deaths_direct integer,
      deaths_indirect integer,
      damage_property integer,
         damage_crops integer,
               source character varying(50),
            magnitude numeric,
       magnitude_type character varying(5),
          flood_cause character varying(36),
          tor_f_scale character varying(5),
           tor_length numeric,
            tor_width integer,
        tor_other_wfo character varying(5),
    tor_other_cz_fips integer,
    tor_other_cz_name character varying(24),
          begin_range numeric,
        begin_azimuth character varying(5),
       begin_location character varying(50),
            end_range numeric,
          end_azimuth character varying(5),
         end_location character varying(50),
begin_lat numeric,
begin_lon numeric,
end_lat numeric,
end_lon numeric,
episode_narrative character varying,
event_narrative character varying
)

DROP TABLE storms

CREATE TABLE storms (
begin_date_time date,
end_date_time date,
episode_id integer,
              event_id integer,
            event_type character varying(36),
               cz_type character varying(5),
               cz_fips integer,
               cz_name character varying(36),
                  wfo character varying(5),
           cz_timezone character varying (10),
      injuries_direct integer,
    injuries_indirect integer,
        deaths_direct integer,
      deaths_indirect integer,
      damage_property integer,
         damage_crops integer,
               source character varying(50),
            magnitude numeric,
       magnitude_type character varying(5),
          flood_cause character varying(36),
          tor_f_scale character varying(5),
           tor_length numeric,
            tor_width numeric,
        tor_other_wfo character varying(5),
    tor_other_cz_fips integer,
    tor_other_cz_name character varying(24),
          begin_range numeric,
        begin_azimuth character varying(5),
       begin_location character varying(50),
            end_range numeric,
          end_azimuth character varying(5),
         end_location character varying(50),
begin_lat numeric,
begin_lon numeric,
end_lat numeric,
end_lon numeric,
episode_narrative character varying,
event_narrative character varying
)

DROP TABLE storms

CREATE TABLE storms (
begin_date_time date,
end_date_time date,
episode_id integer,
              event_id integer,
            event_type character varying(36),
               cz_type character varying(5),
               cz_fips integer,
               cz_name character varying(36),
                  wfo character varying(5),
           cz_timezone character varying (10),
      injuries_direct integer,
    injuries_indirect integer,
        deaths_direct integer,
      deaths_indirect integer,
      damage_property integer,
         damage_crops integer,
               source character varying(50),
            magnitude numeric,
       magnitude_type character varying(5),
          flood_cause character varying(36),
          tor_f_scale character varying(5),
           tor_length numeric,
            tor_width numeric,
        tor_other_wfo character varying(5),
    tor_other_cz_fips numeric,
    tor_other_cz_name character varying(24),
          begin_range numeric,
        begin_azimuth character varying(5),
       begin_location character varying(50),
            end_range numeric,
          end_azimuth character varying(5),
         end_location character varying(50),
begin_lat numeric,
begin_lon numeric,
end_lat numeric,
end_lon numeric,
episode_narrative character varying,
event_narrative character varying
)

DROP TABLE storms

CREATE TABLE storms (
	begin_date date,
	begin_time time,
	end_date date,
	end_time time,
	episode_id integer,
	event_id integer,
	event_type character varying(36),
	cz_type character varying(5),
	cz_fips integer,
	cz_name character varying(36),
	wfo character varying(5),
	cz_timezone character varying (10),
	injuries_direct integer,
	injuries_indirect integer,
	deaths_direct integer,
	deaths_indirect integer,
	damage_property integer,
	damage_crops integer,
	source character varying(50),
	magnitude numeric,
	magnitude_type character varying(5),
	flood_cause character varying(36),
	tor_f_scale character varying(5),
	tor_length numeric,
	tor_width numeric,
	tor_other_wfo character varying(5),
	tor_other_cz_fips numeric,
	tor_other_cz_name character varying(24),
	begin_range numeric,
	begin_azimuth character varying(5),
	begin_location character varying(50),
	end_range numeric,
	end_azimuth character varying(5),
	end_location character varying(50),
	begin_lat numeric,
	begin_lon numeric,
	end_lat numeric,
	end_lon numeric,
	episode_narrative character varying,
	event_narrative character varying
)

SELECT *
FROM storms
WHERE injuries_direct > 10
ORDER BY injuries_direct DESC

SELECT *
FROM storms