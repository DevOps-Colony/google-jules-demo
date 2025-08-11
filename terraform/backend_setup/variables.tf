# terraform/backend_setup/variables.tf

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "The globally unique name of the S3 bucket for the Terraform state."
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table for the Terraform state lock."
  type        = string
}

variable "iam_role_name" {
  description = "The name of the existing IAM role for GitHub Actions."
  type        = string
  default     = "github-actions-role"
}
