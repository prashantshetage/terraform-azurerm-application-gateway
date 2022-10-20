// Application Gateway outputs
//**********************************************************************************************
output "appgateway" {
  value = azurerm_application_gateway.application_gateway
}

output "appgw_subnet" {
  value = azurerm_subnet.appgateway
}
//**********************************************************************************************
