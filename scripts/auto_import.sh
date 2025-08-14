#!/bin/bash
set -e

# This script initializes Terraform for a specific environment and imports existing
# resources to prevent errors.

# These variables are expected to be passed from the GitHub workflow.
# E.g., ENVIRONMENT, BUCKET, KEY, REGION, DYNAMO_TABLE
if [[ -z "$ENVIRONMENT" || -z "$BUCKET" || -z "$KEY" || -z "$REGION" || -z "$DYNAMO_TABLE" ]]; then
  echo "Error: One or more required environment variables are not set."
  exit 1
fi

echo "--- Initializing Terraform for $ENVIRONMENT environment ---"
terraform init \
  -backend-config="bucket=$BUCKET" \
  -backend-config="key=$KEY" \
  -backend-config="region=$REGION" \
  -backend-config="dynamodb_table=$DYNAMO_TABLE"

echo "--- Checking for existing resources to import into $ENVIRONMENT ---"

# Extract names from tfvars file
EKS_CLUSTER_NAME=$(grep "cluster_name" "${ENVIRONMENT}.tfvars" | awk -F'=' '{print $2}' | tr -d ' "')
ECR_REPO_NAME=$(grep "ecr_repository_name" "${ENVIRONMENT}.tfvars" | awk -F'=' '{print $2}' | tr -d ' "')
DYNAMO_TABLE_NAME=$(grep "dynamodb_table_name" "${ENVIRONMENT}.tfvars" | awk -F'=' '{print $2}' | tr -d ' "')

# Check and import EKS Cluster
if aws eks describe-cluster --name "$EKS_CLUSTER_NAME" >/dev/null 2>&1; then
  echo "EKS cluster '$EKS_CLUSTER_NAME' exists."
  if ! (terraform state list 2>/dev/null || true) | grep -q 'module.eks.aws_eks_cluster.this'; then
    echo "Importing EKS cluster..."
    terraform import -var-file="${ENVIRONMENT}.tfvars" module.eks.aws_eks_cluster.this "$EKS_CLUSTER_NAME"
  else
    echo "EKS cluster already in state."
  fi
else
  echo "EKS cluster '$EKS_CLUSTER_NAME' does not exist. Skipping import."
fi

# Check and import ECR Repository
if aws ecr describe-repositories --repository-names "$ECR_REPO_NAME" >/dev/null 2>&1; then
  echo "ECR repository '$ECR_REPO_NAME' exists."
  if ! (terraform state list 2>/dev/null || true) | grep -q 'module.ecr.aws_ecr_repository.app'; then
    echo "Importing ECR repository..."
    terraform import -var-file="${ENVIRONMENT}.tfvars" module.ecr.aws_ecr_repository.app "$ECR_REPO_NAME"
  else
    echo "ECR repository already in state."
  fi
else
  echo "ECR repository '$ECR_REPO_NAME' does not exist. Skipping import."
fi

# Check and import App's DynamoDB Table
if aws dynamodb describe-table --table-name "$DYNAMO_TABLE_NAME" >/dev/null 2>&1; then
  echo "App DynamoDB table '$DYNAMO_TABLE_NAME' exists."
  if ! (terraform state list 2>/dev/null || true) | grep -q 'module.dynamodb.aws_dynamodb_table.app_table'; then
    echo "Importing App DynamoDB table..."
    terraform import -var-file="${ENVIRONMENT}.tfvars" module.dynamodb.aws_dynamodb_table.app_table "$DYNAMO_TABLE_NAME"
  else
    echo "App DynamoDB table already in state."
  fi
else
  echo "App DynamoDB table '$DYNAMO_TABLE_NAME' does not exist. Skipping import."
fi
