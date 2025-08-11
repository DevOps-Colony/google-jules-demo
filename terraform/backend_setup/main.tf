provider "aws" {
  region = var.aws_region
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
