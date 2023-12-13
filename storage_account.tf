resource "azurerm_storage_account" "example" {
  name                     = "testterraformstorage42"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_storage_container" "example" {
  name                  = "default"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}
