data "azurerm_resource_group" "existing_rg" {
  name = var.resource_group_name
}

data "azurerm_network_interface" "awx" {
  name                = "kplat-awx715"
  resource_group_name = data.azurerm_resource_group.existing_rg.name
}
