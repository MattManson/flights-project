CREATE OR REPLACE TABLE dim_date (
    date_key                        NUMBER PRIMARY KEY,
    full_date                       DATE,
    year                            NUMBER,
    quarter                         NUMBER,
    quarter_name                    VARCHAR(10),
    month                           NUMBER,
    month_name                      VARCHAR(20),
    day_of_month                    NUMBER,
    day_of_week                     NUMBER,
    day_name                        VARCHAR(20),
    is_weekend                      BOOLEAN,
    is_weekday                      BOOLEAN,
    week_of_year                    NUMBER,
    day_of_year                     NUMBER
);

INSERT INTO dim_date (
    date_key,
    full_date,
    year,
    quarter,
    quarter_name,
    month,
    month_name,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend,
    is_weekday,
    week_of_year,
    day_of_year
)
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(TRY_TO_DATE(flightdate), 'YYYYMMDD'))     AS date_key,
    TRY_TO_DATE(flightdate)                                      AS full_date,
    YEAR(TRY_TO_DATE(flightdate))                                AS year,
    QUARTER(TRY_TO_DATE(flightdate))                             AS quarter,
    CONCAT('Q', QUARTER(TRY_TO_DATE(flightdate)))                AS quarter_name,
    MONTH(TRY_TO_DATE(flightdate))                               AS month,
    MONTHNAME(TRY_TO_DATE(flightdate))                           AS month_name,
    DAY(TRY_TO_DATE(flightdate))                                 AS day_of_month,
    DAYOFWEEK(TRY_TO_DATE(flightdate))                           AS day_of_week,
    DAYNAME(TRY_TO_DATE(flightdate))                             AS day_name,
    CASE WHEN DAYOFWEEK(TRY_TO_DATE(flightdate)) IN (1, 7) 
         THEN TRUE ELSE FALSE END                                AS is_weekend,
    CASE WHEN DAYOFWEEK(TRY_TO_DATE(flightdate)) NOT IN (1, 7) 
         THEN TRUE ELSE FALSE END                                AS is_weekday,
    WEEKOFYEAR(TRY_TO_DATE(flightdate))                          AS week_of_year,
    DAYOFYEAR(TRY_TO_DATE(flightdate))                           AS day_of_year
FROM raw_flights
WHERE flightdate IS NOT NULL
ORDER BY full_date;