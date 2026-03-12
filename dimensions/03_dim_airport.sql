CREATE OR REPLACE TABLE dim_airport (
    airport_key                     NUMBER AUTOINCREMENT PRIMARY KEY,
    airport_code                    VARCHAR(10),
    city_name                       VARCHAR(100),
    state                           VARCHAR(10),
    state_fips                      NUMBER,
    state_name                      VARCHAR(100),
    wac                             NUMBER
);

INSERT INTO dim_airport (
    airport_code,
    city_name,
    state,
    state_fips,
    state_name,
    wac
)
SELECT DISTINCT
    origin,
    origincityname,
    originstate,
    TRY_TO_NUMBER(originstatefips),
    originstatename,
    TRY_TO_NUMBER(originwac)
FROM raw_flights
WHERE origin IS NOT NULL

UNION

SELECT DISTINCT
    dest,
    destcityname,
    deststate,
    TRY_TO_NUMBER(deststatefips),
    deststatename,
    TRY_TO_NUMBER(destwac)
FROM raw_flights
WHERE dest IS NOT NULL;