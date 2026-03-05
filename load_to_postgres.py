import pandas as pd
from sqlalchemy import create_engine
import os

# === CHANGE THESE TWO LINES ONLY ===
DB_PASSWORD = 'db password'          # ← Replace with your actual PostgreSQL password
CSV_FOLDER = r'D:\ecommerce-project'                  # ← This is already correct for you

# Database connection string
engine = create_engine(f'postgresql+psycopg2://postgres:{DB_PASSWORD}@localhost:5432/ecommerce_db')

# List of CSV files and the table names we want to create in PostgreSQL
files_to_tables = {
    'olist_customers_dataset.csv': 'customers',
    'olist_geolocation_dataset.csv': 'geolocation',
    'olist_order_items_dataset.csv': 'order_items',
    'olist_order_payments_dataset.csv': 'order_payments',
    'olist_order_reviews_dataset.csv': 'order_reviews',
    'olist_orders_dataset.csv': 'orders',
    'olist_products_dataset.csv': 'products',
    'olist_sellers_dataset.csv': 'sellers',
    'product_category_name_translation.csv': 'product_category_translation'
}

print("Starting to load CSV files into PostgreSQL...\n")

for csv_file, table_name in files_to_tables.items():
    full_path = os.path.join(CSV_FOLDER, csv_file)
    
    if not os.path.exists(full_path):
        print(f"WARNING: File not found → {csv_file} (skipping)")
        continue
    
    print(f"Loading {csv_file} into table '{table_name}'...")
    try:
        df = pd.read_csv(full_path)
        df.to_sql(table_name, engine, if_exists='replace', index=False)
        print(f"   SUCCESS: Loaded {len(df)} rows into {table_name}")
    except Exception as e:
        print(f"   ERROR: Failed to load {csv_file}")
        print(f"   Error message: {e}\n")

print("\nAll done! Check pgAdmin or run queries to verify.")