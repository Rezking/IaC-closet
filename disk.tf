resource "azurerm_managed_disk" "data_disk" {
  count                = var.disk_count
  name                 = "data_disk_${count.index}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_virtual_machine.vm[count.index].id
  lun                = 0
  caching            = "ReadWrite"
}
