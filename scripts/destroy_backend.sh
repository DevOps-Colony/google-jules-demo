#!/bin/bash
set -e

# This script forcefully destroys the Terraform backend resources.

PROJECT_NAME="my-flask-app"
S3_BUCKET_NAME="${PROJECT_NAME}-terraform-state"
DYNAMODB_TABLE_NAME="${PROJECT_NAME}-terraform-lock"

echo "--- Destroying S3 Backend Bucket: $S3_BUCKET_NAME ---"
# The --force flag will remove all objects before deleting the bucket.
if aws s3api head-bucket --bucket "$S3_BUCKET_NAME" >/dev/null 2>&1; then
  aws s3 rb "s3://$S3_BUCKET_NAME" --force
  echo "S3 bucket deleted."
else
  echo "S3 bucket did not exist."
fi

echo "--- Destroying DynamoDB Lock Table: $DYNAMODB_TABLE_NAME ---"
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" >/dev/null 2>&1; then
  aws dynamodb delete-table --table-name "$DYNAMODB_TABLE_NAME"
  echo "DynamoDB table deleted."
else
  echo "DynamoDB table did not exist."
fi
