import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.getenv('DB_URL', 'postgresql://username:password@localhost:5432/pipeline_db')
engine = create_engine(DB_URL)

def load_warehouse():
    print("🚀 Starting Warehouse Loading (Gold Layer)...")
    
    try:
        with engine.connect() as conn:
            print("⏳ Initializing Warehouse Schema...")
            with open('../warehouse_schema.sql', 'r') as file:
                conn.execute(text(file.read()))
                conn.commit()

            print("⏳ Loading Dimensions...")
            with open('../sql/dimension_loads.sql', 'r') as file:
                conn.execute(text(file.read()))
                conn.commit()
            
            print("⏳ Loading Facts...")
            with open('../sql/fact_loads.sql', 'r') as file:
                conn.execute(text(file.read()))
                conn.commit()
            
            print("⏳ Creating Analytics Views...")
            with open('../analytics_views.sql', 'r') as file:
                conn.execute(text(file.read()))
                conn.commit()
                
            print("✅ Warehouse Loading Complete: Star schema is live.")
    
    except Exception as e:
        print(f"❌ Pipeline Failed at Warehouse Load: {str(e)}")
        raise

if __name__ == "__main__":
    load_warehouse()