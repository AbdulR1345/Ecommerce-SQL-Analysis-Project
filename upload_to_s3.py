import boto3
import os

# === EDIT THESE THREE LINES ===
AWS_ACCESS_KEY = 'AWS_ACCESS_KEY_ID'          # ← Paste your Access key ID
AWS_SECRET_KEY = 'AWS_SECRET_ACCESS_KEY'      # ← Paste your Secret access key
BUCKET_NAME = 'abdul-ecommerce-analytics-2026'               # ← e.g., 'abdul-ecommerce-analytics-2026'

# Folder where your CSVs are
CSV_FOLDER = r'D:\ecommerce-project'

# Create S3 client
s3 = boto3.client(
    's3',
    aws_access_key_id=AWS_ACCESS_KEY,
    aws_secret_access_key=AWS_SECRET_KEY
)

print("Starting upload to S3...\n")

# Find all .csv files in the folder
for file_name in os.listdir(CSV_FOLDER):
    if file_name.lower().endswith('.csv'):
        file_path = os.path.join(CSV_FOLDER, file_name)
        try:
            s3.upload_file(file_path, BUCKET_NAME, file_name)
            print(f"SUCCESS: Uploaded {file_name}")
        except Exception as e:
            print(f"ERROR uploading {file_name}: {e}")

print("\nUpload complete! Check your S3 bucket in AWS Console.")