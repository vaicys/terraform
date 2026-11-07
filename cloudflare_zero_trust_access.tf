# Applications

resource "cloudflare_zero_trust_access_application" "home_network_access" {
  account_id       = var.cloudflare_account_id
  name             = "home network"
  type             = "self_hosted"
  session_duration = "730h"

  allowed_idps = [
    cloudflare_zero_trust_access_identity_provider.google.id,
    cloudflare_zero_trust_access_identity_provider.passkeys.id,
  ]

  auto_redirect_to_identity  = false
  enable_binding_cookie      = false
  http_only_cookie_attribute = false
  options_preflight_bypass   = false

  destinations = [
    for hostname, _ in var.cloudflare_tunnel_applications : {
      type = "public"
      uri  = hostname
    }
  ]

  policies = [
    {
      id         = cloudflare_zero_trust_access_policy.home_access.id
      precedence = 1
    }
  ]
}

# Policies

resource "cloudflare_zero_trust_access_policy" "home_access" {
  account_id       = var.cloudflare_account_id
  name             = "Home access"
  decision         = "allow"
  session_duration = "730h"
  exclude          = []
  require          = []

  include = [
    for email in var.cloudflare_access_allowed_emails : {
      email = {
        email = email
      }
    }
  ]
}

# Identity providers

resource "cloudflare_zero_trust_access_identity_provider" "google" {
  account_id = var.cloudflare_account_id
  name       = "Google"
  type       = "google"

  config = {
    client_id     = var.gcp_oauth_client_id
    client_secret = var.gcp_oauth_client_secret
  }
}

resource "cloudflare_zero_trust_access_identity_provider" "passkeys" {
  account_id = var.cloudflare_account_id
  name       = "Passkeys"
  type       = "passkeys"

  config = {
    login_page_auto_prompt = true
  }
}
