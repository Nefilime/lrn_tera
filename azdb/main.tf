terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.61.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = "example-resources"
  location = "West US 2"
}

resource "azurerm_sql_server" "sqlsrv" {
  name                         = "myexamplesqlserver"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "West US 2"
  version                      = "12.0"
  administrator_login          = var.usr
  administrator_login_password = var.pass

  tags = {
    environment = "TestEnv"
  }
}

resource "azurerm_storage_account" "stacc" {
  name                     = "examplesa"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "db" {
  name                = "myexamplesqldatabase"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  server_name         = azurerm_sql_server.sqlsrv.name

  extended_auditing_policy {
    storage_endpoint                        = azurerm_storage_account.stacc.primary_blob_endpoint
    storage_account_access_key              = azurerm_storage_account.stacc.primary_access_key
    storage_account_access_key_is_secondary = true
    retention_in_days                       = 6
  }



  tags = {
    environment = "production"
  }
}
