resource "azurerm_resource_group" "marvin_dev_rg" {
  name     = "marvin_dev"
  location = var.location

  tags = {
    environment = var.env
  }
}

resource "azurerm_storage_account" "marvin_dev_storage_account" {
  name                     = "marvin42devstorage"
  resource_group_name      = azurerm_resource_group.marvin_dev_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_workspace" "marvin_dev_log_analytics_workspace" {
  name                = "marvin-${var.env}-log-analytics-workspace"
  location            = azurerm_resource_group.marvin_dev_rg.location
  resource_group_name = azurerm_resource_group.marvin_dev_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "marvin_dev_application_insights" {
  name                = "marvin-${var.env}-application-insights"
  location            = azurerm_resource_group.marvin_dev_rg.location
  resource_group_name = azurerm_resource_group.marvin_dev_rg.name
  workspace_id        = azurerm_log_analytics_workspace.marvin_dev_log_analytics_workspace.id
  application_type    = "other"
}

resource "azurerm_service_plan" "marvin_dev_service_plan" {
  name                = "marvin-${var.env}-app-service-plan"
  resource_group_name = azurerm_resource_group.marvin_dev_rg.name
  location            = azurerm_resource_group.marvin_dev_rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "marvin_dev_function_app" {
  name                = "marvin-${var.env}-function-app"
  resource_group_name = azurerm_resource_group.marvin_dev_rg.name
  location            = azurerm_resource_group.marvin_dev_rg.location

  storage_account_name       = azurerm_storage_account.marvin_dev_storage_account.name
  storage_account_access_key = azurerm_storage_account.marvin_dev_storage_account.primary_access_key
  service_plan_id            = azurerm_service_plan.marvin_dev_service_plan.id

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"  = "",
    "OPENAI_MODEL"              = "gpt-4-1106-preview",
    "WEBHOOK_URL"               = "https://marvin-dev.stumpy.fr/api/telegram"
    "OPENAI_API_KEY"            = var.OPENAI_API_KEY,
    "TELEGRAM_TOKEN"            = var.TELEGRAM_TOKEN,
    "BOT_PROMPT"                = "You are a helpful assistant and your name is Marvin",
    "ALLOWED_TELEGRAM_USER_IDS" = join(",", data.terraform_remote_state.google_workspace.outputs.telegram_user_ids),
    "GROUP_TRIGGER_KEYWORD"     = "marvin",
    "REDIS_HOST"                = var.REDIS_HOST,
    "REDIS_LOGIN"               = var.REDIS_LOGIN,
    "REDIS_PASSWORD"            = var.REDIS_PASSWORD,
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }

  site_config {
    application_insights_connection_string = azurerm_application_insights.marvin_dev_application_insights.connection_string
    application_insights_key               = azurerm_application_insights.marvin_dev_application_insights.instrumentation_key
  }
}

resource "azurerm_key_vault" "marvin_dev_keyvault" {
  name                        = "marvin-${var.env}-key-vault"
  location                    = azurerm_resource_group.marvin_dev_rg.location
  resource_group_name         = azurerm_resource_group.marvin_dev_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "marvin_dev_keyvault_access_policy" {
  key_vault_id = azurerm_key_vault.marvin_dev_keyvault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azuread_client_config.current.object_id

  #   key_permissions = [
  #     "Get",
  #   ]

  secret_permissions = [
    "Get", "List", "Delete", "Recover", "Backup", "Restore", "Set",
  ]
}

resource "azurerm_key_vault_secret" "marvin_dev_secret_redis_login" {
  name         = "redis-login"
  value        = "default"
  key_vault_id = azurerm_key_vault.marvin_dev_keyvault.id
}

resource "azurerm_key_vault_secret" "marvin_dev_secret_redis_password" {
  name         = "redis-password"
  value        = var.REDIS_PASSWORD
  key_vault_id = azurerm_key_vault.marvin_dev_keyvault.id
}

resource "azurerm_app_service_custom_hostname_binding" "marvin_dev_custom_domain" {
  hostname            = "marvin-${var.env}.stumpy.fr"
  app_service_name    = azurerm_linux_function_app.marvin_dev_function_app.name
  resource_group_name = azurerm_resource_group.marvin_dev_rg.name

  # Ignore ssl_state and thumbprint as they are managed using
  # azurerm_app_service_certificate_binding.example
  lifecycle {
    ignore_changes = [ssl_state, thumbprint]
  }

  depends_on = [
    azurerm_app_service_custom_hostname_binding.marvin_dev_custom_domain
  ]
}

resource "azurerm_app_service_managed_certificate" "marvin_dev_managed_certificate" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.marvin_dev_custom_domain.id
}

resource "azurerm_app_service_certificate_binding" "marvin_dev_managed_certificate_binding" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.marvin_dev_custom_domain.id
  certificate_id      = azurerm_app_service_managed_certificate.marvin_dev_managed_certificate.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_dns_txt_record" "marvin_dev_dns_txt" {
  name                = "asuid.marvin-${var.env}"
  zone_name           = azurerm_dns_zone.stumpy_fr.name
  resource_group_name = azurerm_resource_group.global.name
  ttl                 = 300
  record {
    value = azurerm_linux_function_app.marvin_dev_function_app.custom_domain_verification_id
  }
}

resource "azurerm_dns_cname_record" "marvin_dev_cname" {
  name                = "marvin-${var.env}"
  zone_name           = azurerm_dns_zone.stumpy_fr.name
  resource_group_name = azurerm_resource_group.global.name
  ttl                 = 300
  record              = azurerm_linux_function_app.marvin_dev_function_app.default_hostname
}

# output "function_app_name" {
#   value       = azurerm_linux_function_app.marvin_dev_function_app.name
#   description = "Deployed function app name"
# }

# output "function_app_default_hostname" {
#   value       = azurerm_linux_function_app.marvin_dev_function_app.default_hostname
#   description = "Deployed function app hostname"
# }