CREATE OR REPLACE TABLE dim_cancellation (
    cancellation_key                NUMBER AUTOINCREMENT PRIMARY KEY,
    cancellation_code               VARCHAR(1),
    cancellation_reason             VARCHAR(50)
);

INSERT INTO dim_cancellation (cancellation_code, cancellation_reason)
VALUES
    ('A', 'Carrier'),
    ('B', 'Weather'),
    ('C', 'National Air System'),
    ('D', 'Security');