// Local Values
//**********************************************************************************************
locals {
  timeout_duration            = var.timeout
  timeout_duration_appgateway = var.appgateway_timeout
  appgateway_name             = var.appgateway_name
  subnet_name                 = "sn-${local.appgateway_name}"
  nsg_name                    = "nsg-${local.appgateway_name}"
  pip_name                    = "pip-${local.appgateway_name}"
}
//**********************************************************************************************