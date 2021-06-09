resource "azurerm_resource_group" "webapp" {
  name     = "webapp"
  location = "West US 2"
}

resource "azurerm_app_service_plan" "webapp" {
  name                = "test-env"
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name

  sku {
    tier = "Free"
    size = "F1"
  }
}



resource "azurerm_app_service" "example" {
  name                = "test-app-service"
  location            = azurerm_resource_group.webapp.location
  resource_group_name = azurerm_resource_group.webapp.name
  app_service_plan_id = azurerm_app_service_plan.webapp.id

  site_config {
    dotnet_framework_version = "v4.0"
    scm_type                 = "LocalGit"
  }

  app_settings = {
    "SOME_KEY" = "some-value"
  }

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}
