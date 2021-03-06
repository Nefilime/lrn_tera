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
  name                         = "sqlsrvazsql"
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
  name                     = "aztestvv001"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_sql_database" "db" {
  name                = "azdb001"
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
    environment = "TestEnv"
  }
}

# Create private endpoint
data "azurerm_resource_group" "ctdev" {
  name = "ctdev"
}

data "azurerm_virtual_network" "vnet" {
  name                = "UbuntusrvVNET"
  resource_group_name = data.azurerm_resource_group.ctdev.name
}

data "azurerm_subnet" "subnet" {
  name                 = "UbuntusrvSubnet"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.ctdev.name
}

output "subnet_name" {
  value = data.azurerm_subnet.subnet.id
}


  resource "azurerm_private_endpoint" "example" {
    name                = "dbendpoint"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    subnet_id           = data.azurerm_subnet.subnet.id
    depends_on = [azurerm_sql_server.sqlsrv]

    private_service_connection {
      name                              = "db"
      is_manual_connection              = false
      private_connection_resource_id = azurerm_sql_server.sqlsrv.id
      subresource_names = ["sqlServer"]
    }
  }


  resource "azurerm_private_dns_zone" "dnszone" {
    name                = "ct.loc"
    resource_group_name = data.azurerm_resource_group.ctdev.name
  }

  resource "azurerm_private_dns_a_record" "example" {
    name                = azurerm_sql_server.sqlsrv.name
    zone_name           = azurerm_private_dns_zone.dnszone.name
    resource_group_name = data.azurerm_resource_group.ctdev.name
    ttl                 = 300
    records             = ["10.0.0.5"]
  }

# Link to private DNS zone
  resource "azurerm_private_dns_zone_virtual_network_link" "linktovnet" {
  name                  = "linkto"
  resource_group_name   = data.azurerm_resource_group.ctdev.name
  private_dns_zone_name = azurerm_private_dns_zone.dnszone.name
  virtual_network_id    = data.azurerm_virtual_network.vnet.id
}
