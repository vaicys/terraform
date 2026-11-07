# VPC

resource "google_compute_network" "chr_vpc" {
  name                    = "mikrotik-chr-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "chr_subnet" {
  name             = "mikrotik-chr-subnet"
  ip_cidr_range    = "10.0.1.0/24"
  region           = var.gcp_region
  network          = google_compute_network.chr_vpc.id
  stack_type       = "IPV4_IPV6"
  ipv6_access_type = "EXTERNAL"
}

# Firewall

resource "google_compute_firewall" "chr_allow_ipv4" {
  name    = "mikrotik-chr-allow-ipv4"
  network = google_compute_network.chr_vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["mikrotik-chr"]
}

resource "google_compute_firewall" "chr_allow_ipv6" {
  name    = "mikrotik-chr-allow-ipv6"
  network = google_compute_network.chr_vpc.name

  allow {
    protocol = "all"
  }

  source_ranges = ["::/0"]
  target_tags   = ["mikrotik-chr"]
}

# VM

resource "google_compute_instance" "mikrotik_chr" {
  name           = "mikrotik-chr"
  machine_type   = "e2-micro"
  zone           = var.gcp_zone
  desired_status = "RUNNING"
  tags           = ["mikrotik-chr"]

  boot_disk {
    initialize_params {
      # image = google_compute_image.mikrotik_chr.self_link
      type = "pd-standard" # Standard persistent disk is required for the 30 GB Free Tier
      size = 10            # GiB
    }
  }

  network_interface {
    network    = google_compute_network.chr_vpc.id
    subnetwork = google_compute_subnetwork.chr_subnet.id
    stack_type = "IPV4_IPV6"

    # Ephemeral External IPv4
    access_config {
      network_tier = "PREMIUM"
    }

    # External IPv6 (/96 range assigned to the interface)
    ipv6_access_config {
      network_tier = "PREMIUM"
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      boot_disk[0].initialize_params[0].image,
    ]
  }
}

locals {
  mikrotik_chr_ipv4 = google_compute_instance.mikrotik_chr.network_interface[0].access_config[0].nat_ip
  mikrotik_chr_ipv6 = cidrhost(
    "${google_compute_instance.mikrotik_chr.network_interface[0].ipv6_access_config[0].external_ipv6}/${google_compute_instance.mikrotik_chr.network_interface[0].ipv6_access_config[0].external_ipv6_prefix_length}",
    1
  )
}

output "mikrotik_chr_ipv4" {
  description = "MikroTik CHR IPv4 address"
  value       = local.mikrotik_chr_ipv4
}

output "mikrotik_chr_ipv6" {
  description = "MikrotIk CHR IPv6 address"
  value       = local.mikrotik_chr_ipv6
}

