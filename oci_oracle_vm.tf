# Availability Domains & Platform Image

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.oci_tenancy_ocid
}

data "oci_core_images" "oracle_linux" {
  compartment_id   = var.oci_tenancy_ocid
  operating_system = "Oracle Linux"
  shape            = "VM.Standard.A1.Flex"
  sort_by          = "TIMECREATED"
  sort_order       = "DESC"

  filter {
    name   = "display_name"
    values = ["^Oracle-Linux-10\\.[0-9]+-aarch64-[0-9]{4}\\..*$"]
    regex  = true
  }
}

# VCN & Dual-Stack Networking

resource "oci_core_vcn" "oracle_vcn" {
  compartment_id = var.oci_tenancy_ocid
  display_name   = "oracle-vcn"
  dns_label      = "oraclevcn"
  cidr_blocks    = ["10.1.0.0/16"]
  is_ipv6enabled = true
}

resource "oci_core_internet_gateway" "oracle_igw" {
  compartment_id = var.oci_tenancy_ocid
  vcn_id         = oci_core_vcn.oracle_vcn.id
  display_name   = "oracle-igw"
  enabled        = true
}

resource "oci_core_route_table" "oracle_rt" {
  compartment_id = var.oci_tenancy_ocid
  vcn_id         = oci_core_vcn.oracle_vcn.id
  display_name   = "oracle-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oracle_igw.id
  }

  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oracle_igw.id
  }
}

# Firewall (Security List: SSH + essential PMTUD/RFC 4890 ICMP only)

resource "oci_core_security_list" "oracle_sl" {
  compartment_id = var.oci_tenancy_ocid
  vcn_id         = oci_core_vcn.oracle_vcn.id
  display_name   = "oracle-sl"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  egress_security_rules {
    destination      = "::/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

  ingress_security_rules {
    description = "SSH over IPv4"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "SSH over IPv6"
    protocol    = "6"
    source      = "::/0"
    source_type = "CIDR_BLOCK"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    description = "IPv4 Path MTU Discovery (Fragmentation Needed)"
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "IPv4 VCN ICMP Destination Unreachable"
    protocol    = "1"
    source      = "10.1.0.0/16"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 3
    }
  }

  ingress_security_rules {
    description = "ICMPv6 Destination Unreachable"
    protocol    = "58"
    source      = "::/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 1
    }
  }

  ingress_security_rules {
    description = "ICMPv6 Packet Too Big (Path MTU Discovery)"
    protocol    = "58"
    source      = "::/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 2
    }
  }

  ingress_security_rules {
    description = "ICMPv6 Time Exceeded"
    protocol    = "58"
    source      = "::/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 3
    }
  }

  ingress_security_rules {
    description = "ICMPv6 Parameter Problem"
    protocol    = "58"
    source      = "::/0"
    source_type = "CIDR_BLOCK"

    icmp_options {
      type = 4
    }
  }
}

resource "oci_core_subnet" "oracle_subnet" {
  compartment_id             = var.oci_tenancy_ocid
  vcn_id                     = oci_core_vcn.oracle_vcn.id
  display_name               = "oracle-subnet"
  dns_label                  = "public"
  cidr_block                 = "10.1.1.0/24"
  ipv6cidr_block             = cidrsubnet(oci_core_vcn.oracle_vcn.ipv6cidr_blocks[0], 8, 0)
  prohibit_public_ip_on_vnic = false
  prohibit_internet_ingress  = false
  route_table_id             = oci_core_route_table.oracle_rt.id
  security_list_ids          = [oci_core_security_list.oracle_sl.id]
}

# VM (Ampere A1 Flex: 4 OCPUs, 24 GB RAM, 200 GB Boot Volume)

resource "oci_core_instance" "oracle" {
  availability_domain  = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id       = var.oci_tenancy_ocid
  display_name         = "oracle"
  shape                = "VM.Standard.A1.Flex"
  preserve_boot_volume = false

  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.oracle_subnet.id
    display_name     = "oracle-vnic"
    hostname_label   = "oracle"
    assign_public_ip = false
    assign_ipv6ip    = false
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.oracle_linux.images[0].id
    boot_volume_size_in_gbs = 200
    boot_volume_vpus_per_gb = 10
  }

  metadata = {
    ssh_authorized_keys = var.oci_ssh_public_key
    user_data = base64encode(<<-EOF
      #!/bin/bash
      /usr/libexec/oci-growfs -y
    EOF
    )
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      source_details[0].source_id,
    ]
  }
}

# Reserved Public IPv4 & Static IPv6

data "oci_core_vnic_attachments" "oracle_vnics" {
  compartment_id      = var.oci_tenancy_ocid
  availability_domain = oci_core_instance.oracle.availability_domain
  instance_id         = oci_core_instance.oracle.id
}

data "oci_core_private_ips" "oracle_private_ips" {
  vnic_id = data.oci_core_vnic_attachments.oracle_vnics.vnic_attachments[0].vnic_id
}

resource "oci_core_public_ip" "oracle_ipv4" {
  compartment_id = var.oci_tenancy_ocid
  display_name   = "oracle-ipv4"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.oracle_private_ips.private_ips[0].id
}

resource "oci_core_ipv6" "oracle_ipv6" {
  vnic_id      = data.oci_core_vnic_attachments.oracle_vnics.vnic_attachments[0].vnic_id
  display_name = "oracle-ipv6"
}

locals {
  oracle_ipv4 = oci_core_public_ip.oracle_ipv4.ip_address
  oracle_ipv6 = oci_core_ipv6.oracle_ipv6.ip_address
}

output "oracle_ipv4" {
  description = "Oracle Cloud VM Reserved IPv4 address"
  value       = local.oracle_ipv4
}

output "oracle_ipv6" {
  description = "Oracle Cloud VM IPv6 address"
  value       = local.oracle_ipv6
}
