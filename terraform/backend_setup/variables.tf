variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
}

variable "project_name" {
  description = "The name of the project, used to construct resource names."
  type        = string
  default     = "my-flask-app"
}

variable "aws_role_arn" {
  description = "The name of the existing IAM role for GitHub Actions."
  type        = string
}
