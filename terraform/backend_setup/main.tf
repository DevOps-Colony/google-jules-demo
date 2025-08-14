terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# This data source is used to look up the OIDC provider for GitHub Actions.
# This assumes the provider has been created in the AWS account.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# This data source is used to look up an existing IAM role.
# This assumes the role has been created with the correct trust policy.
data "aws_iam_role" "github_actions" {
  name = var.iam_role_name
}

locals {
  s3_bucket_name = "${var.project_name}-terraform-state"
  dynamodb_name  = "${var.project_name}-terraform-lock"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.s3_bucket_name
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tflock" {
  name           = local.dynamodb_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions"
  value       = data.aws_iam_role.github_actions.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state lock"
  value       = aws_dynamodb_table.tflock.name
}
