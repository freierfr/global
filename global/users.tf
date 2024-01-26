resource "random_password" "pwd" {
  length  = 32
  special = true
  lower   = true
  upper   = true
  numeric = true
}

locals {
  azure_users          = { for key, val in var.google_users : key => val if length([for s in val.custom_schemas : s if s.schema_name == "azure"]) > 0 && val.primary_email != "niels@freier.fr" }
  azure_users_filtered = [for v in local.azure_users : v if length(v) > 0]
}

resource "azuread_user" "users" {
  count = length(local.azure_users_filtered)

  user_principal_name   = local.azure_users_filtered[count.index].primary_email
  display_name          = local.azure_users_filtered[count.index].name[0].full_name
  mail_nickname         = lower(local.azure_users_filtered[count.index].name[0].given_name)
  mail                  = local.azure_users_filtered[count.index].primary_email
  password              = random_password.pwd.result
  force_password_change = true
  other_mails           = [local.azure_users_filtered[count.index].primary_email]

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

data "azuread_client_config" "current" {}

locals {
  freier_google_users    = [for user in azuread_user.users : user if strcontains(user.user_principal_name, "@freier.fr")]
  mensier_google_users   = [for user in azuread_user.users : user if strcontains(user.user_principal_name, "@mensier.fr")]
  akhmadova_google_users = [for user in azuread_user.users : user if strcontains(user.user_principal_name, "@akhmadova.fr")]
}

resource "azuread_group" "freier" {
  display_name     = "freier"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = concat([for user in local.freier_google_users : user.object_id], [data.azuread_client_config.current.object_id])
}

resource "azuread_group" "mensier" {
  display_name     = "mensier"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [for user in local.mensier_google_users : user.object_id]
}

resource "azuread_group" "akhmadova" {
  display_name     = "akhmadova"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = [for user in local.akhmadova_google_users : user.object_id]
}