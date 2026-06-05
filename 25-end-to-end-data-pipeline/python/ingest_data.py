import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

# Simulate connection. In real pipelines, these come from environment variables or secrets managers.
DB_URL = os.getenv('DB_URL', 'postgresql://username:password@localhost:5432/pipeline_db')
engine = create_engine(DB_URL)

def run_ingestion():
    print("🚀 Starting Data Ingestion Layer...")
    
    try:
        with engine.connect() as conn:
            print("⏳ Reading schema and generating raw data via SQL script...")
            # In a true Python pipeline, we would do:
            # df = pd.read_csv('data/raw_customers.csv')
            # df.to_sql('raw_customers', engine, if_exists='replace', index=False)
            
            # Since this is a self-contained simulation, we execute the generation scripts directly.
            with open('../schema.sql', 'r') as file:
                conn.execute(text(file.read()))
                conn.commit()
            
            with open('../insert_raw_data.sql', 'r') as file:
                conn.execute(text(file.read()))
                conn.commit()
            
            print("✅ Ingestion Layer Complete: Raw data loaded successfully.")
    
    except Exception as e:
        print(f"❌ Pipeline Failed at Ingestion Layer: {str(e)}")
        raise

if __name__ == "__main__":
    run_ingestion()