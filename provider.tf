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

provider "google" {
  credentials           = var.gcp_credentials
  project               = var.gcp_project_id
  billing_project       = var.gcp_project_id
  user_project_override = true
  region                = var.gcp_region
  zone                  = var.gcp_zone
}

provider "oci" {
  tenancy_ocid = var.oci_tenancy_ocid
  user_ocid    = var.oci_user_ocid
  fingerprint  = var.oci_fingerprint
  private_key  = var.oci_private_key
  region       = var.oci_region
}

