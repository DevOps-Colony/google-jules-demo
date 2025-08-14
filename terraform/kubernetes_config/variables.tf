variable "cluster_name" {
  description = "The name of the EKS cluster to configure."
  type        = string
}

variable "node_role_arn" {
  description = "The ARN of the IAM role for the EKS nodes."
  type        = string
}
