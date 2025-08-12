# terraform/backend_setup/main.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "github_actions" {
  name = var.iam_role_name
}

resource "aws_s3_bucket" "tfstate" {
  bucket = var.bucket_name

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
  name           = var.table_name
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
