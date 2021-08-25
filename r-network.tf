// Public IP for Application Gateway
//**********************************************************************************************
module "public_ip" {
  source = "git@github.com:prashantshetage/terraform-azurerm-public-ip.git?ref=development"

  resource_group_name = var.resource_group_name
  location            = var.location

  name              = local.ip_name
  sku               = var.ip_sku
  allocation_method = each.value.allocation_method
  domain_name_label = local.ip_label
  resource_tags     = var.tags
  deployment_tags   = var.additional_tags
}

//**********************************************************************************************


//**********************************************************************************************
/* resource "azurerm_public_ip" "ip" {
  name                    = local.ip_name
  resource_group_name     = var.resource_group_name
  location                = var.location
  allocation_method       = var.ip_allocation_method
  sku                     = var.ip_sku
  ip_version              = var.ip_version
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  domain_name_label       = local.ip_label
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

resource "azurerm_public_ip" "ip" {
  location            = var.location
  name                = local.ip_name
  resource_group_name = var.resource_group_name
  ## Default value to "Standard" sku because "Basic" is not compatible
  ## with Application Gateway v2
  sku = var.ip_sku
  ## Default value to "Static" allocation because can't switch to "Dynamic"
  ## with IP sku to "Standard"
  allocation_method = var.ip_allocation_method

  domain_name_label = local.ip_label

  tags = merge(local.default_tags, var.ip_tags)
} */
