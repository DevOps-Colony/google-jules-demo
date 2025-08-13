module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1" # Using an older, more stable version to avoid recent provider issues.

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags = {
    Terraform   = "true"
    Environment = "feature"
  }
}
