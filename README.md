# Terraform scripts

Terraform configuration for personal cloud infrastructure:

- Cloudflare
- Google Cloud

# Usage

For GCP usage, authenticate with `gcloud auth application-default login`.

```sh
terraform init                 # initialize backend and providers
terraform plan                 # preview changes
terraform apply                # apply changes interactively
terraform apply -auto-approve  # apply changes without confirmation
```
