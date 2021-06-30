resource "azurerm_resource_group" "AKS" {
  name     = "AKS"
  location = "East US 2"
}

resource "azurerm_kubernetes_cluster" "AKS01" {
  name                = "AKS01"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
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
  value = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw
}
