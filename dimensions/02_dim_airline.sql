-- AIRLINE DIMENSION
CREATE OR REPLACE TABLE dim_airline (
    airline_key                     NUMBER AUTOINCREMENT PRIMARY KEY,
    reporting_airline               VARCHAR(10),
    dot_id_reporting_airline        NUMBER,
    iata_code_reporting_airline     VARCHAR(10),
    airline_name                    VARCHAR(100)
);

-- Now insert with hardcoded names
INSERT INTO dim_airline (
    reporting_airline,
    dot_id_reporting_airline,
    iata_code_reporting_airline,
    airline_name
)
VALUES
    ('AA', 19805, 'AA', 'American Airlines Inc.'),
    ('AS', 19930, 'AS', 'Alaska Airlines Inc.'),
    ('B6', 20409, 'B6', 'JetBlue Airways'),
    ('DL', 19790, 'DL', 'Delta Air Lines Inc.'),
    ('F9', 20436, 'F9', 'Frontier Airlines Inc.'),
    ('G4', 20368, 'G4', 'Allegiant Air'),
    ('HA', 19690, 'HA', 'Hawaiian Airlines Inc.'),
    ('MQ', 20398, 'MQ', 'Envoy Air'),
    ('NK', 20416, 'NK', 'Spirit Airlines Inc.'),
    ('OH', 20397, 'OH', 'PSA Airlines Inc.'),
    ('OO', 20304, 'OO', 'SkyWest Airlines Inc.'),
    ('UA', 19977, 'UA', 'United Air Lines Inc.'),
    ('WN', 19393, 'WN', 'Southwest Airlines Co.'),
    ('YX', 20452, 'YX', 'Midwest Express Airlines Inc.');

