CREATE OR REPLACE VIEW vw_flights AS
SELECT
    -- DATE
    dd.full_date                        AS flight_date,
    dd.year,
    dd.month_name,
    dd.day_name,
    dd.is_weekend,

    -- AIRLINE
    da.airline_name,
    da.reporting_airline                AS carrier_code,

    -- ROUTE
    f.flight_number,
    f.tail_number,
    dapo.airport_code                   AS origin,
    dapo.city_name                      AS origin_city,
    dapo.state                          AS origin_state,
    dapd.airport_code                   AS dest,
    dapd.city_name                      AS dest_city,
    dapd.state                          AS dest_state,

    -- DEPARTURE
    f.scheduled_dep_time,
    f.actual_dep_time,
    f.dep_delay,
    f.taxi_out,

    -- ARRIVAL
    f.scheduled_arr_time,
    f.actual_arr_time,
    f.arr_delay,
    f.taxi_in,

    -- STATUS
    f.cancelled,
    dc.cancellation_reason,
    f.diverted,

    -- PERFORMANCE
    f.scheduled_elapsed_time,
    f.actual_elapsed_time,
    f.air_time,
    f.distance,

    -- DELAY BREAKDOWN
    f.carrier_delay,
    f.weather_delay,
    f.nas_delay,
    f.security_delay,
    f.late_aircraft_delay

FROM fact_flights f
JOIN dim_date dd          ON f.date_key = dd.date_key
JOIN dim_airline da       ON f.airline_key = da.airline_key
JOIN dim_airport dapo     ON f.origin_airport_key = dapo.airport_key
JOIN dim_airport dapd     ON f.dest_airport_key = dapd.airport_key
LEFT JOIN dim_cancellation dc ON f.cancellation_key = dc.cancellation_key;