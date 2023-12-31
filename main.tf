terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.21"
    }
  }


  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstatefreier"
    container_name       = "tfstate"
    key                  = "global.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

provider "cloudflare" {
  api_token = var.CLOUDFLARE_API_TOKEN
}

# data "terraform_remote_state" "google_workspace" {
#   backend = "azurerm"

#   config = {
#     resource_group_name  = "tfstate"
#     storage_account_name = "tfstatefreier"
#     container_name       = "tfstate"
#     key                  = "terraform_google_workspace.tfstate"
#   }
# }

# data "azuread_client_config" "current" {}

# data "azurerm_client_config" "current" {}

module "global" {
  source = "./global"
}
