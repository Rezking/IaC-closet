#create vnets
resource "azurerm_virtual_network" "vnet" {
  count               = var.vnet_count
  name                = "${var.vnet_name}-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [element(var.vnet_address_space, count.index)]
}

resource "azurerm_subnet" "subnet" {
  count                = var.vnet_count
  name                 = "subnet-${count.index}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = element(azurerm_virtual_network.vnet.*.name, count.index)
  address_prefixes     = var.subnet_address_space[count.index]
}

#create vnet peering
resource "azurerm_virtual_network_peering" "peering" {
  count                        = var.vnet_count
  name                         = "peering-to-${element(azurerm_virtual_network.vnet.*.name, 1 - count.index)}"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = element(azurerm_virtual_network.vnet.*.name, count.index)
  remote_virtual_network_id    = element(azurerm_virtual_network.vnet.*.id, 1 - count.index)
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_network_interface" "nic" {
  count               = var.vm_count
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "vm_ip"
    subnet_id                     = azurerm_subnet.subnet[count.index].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nic_ip[count.index].id
  }
}

resource "azurerm_public_ip" "nic_ip" {
  count               = var.vm_count
  name                = "public_ip${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = "jenkins_8080"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow8080"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "example" {
  count                     = var.vnet_count
  subnet_id                 = azurerm_subnet.subnet[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}