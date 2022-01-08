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
}

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

variable "ssh_key_fingerprint" {
  sensitive = true
}

variable "hcloud_volume_name" {
}

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

data "http" "local_ipv4" {
  url = "http://ipv4.icanhazip.com"
}

data "http" "local_ipv6" {
  url = "http://ipv6.icanhazip.com"
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

data "hcloud_ssh_key" "ssh-key" {
  fingerprint = var.ssh_key_fingerprint
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
      "${chomp(data.http.local_ipv4.body)}/32",
      "${chomp(data.http.local_ipv6.body)}/128",
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

  ssh_keys     = [data.hcloud_ssh_key.ssh-key.id]
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

resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tpl",
    {
      valheim_server_ip = hcloud_server.valheim-server.ipv4_address
    }
  )
  filename = "inventory"
}

resource "local_file" "server_ip" {
  content = hcloud_server.valheim-server.ipv4_address
  filename = "server_ip.txt"
}
