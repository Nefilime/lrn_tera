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
    vm_size    = "Standard_b2s"
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
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks01.kube_config_raw
}
