resource "azurerm_resource_group" "blog_niels_rg" {
  name     = "blog_niels_${var.env}"
  location = var.location

  tags = {
    env = var.env
  }
}

resource "azurerm_log_analytics_workspace" "blog_niels_log_analytics_workspace" {
  name                = "blog-niels-${var.env}-log-analytics-workspace"
  location            = azurerm_resource_group.blog_niels_rg.location
  resource_group_name = azurerm_resource_group.blog_niels_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "blog_niels_application_insights" {
  name                = "blog-niels-${var.env}-application-insights"
  location            = azurerm_resource_group.blog_niels_rg.location
  resource_group_name = azurerm_resource_group.blog_niels_rg.name
  workspace_id        = azurerm_log_analytics_workspace.blog_niels_log_analytics_workspace.id
  application_type    = "other"
}

output "blog_niels_application_insights_connection_string" {
  value     = azurerm_application_insights.blog_niels_application_insights.connection_string
  sensitive = true
}
