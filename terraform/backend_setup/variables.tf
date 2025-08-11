# terraform/backend_setup/variables.tf

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-south-1"
}

variable "iam_role_name" {
  description = "The name of the existing IAM role for GitHub Actions."
  type        = string
  default     = "github-actions-role"
}
