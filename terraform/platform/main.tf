locals {
  prefix = "fincore-${var.environment}"
}

# --- Resource Group ---

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.prefix}"
  location = var.location

  tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "fincore-idp"
  }
}

# --- Networking ---

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${local.prefix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# --- Container Registry ---

resource "azurerm_container_registry" "main" {
  name                = "acr${replace(local.prefix, "-", "")}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

# --- Log Analytics (for AKS monitoring) ---

resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# --- AKS Cluster ---

resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${local.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = local.prefix

  default_node_pool {
    name           = "default"
    node_count     = var.aks_node_count
    vm_size        = var.aks_vm_size
    vnet_subnet_id = azurerm_subnet.aks.id

    temporary_name_for_rotation = "tempdefault"
  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"
    dns_service_ip = "10.1.0.10"
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
    project     = "fincore-idp"
  }
}

# --- Grant AKS permission to pull from ACR ---

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}
