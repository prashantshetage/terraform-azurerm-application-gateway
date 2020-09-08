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
  zones                   = var.pip_zones

  public_ip_prefix_id = var.public_ip_prefix_id

  tags       = merge(var.resource_tags, var.deployment_tags)
  depends_on = [var.it_depends_on]

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


/* // Route table
//**********************************************************************************************
resource "azurerm_route_table" "appgw_route_table" {
  name                          = "rt-appgw-default"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = true
 
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************
 
 
// Adds default internet route to app gateway route table
//**********************************************************************************************
resource "azurerm_route" "appgw_internet_route" {
  name                = "appgw_internet_route"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.appgw_route_table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "Internet"
 
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************
 
 
// Adds hub route to app gateway route table
//**********************************************************************************************
resource "azurerm_route" "appgw_hub_route" {
  name                = "appgw_hub_route"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.appgw_route_table.name
  address_prefix      = "10.0.0.0/8"
  next_hop_type       = "VirtualNetworkGateway"
 
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************
 
 
// Associates app gateway subnet with route table
//**********************************************************************************************
resource "azurerm_subnet_route_table_association" "appgw_rt_associate" {
  subnet_id      = azurerm_subnet.appgateway.id
  route_table_id = azurerm_route_table.appgw_route_table.id
 
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************
*/

// Subnet for Application Gateway
//**********************************************************************************************
resource "azurerm_subnet" "appgateway" {
  name                                           = local.subnet_name
  resource_group_name                            = var.resource_group_name
  virtual_network_name                           = var.virtual_network_name
  address_prefixes                               = var.address_prefixes
  service_endpoints                              = var.service_endpoints
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
  enforce_private_link_service_network_policies  = var.enforce_private_link_service_network_policies

  depends_on = [var.it_depends_on]

  /* lifecycle {
    ignore_changes = [
    ]
  }*/

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

  depends_on = [var.it_depends_on]

  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//**********************************************************************************************