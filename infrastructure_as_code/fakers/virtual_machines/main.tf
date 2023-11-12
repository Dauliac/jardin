provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_domain" "default" {
  name = "test"
}

terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_record" "nodes" {
  zone_id = var.cloudflare_zone_id
  for_each = var.nodes
  name    = each.key
  value   = each.value
  type    = "A"
  ttl     = 3600
}
