# TODO: lifecycle [ignore_changes = tags], Subnet: address_prefix => address_prefixs 

# Configurations
https://docs.microsoft.com/en-us/azure/application-gateway/configuration-overview#size-of-the-subnet
1. Subnet settings: dedicated subnet without route tables
1. NSG settings

# FAQs
https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq


1. waf_configuration
dynamic "disabled_rule_group" { 
	for_each = var.waf_configuration.disabled_rule_group
	content {
		rule_group_name = list(string)
        rules = list(string)
	}
}
    file_upload_limit_mb = number #(Optional) The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB. Defaults to 100MB
         request_body_check = bool #(Optional) Is Request Body Inspection enabled? Defaults to true
          max_request_body_size_kb = number #(Optional) The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB. Defaults to 128KB
          exclusion = { #(Optional) one or more exclusion blocks as defined below
              match_variable = string
              selector_match_operator = sting
              selector = string
          }
}          

2. backend_http_settings
    authentication_certificate = backend_http_settings.value.authentication_certificate
	trusted_root_certificate_names = backend_http_settings.value.trusted_root_certificate_names
	connection_draining = backend_http_settings.value.connection_draining

3. Enable HTTP2: 
    HTTP/2 protocol support is available to clients that connect to application gateway listeners only. The communication to back-end server pools is over HTTP/1.1. By default, HTTP/2 support is disabled.

4. custom_error_configuratin

5. http_listener


- WAF: Prevention / Detection ? 
- frontend_ip_configuration: Creating Public only configuration isn't supported
- Backend: Default=AKS AKS Ingress controller configuration should be done from AKS side only.
- Ruting rules: NA for AKS
- HTTP2 enable: Pending
- Listeners: Basic/Multi-site
- Redirect Configurations
- Private IP address for apg conf
-  




