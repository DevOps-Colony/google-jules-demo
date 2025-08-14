# Agent Instructions

This document provides instructions for AI agents working on this repository.

## CI/CD Architecture

The CI/CD process is split into two main workflows:

1.  **`.github/workflows/infrastructure.yml`**: This workflow is for provisioning and managing all cloud infrastructure using Terraform.
    -   It is triggered **manually** via the "Actions" tab in GitHub.
    -   It requires selecting an environment (`dev` or `feature`).
    -   It has a `plan` job and an `apply` job. The `apply` job requires manual approval if configured in GitHub's environment settings.
    -   It calls the `application.yml` workflow upon successful completion.

2.  **`.github/workflows/application.yml`**: This workflow handles the application build, test, scan, and deployment.
    -   It is a **reusable workflow** and should not be run directly.
    -   It is triggered automatically by the `infrastructure.yml` workflow.

## Scripts

All complex shell logic is externalized into the `scripts/` directory. When modifying workflow logic, check if an existing script should be updated.

-   `scripts/backend_setup.sh`: Idempotent script to create/import the Terraform backend.
-   `scripts/auto_import.sh`: Idempotent script to import existing AWS resources into the Terraform state for a given environment.
-   `scripts/destroy_backend.sh`: Script to forcefully destroy the Terraform backend resources.

## Terraform

-   Infrastructure is defined in the `terraform/` directory.
-   The `modules/` directory contains reusable components.
-   The `environments/` directory contains the top-level configurations for each environment (`dev`, `feature`).
-   The `kubernetes_config/` directory contains the standalone configuration for the `aws-auth` ConfigMap.
