/*
# Bastion Host
# Bastion Public IP
resource "azurerm_public_ip" "bastion_ip" {
  name                = "bastion-ip-${local.name_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  allocation_method   = var.public_ip_allocation_method
  sku                 = var.public_ip_sku
  zones               = var.availability_zones
}

# NSG allowing SSH
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-bastion-${local.name_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# NSG association
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = local.public_subnet_id_list[0]
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux VM for Bastion
resource "azurerm_network_interface" "nic" {
  name                = "bastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = local.public_subnet_id_list[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "bastion" {
  name                = "bastion-${local.name_prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  size           = "Standard_B1s"
  admin_username = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
*/