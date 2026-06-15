# Create Resource Group 
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Create Vnet 
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

# WebSubnet
resource "azurerm_subnet" "web" {
  name                 = "subnet-web"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.1.0/24"]
}


# BastionSubnet
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = ["10.0.2.0/26"]
}


# NSG
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "http" {
  name                       = "allow-http"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "80"
  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.web.name
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.web.id
}

# NIC
resource "azurerm_network_interface" "vm1" {
  name                = "nic-vm1"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "vm2" {
  name                = "nic-vm2"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
  }
}

#Linux VM1
resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "vm-web-01"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  size           = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm1.id
  ]

#   admin_ssh_key {
#     username   = var.admin_username
#     public_key = file(var.public_key_path)
#   }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  #   custom_data = base64encode(file("${path.module}/scripts/install-nginx.sh"))
}

#Linux VM2
resource "azurerm_linux_virtual_machine" "vm2" {
  name                = "vm-web-02"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  size           = var.vm_size
  admin_username = var.admin_username
  admin_password = var.admin_password

  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.vm2.id]

 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  #   custom_data = base64encode(file("${path.module}/scripts/install-nginx.sh"))
}


# Bastion Public IP
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

# Bastion Host

resource "azurerm_bastion_host" "main" {
  name                = "bastion-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}


# Load Balancer Public IP
resource "azurerm_public_ip" "lb" {
  name                = "pip-lb"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

# Load Balancer
resource "azurerm_lb" "web" {
  name                = "lb-web"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

# Backend Pool
resource "azurerm_lb_backend_address_pool" "web" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "backend-pool"
}


# Associated NIC
resource "azurerm_network_interface_backend_address_pool_association" "vm1" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.vm1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "vm2" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.web.id
  ip_configuration_name   = "internal"
  network_interface_id    = azurerm_network_interface.vm2.id
}


# Health Probe
resource "azurerm_lb_probe" "http" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "http-probe"
  port            = 80
}

# Load balancer Rule
resource "azurerm_lb_rule" "http" {
  loadbalancer_id = azurerm_lb.web.id
  name            = "http-rule"

  protocol      = "Tcp"
  frontend_port = 80
  backend_port  = 80

  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
}


