variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for the Terraform state."
  type        = string
}

variable "table_name" {
  description = "The name of the DynamoDB table for the Terraform state lock."
  type        = string
}
