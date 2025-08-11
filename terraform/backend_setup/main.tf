# terraform/backend_setup/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "bucket_name" {
  length = 2
}

resource "random_pet" "table_name" {
  length = 2
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "github_actions" {
  name = var.iam_role_name
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "tfstate-${random_pet.bucket_name.id}"

  tags = {
    Name        = "Terraform state bucket"
    Environment = "production"
  }
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
  name           = "tflock-${random_pet.table_name.id}"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "Terraform lock table"
    Environment = "production"
  }
}

output "github_actions_role_arn" {
  description = "The ARN of the IAM role for GitHub Actions"
  value       = data.aws_iam_role.github_actions.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for the Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for the Terraform state lock"
  value       = aws_dynamodb_table.tflock.name
}
