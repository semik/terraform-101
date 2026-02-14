resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.primary_location
}

resource "random_string" "keyvault_suffix" {
  length  = 6
  upper   = false
  special = false
}

data "azurerm_client_config" "current" {
}

resource "azurerm_key_vault" "main" {
  # The name of a key vault must be globally unique, so we add a random suffix to ensure that.
  # https://learn.microsoft.com/en-us/answers/questions/1181088/why-doe-key-vault-names-have-to-be-worldwide-uniqu
  name                        = "kv-${var.application_name}-${var.environment_name}-${random_string.keyvault_suffix.result}"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  # tenant_id                   = "602f4382-5b54-48fc-abfe-eb49e4b2d38a"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name = "standard"

  rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "terraform_user" {
  scope                = azurerm_key_vault.main.id
  # https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

data "azurerm_log_analytics_workspace" "observability" {
  name                = "log-observability-dev"
  resource_group_name = "rg-observability-dev"
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  name               = "diag-${var.application_name}-${var.environment_name}-${random_string.keyvault_suffix.result}"
  target_resource_id = azurerm_key_vault.main.id

  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.observability.id

  enabled_log {
    category_group = "audit"
  }

  enabled_log {
    category_group = "alllogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}