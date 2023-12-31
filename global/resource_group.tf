resource "azurerm_resource_group" "global" {
  name     = "global"
  location = var.location

  tags = {
    env = var.env
  }
}

# resource "azurerm_resource_group" "rg" {
#   name     = "test_terraform"
#   location = var.location

#   tags = {
#     environment = var.env
#     team        = "DevOps"
#   }
# }
