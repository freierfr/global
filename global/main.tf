terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.21"
      source  = "cloudflare/cloudflare"
    }
  }
  required_version = ">= 1.1.0"
}

