import time
from ingest_data import run_ingestion
from transform_data import run_transformations
from load_warehouse import load_warehouse
from generate_kpis import generate_kpis
from pipeline_monitoring import check_data_quality, log_pipeline_status

def main():
    print("==================================================")
    print("🚀 INITIALIZING END-TO-END BATCH DATA PIPELINE 🚀")
    print("==================================================")
    
    start_time = time.time()
    status = "SUCCESS"
    
    try:
        # Step 1: Extract (Simulated API/CSV loads to Bronze)
        run_ingestion()
        print("-" * 50)
        
        # Step 2: Transform (Clean data to Silver)
        run_transformations()
        print("-" * 50)
        
        # Step 3: Load Warehouse (Move to Gold / Star Schema)
        load_warehouse()
        print("-" * 50)
        
        # Step 4: Quality Checks (Validation)
        check_data_quality()
        print("-" * 50)
        
        # Step 5: Deliver Value (BI / Dashboards)
        generate_kpis()
        print("-" * 50)
        
    except Exception as e:
        print(f"\n❌ PIPELINE ABORTED: {str(e)}")
        status = "FAILED"
        
    finally:
        end_time = time.time()
        log_pipeline_status(status, end_time - start_time)
        print("==================================================")

if __name__ == "__main__":
    main()