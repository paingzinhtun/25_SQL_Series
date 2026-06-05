import os
import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.getenv('DB_URL', 'postgresql://username:password@localhost:5432/pipeline_db')
engine = create_engine(DB_URL)

def generate_kpis():
    print("📊 Extracting KPIs from Analytics Layer...")
    
    try:
        # Instead of executing a script, we use Pandas to fetch data from the views and display it.
        # This simulates a BI tool pulling aggregates.
        
        print("\n--- Executive KPIs ---")
        df_exec = pd.read_sql("SELECT * FROM executive_kpis", engine)
        print(df_exec.to_string(index=False))

        print("\n--- Top 3 Regions by Revenue ---")
        df_region = pd.read_sql("SELECT * FROM regional_performance ORDER BY regional_revenue DESC LIMIT 3", engine)
        print(df_region.to_string(index=False))
        
        print("\n✅ KPI Generation Complete.")
        
    except Exception as e:
        print(f"❌ Failed to generate KPIs: {str(e)}")
        # We don't raise here if we just want to log that the DB isn't running in a dev environment

if __name__ == "__main__":
    generate_kpis()