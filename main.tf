terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.101.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "aa2964d9-daf0-4630-81d4-7a9e8888139e"
  client_id       = "ad90b200-90f0-4909-b4a5-922906995858"
  client_secret   = "taz8Q~jNv3wE0tV9Wu5IMImLO98gEtnF36eldbQ9"
  tenant_id       = "d1852839-7394-4b87-9f84-c6654e3cd292"
  features {}
}
resource "azurerm_resource_group" "app-grp" {
  name     = "appgrp"
  location = "North Europe"
}

resource "azurerm_virtual_network" "gcboyz-app" {
  name                = "gcboysvnet"
  location            = "North Europe"
  resource_group_name = "appgrp"
  address_space       = ["10.0.0.0/16"]
  
  subnet {
    name           = "intsubnet"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "pbfsubnet"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.example.id
  }
}

resource "azurerm_network_interface" "AppVM01-nic" {
  name                = "AppVM01-nic"
  location            = "North Europe"
  resource_group_name = "appgrp"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.intsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "App-VM" {
  name                = "AppVM01"
  resource_group_name = "appgrp"
  location            = "North Europe"
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.AppVM01-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

