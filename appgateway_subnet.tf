// Subnet for Application Gateway
//**********************************************************************************************
resource "azurerm_subnet" "appgateway" {
  name                 = local.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefix       = var.address_prefix

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************


// Associate subnet to NSG
//**********************************************************************************************
resource "azurerm_subnet_network_security_group_association" "nsg_association_private" {
  subnet_id                 = azurerm_subnet.appgateway.id
  network_security_group_id = azurerm_network_security_group.nsg.id

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************


// Public IP for Application Gateway
//**********************************************************************************************
resource "azurerm_public_ip" "public_ip" {
  name                    = local.pip_name
  resource_group_name     = var.resource_group_name
  location                = var.rg_location
  allocation_method       = var.allocation_method
  sku                     = var.pip_sku
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = var.domain_name_label
  reverse_fqdn            = var.reverse_fqdn
  zones                   = var.pip_zones

  public_ip_prefix_id = var.public_ip_prefix_id

  tags = var.tags

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************