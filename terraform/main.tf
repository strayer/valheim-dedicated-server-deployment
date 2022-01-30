terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.32.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }

  cloud {
    organization = "gru-earth"

    workspaces {
      name = "valheim-dedicated-server"
    }
  }
}

variable "cloud_organization" {}
variable "cloud_workspace" {}

variable "hcloud_token" {
  sensitive = true
}

variable "cloudflare_email" {
  sensitive = true
}

variable "cloudflare_api_key" {
  sensitive = true
}

variable "zone_name" {
  sensitive = true
}

variable "server_subdomain" {
  sensitive = true
}

variable "hcloud_volume_name" {
}

variable "local_ipv4" {}

variable "ssh_pubkey" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}

data "cloudflare_zone" "gru" {
  name = var.zone_name
}

resource "cloudflare_record" "valheim_server_ipv4" {
  zone_id = data.cloudflare_zone.gru.zone_id
  name    = var.server_subdomain
  value   = hcloud_server.valheim-server.ipv4_address
  type    = "A"
  ttl     = 60
}

resource "cloudflare_record" "valheim_server_ipv6" {
  zone_id = data.cloudflare_zone.gru.zone_id
  name    = var.server_subdomain
  value   = hcloud_server.valheim-server.ipv6_address
  type    = "AAAA"
  ttl     = 60
}

resource "hcloud_ssh_key" "ansible" {
  name       = "Ansible"
  public_key = var.ssh_pubkey
}

data "hcloud_ssh_keys" "all_keys" {
  depends_on = [
    hcloud_ssh_key.ansible,
  ]
}

data "hcloud_volume" "valheim-home" {
  name = var.hcloud_volume_name
}

resource "hcloud_firewall" "valheim-firewall" {
  name = "valheim-firewall"

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "${var.local_ipv4}/32",
    ]
  }

  rule {
    direction = "in"
    protocol  = "udp"
    port      = "2456-2457"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_server" "valheim-server" {
  name        = "valheim-server"
  image       = "debian-11"
  server_type = "ccx12"
  location    = "nbg1"

  ssh_keys     = data.hcloud_ssh_keys.all_keys.ssh_keys.*.name
  firewall_ids = [hcloud_firewall.valheim-firewall.id]
}

resource "hcloud_rdns" "valheim-server-ipv4" {
  server_id  = hcloud_server.valheim-server.id
  ip_address = hcloud_server.valheim-server.ipv4_address
  dns_ptr    = cloudflare_record.valheim_server_ipv4.hostname
}

resource "hcloud_volume_attachment" "valheim-home-to-server" {
  volume_id = data.hcloud_volume.valheim-home.id
  server_id = hcloud_server.valheim-server.id
  automount = true
}

output "server_ip" { value = hcloud_server.valheim-server.ipv4_address }
output "volume_id" { value = data.hcloud_volume.valheim-home.id }
