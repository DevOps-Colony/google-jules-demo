output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = aws_eks_cluster.this.name
}

output "cluster_ca_certificate" {
  description = "Certificate authority data for the EKS cluster"
  value       = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_role_arn" {
  description = "ARN of the IAM role for the EKS nodes"
  value       = aws_iam_role.nodes.arn
}
