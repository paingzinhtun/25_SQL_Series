# Day 25 — End-to-End Data Pipeline (SQL + Python + Cloud Simulation)

## Project Overview
This is the Capstone Project for the "25 Days of SQL" series. It simulates a complete, end-to-end Data Engineering pipeline using PostgreSQL and Python. It shifts the focus from writing individual SQL queries to designing an automated, reliable system that moves data from raw operational sources into a clean, highly optimized Data Warehouse for BI reporting.

## Business Problem
A retail business is generating massive amounts of data from its e-commerce website and physical stores. However, the data is messy, decentralized, and difficult to query. Leadership wants a reliable daily pipeline that provides trusted analytics, tracks KPIs, and alerts them if data quality drops.

## Pipeline Architecture
We simulate a **Medallion Architecture** (Bronze, Silver, Gold):
1. **Bronze (Raw / Source Systems):** Data is ingested exactly as it arrives. It is messy, contains duplicates, and uses incorrect data types.
2. **Silver (Staging Layer):** Data is cleaned, deduplicated, standardized, and cast to proper data types.
3. **Gold (Warehouse Layer):** Data is modeled into a Star Schema (Fact and Dimension tables) optimized for fast analytics.
4. **Analytics Layer:** SQL Views aggregate the Gold data into BI-ready KPI dashboards.

## Why Each Layer Matters
- **Why Pipelines Matter:** Manual data extraction is error-prone and unscalable. Pipelines automate the flow of truth.
- **Why Raw Data is Messy:** Humans make typos, APIs fail, and systems crash. Raw data is never perfect.
- **Why Staging Layers Matter:** They isolate the raw chaos. You clean data in staging so you never break downstream executive dashboards.
- **Why Warehouse Layers Matter:** Operational databases are built for row-by-row inserts. Data Warehouses (Star Schemas) are built for aggregations and analytics over millions of rows.
- **Why Monitoring Matters:** If a pipeline fails silently, executives make decisions on outdated data.
- **Why Analytics Layers Matter:** They pre-calculate complex metrics so BI tools (Tableau/Power BI) remain fast and consistent.

## ETL Workflow & Python Orchestration
In a real cloud environment, tools like Airflow or Dagster would run this workflow. In this project, Python simulates the orchestrator:
1. `ingest_data.py`: Extracts data and loads it into Bronze tables.
2. `transform_data.py`: Runs SQL to clean the data into Silver tables.
3. `load_warehouse.py`: Maps surrogate keys and loads the Gold Star Schema.
4. `generate_kpis.py`: Queries the final Analytics Views via Pandas.
5. `pipeline_monitoring.py`: Executes data quality checks.
6. `run_pipeline.py`: The master script that executes everything in sequence.

## Data Quality Checks
Automated SQL queries check for:
- Duplicate customers.
- Orphaned fact records (missing dimension keys).
- Negative revenue (indicative of broken ingestion logic).
- Missing dates or unstandardized categories.

## Concepts Practiced
### Data Engineering Concepts
- ETL/ELT pipeline design.
- Medallion architecture thinking.
- Surrogate key generation.
- Fact and Dimension modeling (Star Schema).
- Data cleaning and deduplication.
- Data quality validation.
- Pipeline orchestration.

### SQL Concepts
- `TRUNCATE` and `INSERT INTO`
- `ROW_NUMBER() OVER()` for deduplication
- `CASE WHEN` and `COALESCE` for standardization
- `LEFT JOIN` for identifying missing data
- Advanced Window Functions (`LAG`, rolling averages)

### Python Concepts
- Executing raw SQL via SQLAlchemy.
- Modular script design.
- Basic logging and error handling.
- Environment variables via `dotenv`.

## Files in This Project
- `architecture.md`: In-depth pipeline documentation.
- `schema.sql`: Bronze (Raw) and Silver (Staging) table definitions.
- `insert_raw_data.sql`: Scripts to generate hundreds of messy data rows.
- `warehouse_schema.sql`: Gold (Star Schema) table definitions.
- `sql/`: Folder containing all SQL logic for transformations, loading, and analytics.
- `python/`: Folder containing the Python orchestration scripts.
- `analytics_views.sql`: Dashboard-ready SQL views.
- `data_quality_checks.sql`: Automated validation scripts.
- `business_questions.md`: Mapping queries to business value.

## Key Lessons
Data Engineering is not just about writing queries; it is about building reliable systems. The value of data is entirely dependent on the pipeline that delivers it. If the pipeline is slow, the data is late. If the pipeline is fragile, the data is untrusted.

## How to Run This Project
1. Create a PostgreSQL database and update your connection string in a `.env` file or directly in the Python scripts.
2. Install Python dependencies: `pip install -r requirements.txt`
3. Execute the pipeline: `python python/run_pipeline.py`
4. Review the generated logs and run the queries in `sql/analytics_queries.sql` to explore the clean data!

## Future Improvements
To take this closer to an enterprise cloud environment, one could:
- Move from Postgres to a cloud warehouse like Snowflake or BigQuery.
- Replace Python scripts with Apache Airflow DAGs.
- Use dbt (data build tool) for the transformation layer.
- Connect a live BI tool (Metabase, Superset, Power BI) to the analytics views.

---

## LinkedIn Reflection Draft

Day 25/25 — SQL for Real Business Data Systems

Today I completed the final project of my SQL series:
An End-to-End Data Pipeline using SQL + Python.

This project helped me understand how real business data moves through a complete analytics pipeline.

I simulated:
- raw operational data
- staging layers
- data cleaning
- transformations
- warehouse loading
- analytics views
- KPI reporting
- pipeline monitoring
- data quality validation

For this project, I built:
- raw tables
- staging tables
- dimension tables
- fact tables
- analytics dashboards
- ETL SQL scripts
- Python pipeline scripts
- monitoring workflows

Then I wrote SQL queries to analyze:
- revenue
- profit
- customer performance
- product performance
- regional trends
- growth metrics
- executive KPIs
- business analytics

Data Engineering and SQL concepts I practiced:
- ETL pipelines
- staging layers
- dimensional modeling
- fact and dimension tables
- data cleaning
- data quality checks
- analytics engineering
- KPI systems
- orchestration thinking
- pipeline monitoring
- SQL transformations
- Python automation

My key lesson:
Data Engineering is not only about writing queries.

It is about building reliable systems that move raw business data into trusted analytics.

This 25-day SQL series helped me shift from:
“learning SQL syntax”
to
“thinking like a Data Engineer.”

This foundation is extremely important for analytics systems, Data Engineering, BI platforms, and future Data + AI solutions.

Feedback and suggestions are always welcome 🙏