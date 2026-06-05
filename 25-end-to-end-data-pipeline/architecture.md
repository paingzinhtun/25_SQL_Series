# Data Pipeline Architecture

## Pipeline Overview
This project simulates a modern **Batch Data Pipeline** using SQL and Python. In the real world, this architecture represents an ELT (Extract, Load, Transform) or Medallion Architecture pattern (Bronze -> Silver -> Gold).

The goal of this pipeline is to take messy, decentralized raw data and systematically transform it into a centralized, trusted, analytics-ready Data Warehouse.

## Medallion Architecture Concepts (Simulated)
- **Bronze Layer (Raw):** Raw data ingested exactly as it arrives from source systems. It contains duplicates, nulls, and formatting errors.
- **Silver Layer (Staging):** Cleaned, filtered, and deduplicated data. Types are cast correctly, and business rules are applied.
- **Gold Layer (Warehouse/Analytics):** Highly structured Star Schema (Facts and Dimensions) optimized for BI tools and Executive Dashboards.

## Flow of Data
`CSV Files / Operational DBs` 
&rarr; **Ingestion Layer:** Python reads source data and loads it into raw tables.
&rarr; **Staging Layer:** SQL transformations clean the raw data and insert into staging tables.
&rarr; **Warehouse Layer:** Clean data is modeled into Dimensional and Fact tables.
&rarr; **Analytics Layer:** SQL Views aggregate data into BI-ready KPI dashboards.
&rarr; **Reporting:** Data quality checks and monitoring logs validate the pipeline.

## Why Each Layer Matters
- **Why Staging exists:** You should never transform data in transit. Load it raw first so you always have a backup of exactly what the source sent. Staging provides a sandbox to clean data without breaking downstream reports.
- **Why Transformations matter:** "Garbage in, garbage out." If customer names are inconsistent ("Yangon" vs "yangon  ") or orders have negative quantities, BI dashboards will report incorrect revenue.
- **Why Warehouse design matters:** Operational tables (like an app's backend) are designed for fast inserts. Data Warehouses are designed for fast *reads*. We use Star Schemas so BI tools can query massive datasets instantly.
- **Why Monitoring matters:** Pipelines break. APIs change, bad data arrives, or servers crash. Monitoring logs tell Data Engineers exactly *when* and *where* a failure occurred.