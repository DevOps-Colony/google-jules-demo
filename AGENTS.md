# Agent Instructions

This document provides instructions for AI agents working on this repository.

## CI/CD Architecture

The CI/CD process is split into two main workflows:

1.  **`.github/workflows/infrastructure.yml`**: This workflow is for provisioning and managing all cloud infrastructure using Terraform.
    -   It is triggered **manually** via the "Actions" tab in GitHub and requires selecting an environment (`dev` or `feature`).
    -   It uses a safe, multi-stage process:
        1.  `provision_backend`: Creates the S3/DynamoDB backend.
        2.  `plan_environment`: Runs `terraform plan` for the selected environment and saves the plan as an artifact.
        3.  `apply_infra`: **Requires manual approval if configured in GitHub Environments.** Downloads the plan artifact and applies it to create the core infrastructure (VPC, EKS, etc.).
        4.  `apply_kubernetes_auth`: Applies the `aws-auth` ConfigMap to the cluster to authorize nodes.
    -   It calls the `application.yml` workflow upon successful completion.

2.  **`.github/workflows/application.yml`**: This workflow handles the application build, test, scan, and deployment.
    -   It is a **reusable workflow** and should not be run directly.
    -   It is triggered automatically by the `infrastructure.yml` workflow.

## Scripts

All complex shell logic is externalized into the `scripts/` directory.

-   `scripts/backend_setup.sh`: Idempotent script to create/import the Terraform backend.
-   `scripts/destroy_backend.sh`: Script to forcefully destroy the Terraform backend resources.

## Terraform

-   Infrastructure is defined in the `terraform/` directory.
-   `modules/`: Contains reusable components for AWS resources.
-   `environments/`: Contains the top-level configurations for each environment (`dev`, `feature`).
-   `kubernetes_config/`: Contains the standalone configuration for the `aws-auth` ConfigMap, which is applied after the EKS cluster is created.
