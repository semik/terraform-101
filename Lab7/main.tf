resource "azapi_resource" "rg" {
  type = "Microsoft.Resources/resourceGroups@2021-04-01"
  name = "rg-${var.application_name}-${var.environment_name}"
  location = var.primary_location

  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
}

data "azapi_client_config" "current" {
}

resource "azapi_resource" "vm_pip" {
  type = "Microsoft.Network/publicIPAddresses@2025-03-01"
  name = "pip-${var.application_name}-${var.environment_name}"
  location = azapi_resource.rg.location
  parent_id = azapi_resource.rg.id

  body = {
    properties = {
      publicIPAllocationMethod = "Static"
    }
    sku = {
      name = "Standard"
    }
  }
}

data "azapi_resource" "network_rg" {
  name      = "rg-network-dev"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}
data "azapi_resource" "vnet" {
  name      = "vnet-network-dev"
  parent_id = data.azapi_resource.network_rg.id
  type      = "Microsoft.Network/virtualNetworks@2024-05-01"
}

data "azapi_resource" "subnet_bravo" {
  name      = "snet-beta"
  parent_id = data.azapi_resource.vnet.id
  type      = "Microsoft.Network/virtualNetworks/subnets@2024-05-01"

  response_export_values = ["name"]
}

resource "azapi_resource" "vm_nic" {
  type = "Microsoft.Network/networkInterfaces@2025-03-01"
  name = "nic-${var.application_name}-${var.environment_name}"
  location = azapi_resource.rg.location
  parent_id = azapi_resource.rg.id

  body = {
    properties = {
      ipConfigurations = [
        {
          name = "public"
          properties = {
            privateIPAllocationMethod = "Dynamic"
            publicIPAddress = {
              id = azapi_resource.vm_pip.id
            }
            subnet = {
              id = data.azapi_resource.subnet_bravo.id
            }
          }
        }
      ]
    }
  }
}

resource "tls_private_key" "vm1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "azapi_resource" "devops_rg" {
  name      = "rg-devops-dev"
  parent_id = "/subscriptions/${data.azapi_client_config.current.subscription_id}"
  type      = "Microsoft.Resources/resourceGroups@2021-04-01"
}
data "azapi_resource" "keyvault" {
  name      = "kv-devops-dev-wavzyr"
  parent_id = data.azapi_resource.devops_rg.id
  type      = "Microsoft.KeyVault/vaults@2025-05-01"
}
resource "azapi_resource" "vm1_ssh_private" {
  type = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  name = "azapivm-ssh-private"
  parent_id = data.azapi_resource.keyvault.id

  body = {
    properties = {
      value = tls_private_key.vm1.private_key_pem
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}
resource "azapi_resource" "vm1_ssh_public" {
  type = "Microsoft.KeyVault/vaults/secrets@2025-05-01"
  name = "azapivm-ssh-public"
  parent_id = data.azapi_resource.keyvault.id

  body = {
    properties = {
      value = tls_private_key.vm1.public_key_openssh
    }
  }
  lifecycle {
    ignore_changes = [location]
  }
}


# https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-terraform
resource "azapi_resource" "vm1" {
  type = "Microsoft.Compute/virtualMachines@2025-04-01"
  name = "vm1-${var.application_name}-${var.environment_name}"
  parent_id = azapi_resource.rg.id
  location = azapi_resource.rg.location

  body = {
    properties = {
      hardwareProfile = {
        vmSize = "Standard_D2s_v3"
      }
      networkProfile = {
        networkInterfaces = [
          {
            id = azapi_resource.vm_nic.id
          }
        ]
      }
      osProfile = {
        adminUsername = "adminuser"
        computerName = "vm1-${var.application_name}-${var.environment_name}"
        linuxConfiguration = {
          ssh = {
            publicKeys = [
              {
                keyData = tls_private_key.vm1.public_key_openssh
                path    = "/home/adminuser/.ssh/authorized_keys"
              }
            ]
          }
        }
      }
      storageProfile = {
        imageReference = {
          publisher = "Canonical"
          offer     = "0001-com-ubuntu-server-jammy"
          sku       = "22_04-lts"
          version   = "latest"
        }
        osDisk = {
          caching              = "ReadWrite"
          createOption         = "FromImage"
          managedDisk = {
            storageAccountType = "Standard_LRS"
          }
        }
      }
    }
  }
}