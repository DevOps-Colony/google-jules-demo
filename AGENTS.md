# Agent Instructions for DevOps Project

This document provides a comprehensive overview of the project architecture, components, and operational procedures for other agents.

## 1. Project Overview

This project consists of a complete CI/CD pipeline that builds, tests, and deploys a Python Flask web application to an Amazon EKS cluster. The entire infrastructure is managed as code using Terraform, and deployments are handled by Helm.

The key components are:
- **Python Flask Application**: A simple web app with user login/registration.
- **Terraform**: Manages all AWS infrastructure (VPC, EKS, ECR, DynamoDB).
- **Helm**: Packages the application for Kubernetes deployment.
- **GitHub Actions**: Orchestrates the entire CI/CD pipeline.
- **SonarCloud**: Performs static code analysis.
- **Trivy**: Scans the Docker image for vulnerabilities.

## 2. Codebase Structure

- `app/`: Contains the source code for the Python Flask application.
- `tests/`: Contains unit tests for the application.
- `terraform/`: Contains all Terraform code.
  - `modules/`: Contains reusable Terraform modules for each component (VPC, EKS, etc.).
  - `environments/`: Contains environment-specific configurations.
    - `feature/`: The main environment we have built, with its own `main.tf` and `feature.tfvars`.
  - `backend_setup/`: A standalone Terraform configuration to provision the S3 bucket and DynamoDB table for the remote state backend.
- `helm/`: Contains the Helm chart for the application.
- `.github/workflows/`: Contains the GitHub Actions workflow definitions.
  - `main.yml`: The main CI/CD pipeline.
  - `destroy.yml`: A manually triggered workflow to destroy the infrastructure.
- `sonar-project.properties`: Configuration for the SonarCloud scanner.
- `Dockerfile`: Instructions for building the application's Docker image.

## 3. CI/CD Pipeline (`main.yml`)

The main pipeline is triggered on a push to the `main` branch. It consists of two main jobs:

### Job 1: `backend-setup`
- **Purpose**: To create the foundational resources for Terraform's remote state backend.
- **Steps**:
  1. Checks out the code.
  2. Configures AWS credentials using short-lived secrets (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).
  3. Runs `terraform apply` on the `terraform/backend_setup` configuration.
- **Inputs**: This job requires the following GitHub Secrets: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_REGION`, `TF_STATE_BUCKET`, `TF_STATE_LOCK_TABLE`, `IAM_ROLE_NAME`.

### Job 2: `build-and-deploy`
- **Purpose**: To build, test, and deploy the application and its infrastructure.
- **Steps**:
  1. **Setup**: Checks out code, configures AWS credentials via OIDC (`AWS_ROLE_ARN`), and sets up Python.
  2. **CI**: Installs dependencies, runs unit tests, and performs a SonarCloud scan.
  3. **Terraform Apply**: Initializes Terraform using the S3 backend created in the previous job and runs `terraform apply` on the `feature` environment to create the VPC, EKS cluster, ECR repo, and DynamoDB table.
  4. **Docker Build & Push**: Builds the application's Docker image and pushes it to the newly created ECR repository.
  5. **Trivy Scan**: Scans the pushed Docker image for vulnerabilities.
  6. **Helm Deploy**: Sets up `kubectl` and `helm`, configures access to the EKS cluster, and deploys the application using the Helm chart.

## 4. Destruction Workflow (`destroy.yml`)

- **Purpose**: To safely destroy all infrastructure created by the `main.yml` pipeline for the `feature` environment.
- **Trigger**: This workflow is triggered manually via `workflow_dispatch`.
- **How to Run**:
  1. Go to the "Actions" tab in the GitHub repository.
  2. Select the "Destroy Infrastructure" workflow from the list on the left.
  3. Click the "Run workflow" button.
  4. It will use the same secrets as the main pipeline to connect to the Terraform backend and run `terraform destroy`.

## 5. Required Secrets for Operation

To run the pipelines successfully, the following secrets must be configured in the GitHub repository under **Settings > Secrets and variables > Actions > Secrets**:

- `AWS_ACCESS_KEY_ID`: An AWS access key ID.
- `AWS_SECRET_ACCESS_KEY`: An AWS secret access key.
- `AWS_ROLE_ARN`: The ARN of the IAM role for GitHub Actions to assume (with the correct OIDC trust policy).
- `IAM_ROLE_NAME`: The name of the IAM role specified in `AWS_ROLE_ARN`.
- `AWS_REGION`: The target AWS region (e.g., `ap-south-1`).
- `TF_STATE_BUCKET`: A **globally unique** name for the S3 bucket that will store the Terraform state (e.g., `my-org-jules-demo-tfstate`).
- `TF_STATE_LOCK_TABLE`: A name for the DynamoDB table for state locking (e.g., `my-org-jules-demo-tflock`).
- `SONAR_TOKEN`: A token for authenticating with SonarCloud.
