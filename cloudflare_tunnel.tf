# Tunnel

resource "cloudflare_zero_trust_tunnel_cloudflared" "main" {
  account_id = var.cloudflare_account_id
  config_src = "local"
  name       = var.cloudflare_tunnel_name
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "main_config" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.main.id
  source     = "cloudflare"
  config = {
    warp_routing = {
      enabled = true
    }
    ingress = concat(
      [
        for hostname, service in var.cloudflare_tunnel_applications : {
          hostname       = hostname
          service        = service
          origin_request = { no_tls_verify = true }
        }
      ],
      [
        {
          service = "http_status:404"
        }
      ]
    )
  }
}

# DNS

resource "cloudflare_dns_record" "tunnel_cnames" {
  for_each = var.cloudflare_tunnel_applications

  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = each.key
  content = "${cloudflare_zero_trust_tunnel_cloudflared.main.id}.cfargotunnel.com"
  comment = "Tunnel"
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = true
}
