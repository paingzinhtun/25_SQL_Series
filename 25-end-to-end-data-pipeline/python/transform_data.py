import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DB_URL = os.getenv('DB_URL', 'postgresql://username:password@localhost:5432/pipeline_db')
engine = create_engine(DB_URL)

def run_transformations():
    print("🚀 Starting Transformation Layer (Silver)...")
    
    try:
        with engine.connect() as conn:
            print("⏳ Executing Staging Transformations...")
            with open('../sql/staging_transformations.sql', 'r') as file:
                sql_script = file.read()
                conn.execute(text(sql_script))
                conn.commit()
            
            print("✅ Transformation Layer Complete: Staging tables cleaned and deduplicated.")
    
    except Exception as e:
        print(f"❌ Pipeline Failed at Transformation Layer: {str(e)}")
        raise

if __name__ == "__main__":
    run_transformations()