#!/bin/bash
set -e

# This script creates or imports the Terraform backend resources (S3 bucket, DynamoDB table).

PROJECT_NAME="my-flask-app"
S3_BUCKET_NAME="${PROJECT_NAME}-terraform-state"
DYNAMODB_TABLE_NAME="${PROJECT_NAME}-terraform-lock"

# The working directory is terraform/backend_setup, passed from the workflow.

echo "--- Initializing Terraform for backend setup ---"
terraform init

# Check for S3 bucket and import if it exists
if aws s3api head-bucket --bucket "$S3_BUCKET_NAME" >/dev/null 2>&1; then
  echo "S3 bucket '$S3_BUCKET_NAME' exists. Importing."
  terraform import -var="aws_region=${AWS_REGION}" -var="iam_role_name=${IAM_ROLE_NAME}" aws_s3_bucket.tfstate "$S3_BUCKET_NAME" || echo "S3 bucket already in state or import failed."
else
  echo "S3 bucket '$S3_BUCKET_NAME' does not exist."
fi

# Check for DynamoDB table and import if it exists
if aws dynamodb describe-table --table-name "$DYNAMODB_TABLE_NAME" >/dev/null 2>&1; then
  echo "DynamoDB table '$DYNAMODB_TABLE_NAME' exists. Importing."
  terraform import -var="aws_region=${AWS_REGION}" -var="iam_role_name=${IAM_ROLE_NAME}" aws_dynamodb_table.tflock "$DYNAMODB_TABLE_NAME" || echo "DynamoDB table already in state or import failed."
else
  echo "DynamoDB table '$DYNAMODB_TABLE_NAME' does not exist."
fi

echo "--- Applying backend Terraform configuration ---"
# Apply changes - will create resources if they don't exist, or do nothing if imported.
terraform apply -auto-approve \
  -var="aws_region=${AWS_REGION}" \
  -var="iam_role_name=${IAM_ROLE_NAME}"

echo "--- Capturing backend outputs ---"
S3_BUCKET=$(terraform output -raw s3_bucket_name)
DYNAMO_TABLE=$(terraform output -raw dynamodb_table_name)

# Set for subsequent steps in the same job
echo "s3_bucket_name=$S3_BUCKET" >> $GITHUB_OUTPUT
echo "dynamodb_table_name=$DYNAMO_TABLE" >> $GITHUB_OUTPUT

# Save to a file for artifact upload
echo "S3_BUCKET_NAME=$S3_BUCKET" > backend_outputs.env
echo "DYNAMODB_TABLE_NAME=$DYNAMO_TABLE" >> backend_outputs.env
