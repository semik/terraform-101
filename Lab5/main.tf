resource "azurerm_resource_group" "main" {
  name     = "rg-${var.application_name}-${var.environment_name}"
  location = var.primary_location
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.application_name}-${var.environment_name}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [var.base_address_space]

}

locals {
  alpha_address_space = cidrsubnet(var.base_address_space, 2, 0)
  beta_address_space  = cidrsubnet(var.base_address_space, 2, 1)
  gamma_address_space = cidrsubnet(var.base_address_space, 2, 2)
  delta_address_space = cidrsubnet(var.base_address_space, 2, 3)
}

resource "azurerm_subnet" "alpha" {
  name                 = "snet-alpha"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.alpha_address_space]
}
resource "azurerm_subnet" "beta" {
  name                 = "snet-beta"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.beta_address_space]
}
resource "azurerm_subnet" "gamma" {
  name                 = "snet-gamma"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.gamma_address_space]
}
resource "azurerm_subnet" "delta" {
  name                 = "snet-delta"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [local.delta_address_space]
}

resource "azurerm_network_security_group" "remote_access" {
  name                = "nsg-${var.application_name}-${var.environment_name}-remote-access"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "ssh-ipv4"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["45.140.240.11/32", "${chomp(data.http.my_ipv4.response_body)}/32"]
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "ssh-ipv6"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = ["${chomp(data.http.my_ipv6.response_body)}/128"]
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "alpha_remote_access" {
  subnet_id                 = azurerm_subnet.alpha.id
  network_security_group_id = azurerm_network_security_group.remote_access.id
}

data "http" "my_ipv4" {
  url = "https://api.ipify.org/"
}

data "http" "my_ipv6" {
  url = "https://api6.ipify.org/"
}