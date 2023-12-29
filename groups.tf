# resource "azuread_group" "test" {
#   display_name     = "test"
#   owners           = [data.azuread_client_config.current.object_id]
#   security_enabled = true
# }
