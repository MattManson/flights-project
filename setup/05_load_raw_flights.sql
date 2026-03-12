COPY INTO raw_flights
FROM @FLIGHTS_STAGE/On_Time_Reporting_Carrier_On_Time_Performance_(1987_present)_2025_1.csv
FILE_FORMAT = (FORMAT_NAME = 'csv_format');