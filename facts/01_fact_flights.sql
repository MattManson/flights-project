CREATE OR REPLACE TABLE fact_flights (
    flight_key                      VARCHAR(32) PRIMARY KEY,
    date_key                        NUMBER,
    airline_key                     NUMBER,
    origin_airport_key              NUMBER,
    dest_airport_key                NUMBER,
    cancellation_key                NUMBER,
    flight_number                   VARCHAR(10),
    tail_number                     VARCHAR(10),
    scheduled_dep_time              NUMBER,
    actual_dep_time                 NUMBER,
    dep_delay                       FLOAT,
    dep_delay_minutes               FLOAT,
    dep_del15                       FLOAT,
    taxi_out                        FLOAT,
    wheels_off                      NUMBER,
    wheels_on                       NUMBER,
    taxi_in                         FLOAT,
    scheduled_arr_time              NUMBER,
    actual_arr_time                 NUMBER,
    arr_delay                       FLOAT,
    arr_delay_minutes               FLOAT,
    arr_del15                       FLOAT,
    cancelled                       NUMBER,
    diverted                        NUMBER,
    scheduled_elapsed_time          FLOAT,
    actual_elapsed_time             FLOAT,
    air_time                        FLOAT,
    distance                        FLOAT,
    distance_group                  NUMBER,
    carrier_delay                   FLOAT,
    weather_delay                   FLOAT,
    nas_delay                       FLOAT,
    security_delay                  FLOAT,
    late_aircraft_delay             FLOAT
);

INSERT INTO fact_flights
SELECT
    -- MD5 primary key
    MD5(CONCAT_WS('|',
        r.flightdate,
        r.reporting_airline,
        r.flight_number_reporting_airline,
        r.origin,
        r.dest
    ))                                          AS flight_key,

    -- FOREIGN KEYS
    TO_NUMBER(TO_CHAR(TRY_TO_DATE(r.flightdate), 'YYYYMMDD'))
                                                AS date_key,
    da.airline_key                              AS airline_key,
    dapo.airport_key                            AS origin_airport_key,
    dapd.airport_key                            AS dest_airport_key,
    COALESCE(dc.cancellation_key, NULL)         AS cancellation_key,

    -- FLIGHT DETAILS
    r.flight_number_reporting_airline           AS flight_number,
    r.tail_number                               AS tail_number,

    -- DEPARTURE
    TRY_TO_NUMBER(r.crsdeptime)                 AS scheduled_dep_time,
    TRY_TO_NUMBER(r.deptime)                    AS actual_dep_time,
    TRY_TO_DOUBLE(r.depdelay)                   AS dep_delay,
    TRY_TO_DOUBLE(r.depdelayminutes)            AS dep_delay_minutes,
    TRY_TO_DOUBLE(r.depdel15)                   AS dep_del15,
    TRY_TO_DOUBLE(r.taxiout)                    AS taxi_out,
    TRY_TO_NUMBER(r.wheelsoff)                  AS wheels_off,

    -- ARRIVAL
    TRY_TO_NUMBER(r.wheelson)                   AS wheels_on,
    TRY_TO_DOUBLE(r.taxiin)                     AS taxi_in,
    TRY_TO_NUMBER(r.crsarrtime)                 AS scheduled_arr_time,
    TRY_TO_NUMBER(r.arrtime)                    AS actual_arr_time,
    TRY_TO_DOUBLE(r.arrdelay)                   AS arr_delay,
    TRY_TO_DOUBLE(r.arrdelayminutes)            AS arr_delay_minutes,
    TRY_TO_DOUBLE(r.arrdel15)                   AS arr_del15,

    -- FLIGHT STATUS
    TRY_TO_NUMBER(r.cancelled)                  AS cancelled,
    TRY_TO_NUMBER(r.diverted)                   AS diverted,

    -- ELAPSED TIME & DISTANCE
    TRY_TO_DOUBLE(r.crselapsedtime)             AS scheduled_elapsed_time,
    TRY_TO_DOUBLE(r.actualelapsedtime)          AS actual_elapsed_time,
    TRY_TO_DOUBLE(r.airtime)                    AS air_time,
    TRY_TO_DOUBLE(r.distance)                   AS distance,
    TRY_TO_NUMBER(r.distancegroup)              AS distance_group,

    -- DELAY BREAKDOWN
    TRY_TO_DOUBLE(r.carrierdelay)               AS carrier_delay,
    TRY_TO_DOUBLE(r.weatherdelay)               AS weather_delay,
    TRY_TO_DOUBLE(r.nasdelay)                   AS nas_delay,
    TRY_TO_DOUBLE(r.securitydelay)              AS security_delay,
    TRY_TO_DOUBLE(r.lateaircraftdelay)          AS late_aircraft_delay

FROM raw_flights r

-- JOIN TO DIMENSIONS
LEFT JOIN dim_airline da
    ON r.reporting_airline = da.reporting_airline

LEFT JOIN dim_airport dapo
    ON r.origin = dapo.airport_code

LEFT JOIN dim_airport dapd
    ON r.dest = dapd.airport_code

LEFT JOIN dim_cancellation dc
    ON r.cancellationcode = dc.cancellation_code;