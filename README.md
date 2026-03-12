# ✈️ US Flight Performance Data Pipeline — Snowflake

A end-to-end data pipeline built in Snowflake using the Bureau of Transportation 
Statistics (BTS) On-Time Performance dataset. This project demonstrates a full ELT 
workflow from raw file ingestion through to a dimensional model and presentation layer.

---

## 📦 Data Source

**Bureau of Transportation Statistics — On-Time Performance Data**  
- Source: [transtats.bts.gov](https://www.transtats.bts.gov)
- Dataset: Reporting Carrier On-Time Performance (1987–present)
- Coverage: January 2025, all US domestic carriers
- Rows: 539,747 flights across 14 carriers and 329 airports

---

## 🏗️ Architecture

The pipeline follows a classic ELT pattern:
```
BTS Flat File (.csv)
        ↓
  Snowflake Stage
        ↓
   RAW_FLIGHTS          ← All 110 columns loaded as VARCHAR
        ↓
  Dimension Tables      ← Typed, clean, deduplicated
        ↓
   FACT_FLIGHTS         ← Typed, keyed, joined to dimensions
        ↓
   VW_FLIGHTS           ← Flat view for BI/analysis
```

**Why load as VARCHAR first?**  
The BTS dataset contains many nullable numeric fields (e.g. departure time for 
cancelled flights). Loading everything as VARCHAR into the raw staging table avoids 
type casting errors at ingestion time. Type casting and business logic is applied 
downstream when populating the fact table using Snowflake's TRY_TO_NUMBER() and 
TRY_TO_DATE() functions, which return NULL rather than erroring on empty values.

---

## 📐 Schema

### Dimension Tables

| Table | Description |
|-------|-------------|
| `DIM_DATE` | One row per flight date with derived columns (day name, month name, is_weekend etc) |
| `DIM_AIRLINE` | 14 US carriers with IATA codes and full names |
| `DIM_AIRPORT` | 329 US airports with city, state and WAC region |
| `DIM_CANCELLATION` | 4 BTS cancellation reason codes (A/B/C/D) |

### Fact Table

`FACT_FLIGHTS` — one row per flight with:
- MD5 surrogate primary key derived from date + carrier + flight number + origin + dest
- Foreign keys to all four dimension tables
- Departure and arrival performance metrics
- Delay breakdown by cause (carrier, weather, NAS, security, late aircraft)

### View

`VW_FLIGHTS` — denormalised view joining all dimensions to the fact table, 
presenting human-readable names (airline name, airport code, city) without 
requiring knowledge of the underlying schema.

---

## 🔑 Key Design Decisions

**MD5 Primary Key**  
Rather than using an autoincrement surrogate key, `FACT_FLIGHTS` uses an MD5 hash 
of the natural flight identifiers (date, carrier, flight number, origin, destination). 
This makes the pipeline idempotent — reloading the same source file will not create 
duplicate rows, as the key will be identical for the same flight.

**Star Schema**  
The dimensional model separates descriptive attributes (airline name, airport city, 
cancellation reason) from measurable facts (delays, elapsed time, distance). This 
follows Kimball dimensional modelling principles and makes the data easily queryable 
by BI tools.

**LEFT JOINs on fact table insert**  
All joins from RAW_FLIGHTS to dimension tables use LEFT JOINs to ensure cancelled 
flights with null departure/arrival data are not dropped during the load.

---

## 📊 Sample Findings (January 2025)

| Metric | Value |
|--------|-------|
| Total flights | 539,747 |
| Cancelled flights | 16,312 (3.0%) |
| Weather cancellations | 14,327 (87.8% of cancellations) |
| Carrier cancellations | 1,635 (10.0% of cancellations) |
| NAS cancellations | 342 (2.1% of cancellations) |
| Security cancellations | 8 (0.05% of cancellations) |
| Unique airports | 329 |
| Carriers | 14 |

*January is historically the highest cancellation month for US domestic flights 
due to winter weather — the data reflects this with weather accounting for 
nearly 88% of all cancellations.*

---

## 🚀 How to Run

### Prerequisites
- Snowflake account (free trial sufficient)
- BTS On-Time Performance CSV downloaded from transtats.bts.gov
- Snowflake internal stage created and CSV uploaded

### Execution Order

Run scripts in the following order:
```
1. setup/01_create_database.sql
2. setup/02_create_file_format.sql
3. setup/03_create_stage.sql
4. setup/04_create_raw_flights.sql
5. setup/05_load_raw_flights.sql
6. dimensions/01_dim_cancellation.sql
7. dimensions/02_dim_airline.sql
8. dimensions/03_dim_airport.sql
9. dimensions/04_dim_date.sql
10. facts/01_fact_flights.sql
11. views/01_vw_flights.sql
```

---

## 🛠️ Tools Used

- **Snowflake** — cloud data warehouse
- **Snowsight** — Snowflake web UI for stage management
- **VSCode** — with Snowflake extension for SQL development
- **Git / GitHub** — version control

---

## 📁 Repository Structure
```
flights-project/
├── setup/
│   ├── 01_create_database.sql
│   ├── 02_create_file_format.sql
│   ├── 03_create_stage.sql
│   ├── 04_create_raw_flights.sql
│   └── 05_load_raw_flights.sql
├── dimensions/
│   ├── 01_dim_cancellation.sql
│   ├── 02_dim_airline.sql
│   ├── 03_dim_airport.sql
│   └── 04_dim_date.sql
├── facts/
│   └── 01_fact_flights.sql
├── views/
│   └── 01_vw_flights.sql
└── README.md
```