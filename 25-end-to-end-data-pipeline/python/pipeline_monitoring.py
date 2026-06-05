import os
import time
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.getenv('DB_URL', 'postgresql://username:password@localhost:5432/pipeline_db')
engine = create_engine(DB_URL)

def check_data_quality():
    print("🔍 Starting Data Quality Validation...")
    
    try:
        with engine.connect() as conn:
            # We run the quality checks. In a real pipeline (e.g., Great Expectations), 
            # if rows return here, we alert Slack/Teams.
            result = conn.execute(text("SELECT customer_id, COUNT(*) FROM stg_customers GROUP BY customer_id HAVING COUNT(*) > 1"))
            dupes = result.fetchall()
            
            if len(dupes) > 0:
                print(f"⚠️ WARNING: Found {len(dupes)} duplicate customers in staging!")
            else:
                print("✅ Quality Check Passed: No staging duplicates.")
                
            # Verify orphaned facts
            result_orphans = conn.execute(text("SELECT * FROM fact_sales WHERE customer_sk IS NULL"))
            orphans = result_orphans.fetchall()
            if len(orphans) > 0:
                 print(f"⚠️ CRITICAL: Found {len(orphans)} orphaned facts missing dimension mappings!")
            else:
                 print("✅ Quality Check Passed: Star Schema integrity validated.")
                 
    except Exception as e:
        print(f"❌ Monitoring Failed: {str(e)}")

def log_pipeline_status(status, duration):
    # Simulates writing to a monitoring database like Airflow's metadata DB or Datadog
    print(f"\n📈 PIPELINE RUN LOG:")
    print(f"   Status: {status}")
    print(f"   Duration: {duration:.2f} seconds")
    print(f"   Timestamp: {time.strftime('%Y-%m-%d %H:%M:%S')}")

if __name__ == "__main__":
    start = time.time()
    check_data_quality()
    end = time.time()
    log_pipeline_status("SUCCESS", end - start)