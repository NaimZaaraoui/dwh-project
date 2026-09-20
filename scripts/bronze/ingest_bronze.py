# ==============================================================================
# Python Script: Laod Bronze Layer (Source -> Bronze)
# ===============================================================================
# Script Purpose:
#   This script loads data into the 'bronze' schema from external CSV files.
#   It performs the following actions:
#   - Truncate the bronze tables before loading data.
#   - Uses the psql '\copy' command to load data from CSV files to bronze tables.
# It handles authentication via local environment layer (.env) 
# Usage Example:
#   Terminal: python ingest_bronze.py
# =================================================================================


import subprocess
import time
import os
from dotenv import load_dotenv

# Read the key-value pairs from local .env file
load_dotenv()

# Target database parameters
DB_USER = os.getenv("DB_USER")
DB_NAME = os.getenv("DB_NAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Define the explicit data sources to track
INGESTION_JOBS = [
    {
        "table": "bronze.crm_cust_info",
        "file": "C:/Users/zaara/OneDrive/Desktop/SQL/dwh-project/datasets/source_crm/cust_info.csv"
    },
    {
        "table": "bronze.crm_prd_info",
        "file": "C:/Users/zaara/OneDrive/Desktop/SQL/dwh-project/datasets/source_crm/prd_info.csv"
    },
    {
        "table": "bronze.crm_sales_details",
        "file": "C:/Users/zaara/OneDrive/Desktop/SQL/dwh-project/datasets/source_crm/sales_details.csv"
    },
    {
        "table": "bronze.erp_cust_az12",
        "file": "C:/Users/zaara/OneDrive/Desktop/SQL/dwh-project/datasets/source_erp/cust_az12.csv"
    },
    {
        "table": "bronze.erp_loc_a101",
        "file": "C:/Users/zaara/OneDrive/Desktop/SQL/dwh-project/datasets/source_erp/loc_a101.csv"
    },
    {
        "table": "bronze.erp_px_cat_glv2",
        "file": "C:/Users/zaara/OneDrive/Desktop/SQL/dwh-project/datasets/source_erp/px_cat_g1v2.csv"
    }
]

def run_pipeline():
    pipeline_start = time.time()
    performance_metrics = []

     # 🔐 Setup a custom environment copy including the PG credentials
    # This prevents psql from prompting for a password on each step!
    env_context = os.environ.copy()
    env_context["PGPASSWORD"] = DB_PASSWORD
    
    print("========================================================")
    print("🏁 INITIALIZING BRONZE INGESTION WITH METRIC METADATA TRACKING")
    print("========================================================\n")
    
    for job in INGESTION_JOBS:
        table_name = job["table"]
        csv_path = job["file"]
        
        print(f"🧹 Truncating {table_name}...")
        # Step A: Truncate the table cleanly inside the loop
        subprocess.run(["psql", "-U", DB_USER, "-d", DB_NAME, "-c", f"TRUNCATE TABLE {table_name};"], 
                       check=True,
                       env = env_context)
        
        print(f"📥 Loading data into {table_name}...")
        # Step B: Construct the client-side inline psql copy query
        psql_copy_command = f"\\copy {table_name} FROM '{csv_path}' WITH (FORMAT CSV, HEADER true, DELIMITER ',', QUOTE '\"', NULL '');"
        
        # Start the stopwatch for this specific table
        job_start = time.time()
        
        try:
            subprocess.run([
                "psql", "-U", DB_USER, "-d", DB_NAME, "-c", psql_copy_command
            ], check=True, capture_output=True, text=True, env = env_context)
            
            job_duration = time.time() - job_start
            performance_metrics.append((table_name, f"{job_duration:.3f}s", "✅ SUCCESS"))
            print(f"⏱️ Finished {table_name} in {job_duration:.3f} seconds.\n")
            
        except subprocess.CalledProcessError as e:
            performance_metrics.append((table_name, "0.000s", "❌ FAILED"))
            print(f"❌ Error importing data into {table_name}: {e.stderr}\n")

    # Final summary display dashboard
    pipeline_duration = time.time() - pipeline_start
    print("========================================================")
    print("📊 BRONZE LAYER PIPELINE EXECUTION PERFORMANCE METRICS")
    print("========================================================")
    for table, duration, status in performance_metrics:
        print(f" -> {table.ljust(25)} | Duration: {duration.rjust(7)} | Status: {status}")
    print("--------------------------------------------------------")
    print(f"⏳ Total Pipeline Execution Time: {pipeline_duration:.3f} seconds")
    print("========================================================")

if __name__ == "__main__":
    run_pipeline()
