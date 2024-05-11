data "azurerm_ssh_public_key" "vm_key" {
  name                = "vm_key"
  resource_group_name = "ore-test"
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "machine${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  custom_data = filebase64("customdata.tpl")

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.azurerm_ssh_public_key.vm_key.public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

output "vm_public_ip" {
  description = "The public ip address of the virtual machine created"
  value       = ["${azurerm_linux_virtual_machine.vm.*.public_ip_address}"]
}
