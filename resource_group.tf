resource "azurerm_resource_group" "global" {
  name     = "global"
  location = "westeurope"

  tags = {
    environment = "dev"
    team        = "DevOps"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "test_terraform"
  location = "westeurope"

  tags = {
    environment = "dev"
    team        = "DevOps"
  }
}