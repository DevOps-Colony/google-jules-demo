terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name" # This will be parameterized in the CI/CD pipeline
    key            = "global/s3/terraform.tfstate"
    region         = "ap-south-1" # This will also be parameterized
    dynamodb_table = "your-terraform-lock-table-name" # This will be parameterized
    encrypt        = true
  }
}
