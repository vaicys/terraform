# CloudFlare

variable "cloudflare_api_token" {
  description = "Cloudflare API Token"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID"
  type        = string
}

variable "cloudflare_vaicys_com_zone_id" {
  description = "Cloudflare Zone ID for vaicys.com"
  type        = string
}

variable "ipv6_hosts" {
  description = "Map of host subdomains to their IPv6 addresses (AAAA records)"
  type        = map(string)
}

variable "mikrotik_routers" {
  description = "Map of MikroTik router subdomains to their DDNS/CNAME targets"
  type        = map(string)
}

variable "cloudflare_tunnel_name" {
  description = "Name of the Cloudflare Zero Trust tunnel"
  type        = string
}

variable "cloudflare_access_allowed_emails" {
  description = "List of email addresses allowed by the Cloudflare Zero Trust Access policy"
  type        = list(string)
}

variable "cloudflare_tunnel_applications" {
  description = "Map of Cloudflare Tunnel application hostnames to their internal LAN service URLs"
  type        = map(string)
}

# Google Cloud Platform

variable "gcp_project_id" {
  description = "Google Cloud Project ID"
  type        = string
  sensitive   = true
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-east1"
}

variable "gcp_zone" {
  description = "GCP zone within the region"
  type        = string
  default     = "us-east1-b"
}

variable "gcp_oauth_client_id" {
  description = "Google OAuth 2.0 Client ID"
  type        = string
}

variable "gcp_oauth_client_secret" {
  description = "Google OAuth 2.0 Client Secret"
  type        = string
  sensitive   = true
}
