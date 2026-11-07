# Variables

locals {
  dns_ttl = 1 # Auto

  smtp2go_cnames = {
    "em873351.vaicys.com"           = "return.smtp2go.net"
    "link.vaicys.com"               = "track.smtp2go.net"
    "s873351._domainkey.vaicys.com" = "dkim.smtp2go.net"
  }

  txt_records = {
    "vaicys.com"        = "\"v=spf1 include:spf.smtp2go.com include:_spf.mx.cloudflare.net -all\""
    "_dmarc.vaicys.com" = "\"v=DMARC1; p=reject; sp=reject; rua=mailto:fa4844e444424708894dcc7db76ce87e@dmarc-reports.cloudflare.net\""
  }
}

# CloudFlare Pages

resource "cloudflare_dns_record" "vaicys_com_cname" {
  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = "vaicys.com"
  content = cloudflare_pages_project.vaicys_com.subdomain
  comment = "Pages"
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = true
}

resource "cloudflare_dns_record" "www_cname" {
  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = "www.vaicys.com"
  content = cloudflare_pages_project.vaicys_com.subdomain
  comment = "Pages"
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = true
}

# Email

resource "cloudflare_dns_record" "smtp2go_cnames" {
  for_each = local.smtp2go_cnames

  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = each.key
  content = each.value
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = false
  comment = "SMTP2GO"
}

resource "cloudflare_dns_record" "txt_records" {
  for_each = local.txt_records

  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = each.key
  content = each.value
  type    = "TXT"
  ttl     = local.dns_ttl
}

# IPv6 hosts

resource "cloudflare_dns_record" "ipv6_hosts" {
  for_each = var.ipv6_hosts

  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = "${each.key}.vaicys.com"
  content = each.value
  type    = "AAAA"
  ttl     = local.dns_ttl
  proxied = false
}

# Mikrotik routers

resource "cloudflare_dns_record" "mikrotik_routers" {
  for_each = var.mikrotik_routers

  zone_id = var.cloudflare_vaicys_com_zone_id
  name    = "${each.key}.vaicys.com"
  content = each.value
  comment = "MikroTik"
  type    = "CNAME"
  ttl     = local.dns_ttl
  proxied = false
}
