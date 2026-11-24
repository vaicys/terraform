terraform {
  required_version = ">= 1.10.0"

  backend "local" {
    path = ".state/terraform.tfstate"
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.28.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 8.10.0"
    }
    oci = {
      source  = "oracle/oci"
      version = "~> 9.14.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Required for `user_project_override = true` (needed by Cloud Billing Budgets API):
#   gcloud services enable cloudresourcemanager.googleapis.com --project=<gcp_project_id>
provider "google" {
  project               = var.gcp_project_id
  billing_project       = var.gcp_project_id
  user_project_override = true
  region                = var.gcp_region
  zone                  = var.gcp_zone
}

provider "oci" {
  config_file_profile = "DEFAULT"
  region              = var.oci_region
}

