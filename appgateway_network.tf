// Public IP for Application Gateway
//**********************************************************************************************
resource "azurerm_public_ip" "public_ip" {
  name                    = local.pip_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  allocation_method       = var.allocation_method
  sku                     = var.pip_sku
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = var.domain_name_label
  reverse_fqdn            = var.reverse_fqdn
  #availability_zone       = var.availability_zone azurerm 3.X
  zones               = var.availability_zone
  public_ip_prefix_id = var.public_ip_prefix_id

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************


// Subnet for Application Gateway
//**********************************************************************************************
resource "azurerm_subnet" "appgateway" {
  name                                          = local.subnet_name
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = var.virtual_network_name
  address_prefixes                              = var.address_prefixes
  service_endpoints                             = var.service_endpoints
  private_endpoint_network_policies_enabled     = var.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = var.private_link_service_network_policies_enabled


  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************