provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name           = var.vpc_name
  vpc_cidr           = var.vpc_cidr
  azs                = data.aws_availability_zones.available.names
  private_subnets    = var.private_subnets
  public_subnets     = var.public_subnets
  enable_nat_gateway = var.enable_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
  instance_types  = var.instance_types
  min_size        = var.min_size
  max_size        = var.max_size
  desired_size    = var.desired_size
}

module "ecr" {
  source = "../../modules/ecr"

  ecr_repository_name = var.ecr_repository_name
}

module "dynamodb" {
  source = "../../modules/dynamodb"

  table_name = var.dynamodb_table_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.this.token
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      [
        {
          rolearn  = module.eks.node_role_arn
          username = "system:node:{{EC2PrivateDNSName}}"
          groups   = [
            "system:bootstrappers",
            "system:nodes",
          ]
        },
      ],
      [
        {
          rolearn  = var.cicd_role_arn
          username = "admin"
          groups   = [
            "system:masters",
          ]
        }
      ]
    ))
  }

  depends_on = [module.eks]
}
