// This Terraform configuration file creates an Azure Resource Group.
# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "attomic" {
  name     = "attomic-resources"
  location = "East US"  # Change to your desired location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "attomic" {
  name                = "attomic-network"
  resource_group_name = azurerm_resource_group.attomic.name
  location            = azurerm_resource_group.attomic.location
  address_space       = ["10.0.0.0/16"]
}
# Create a subnet within the virtual network
resource "azurerm_subnet" "attomic" {
  name                 = "attomic-subnet"
  resource_group_name  = azurerm_resource_group.attomic.name
  virtual_network_name = azurerm_virtual_network.attomic.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_linux_virtual_machine" "attomic" {
  name                = "attomic-vm"
  resource_group_name = azurerm_resource_group.attomic.name
  location            = azurerm_resource_group.attomic.location
  size                = "Standard_B1s"  # Basic tier - widely available, cost-effective
  # Alternative sizes: "Standard_B2s", "Standard_D2s_v3", "Standard_E2s_v3"
  admin_username      = "adminuser"
  
  disable_password_authentication = false
  admin_password                  = "P@ssw0rd1234!"

  network_interface_ids = [
    azurerm_network_interface.attomic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
# Create a network interface for the virtual machine
resource "azurerm_network_interface" "attomic" {
  name                = "attomic-nic"
  location            = azurerm_resource_group.attomic.location
  resource_group_name = azurerm_resource_group.attomic.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.attomic.id
    private_ip_address_allocation = "Dynamic"
  }
}
# # Output the resource group name
# output "resource_group_name" {
#   value = azurerm_resource_group.attomic.name
# }
# # Output the virtual network name
# output "virtual_network_name" {
#   value = azurerm_virtual_network.attomic.name
# }
# # Output the subnet name
# output "subnet_name" {  
#   value = azurerm_subnet.attomic.name
# }
# # Output the virtual machine name
# output "virtual_machine_name" {
#   value = azurerm_linux_virtual_machine.attomic.name
# }
# # Output the network interface name
# output "network_interface_name" {
#   value = azurerm_network_interface.attomic.name
# }
# Apply the configuration
# Run the following command to apply the configuration:
//terraform apply -auto-approve
# This will create the resource group, virtual network, subnet, and virtual machine in Azure.       
# Make sure you have the Azure CLI installed and authenticated before running this command.
# You can also use the `terraform plan` command to see what changes will be made before
# applying the configuration.
# Note: Ensure that you have the necessary permissions in your Azure account to create these resources.
# If you need to destroy the resources created by this configuration, you can run:
//terraform destroy -auto-approve
# This will remove all the resources created by the Terraform configuration.
# Make sure to run this command only if you want to delete the resources, as it will
# permanently delete them.
# Note: The above configuration is a basic attomic. You may need to adjust the parameters
# such as resource names, locations, and sizes according to your requirements.
# Ensure you have the Azure CLI installed and authenticated before running the commands.
# You can also use the `terraform plan` command to see what changes will be made before
# applying the configuration.