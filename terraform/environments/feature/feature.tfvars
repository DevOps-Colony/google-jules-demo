# terraform/environments/feature/feature.tfvars

aws_region = "ap-south-1"

vpc_name = "my-app-vpc-feature"
vpc_cidr = "10.0.0.0/16"
azs      = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

cluster_name    = "my-app-eks-cluster-feature"
cluster_version = "1.28"
instance_types  = ["t3.medium"]
min_size        = 1
max_size        = 3
desired_size    = 2

ecr_repository_name = "my-flask-app-feature"
dynamodb_table_name = "my-flask-app-users-feature"
