data "cloudflare_zone" "stumpy_fr" {
  name = "stumpy.fr"
}

# resource "azurerm_dns_zone" "stumpy_fr" {
#   name                = "stumpy.fr"
#   resource_group_name = azurerm_resource_group.global.name
# }

# resource "azurerm_dns_cname_record" "example" {
#   name                = "test"
#   zone_name           = azurerm_dns_zone.stumpy_fr.name
#   resource_group_name = azurerm_resource_group.global.name
#   ttl                 = 300
#   record              = "freierservices.blob.core.windows.net"
# }
