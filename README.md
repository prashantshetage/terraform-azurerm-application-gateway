# terraform-azurerm-application-gateway

# Application Gateway Firewall Logs
https://docs.microsoft.com/en-us/azure/application-gateway/log-analytics
https://docs.microsoft.com/en-us/azure/web-application-firewall/ag/web-application-firewall-troubleshoot


1. View the raw data in the firewall log 
AzureDiagnostics 
| where ResourceProvider == "MICROSOFT.NETWORK" and Category == "ApplicationGatewayFirewallLog"

2. 
