terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.61.0"
    }
  }
  backend "azurerm" {
    storage_account_name = "shell21"
    container_name       = "terraform"
    key                  = "terraform.tfstate"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    #access_key = var.key
}
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks" {
  name     = "AKS"
  location = "East US 2"
}

resource "azurerm_kubernetes_cluster" "aks01" {
  name                = "AKS01"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "aks01"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks01.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks01.kube_config_raw
  sensitive = true
}
