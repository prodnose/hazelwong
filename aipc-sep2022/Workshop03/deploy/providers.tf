terraform {
  required_version = ">= 1.2.8"
  required_providers {
    digitalocean = {
        source = "digitalocean/digitalocean"
        version = "2.22.3"
    }
    local = {
        source = "hashicorp/local"
        version = "2.2.3"
    }
  }
}

provider digitalocean {
    token = var.DO_token
}

provider local { }
