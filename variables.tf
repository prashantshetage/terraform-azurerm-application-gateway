// Required Variables
//**********************************************************************************************
variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  type        = string
}
variable "oms_id" {
  type        = string
  description = "(Required) The id of your OMS workspace to send your logs to."
}
variable "tags" {
  description = "(Required) A mapping of tags to assign to the resource."
  type        = map
}

# Gateway Subnet
variable "virtual_network_name" {
  type        = string
  description = "(Required) The name of the virtual network to which to attach the subnet"
}

variable "address_prefix" {
  type        = string
  description = "(Required) The address prefixes to use for the subnet."
}
//**********************************************************************************************


// Optional Variables
//**********************************************************************************************
# Application Gateway
variable "sku" {
  description = "(Optional)"
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
  default = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = null
  }
}
variable "autoscale_configurations" {
  description = "(Optional) Auto scaling threashold for this Application Gateway"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = {
    min_capacity = 2
    max_capacity = 5
  }
}
variable "zones" {
  type        = list(string)
  description = "(Optional) A collection of availability zones to spread the Application Gateway over"
  default     = ["1", "2", "3"]
}
variable "enable_http2" {
  type        = bool
  description = "(Optional) Is HTTP2 enabled on the application gateway resource?"
  default     = false
}
variable "redirect_configurations" {
  // TODO: change type to Object only if it doestn't support multiple redirections
  description = "(Optional)"
  type = map(object({
    name                 = string #(Required) Unique name of the redirect configuration block
    redirect_type        = string #(Required) The type of redirect. Possible values are Permanent, Temporary, Found and SeeOther
    target_listener_name = string #(Optional) The name of the listener to redirect to. Cannot be set if target_url is set
    target_url           = string #(Optional) The Url to redirect the request to. Cannot be set if target_listener_name is set
    include_path         = bool   #Defaults to false
    include_query_string = bool   #Defaults to false
  }))
  default = {}
}
variable "gateway_ip_configurations" {
  description = "(Required) One or more gateway_ip_configuration blocks"
  type = map(object({
    name = string
    //  subnet_id = string # Creating inside module
  }))
  default = {
    gw-ip-conf1 = {
      name = "gw-ip-conf1"
    }
  }
}
variable "frontend_ports" {
  description = "(Required) One or more frontend_port blocks"
  type = map(object({
    name = string
    port = number
  }))
  default = {
    frontend-port1 = {
      name = "frontend-port1"
      port = 80
    }
  }
}
variable "frontend_ip_configurations" {
  description = "(Required) One or more frontend_ip_configuration blocks"
  type = map(object({
    name                          = string
    subnet_id                     = string
    public_ip_address_id          = string
    private_ip_address            = string
    private_ip_address_allocation = string
  }))
  default = {
    public = {
      name                          = "public"
      subnet_id                     = null
      public_ip_address_id          = ""
      private_ip_address            = null
      private_ip_address_allocation = null
    },
    private = {
      name                          = "private"
      subnet_id                     = ""
      public_ip_address_id          = null
      private_ip_address            = ""
      private_ip_address_allocation = "Static"
    }
  }
}
variable "backend_address_pools" {
  description = "(Required) One or more backend_address_pool blocks"
  type = map(object({
    name         = string
    fqdns        = list(string)
    ip_addresses = list(string)
  }))
  default = {
    backend-pool1 = {
      name         = "backend-pool1"
      fqdns        = null
      ip_addresses = null
    }
  }
}
variable "backend_http_settings" {
  description = "(Required)"
  type = map(object({
    cookie_based_affinity               = string
    affinity_cookie_name                = string
    name                                = string
    path                                = string
    port                                = number
    probe_name                          = string
    protocol                            = string
    request_timeout                     = number # default=20
    host_name                           = string
    pick_host_name_from_backend_address = bool
    trusted_root_certificate_names      = list(string)
    authentication_certificate = map(object({
      name = string
    }))
    connection_draining = object({
      enabled           = bool
      drain_timeout_sec = number
    })
  }))
  default = {
    backend-http-set1 = {
      cookie_based_affinity               = "Disabled"
      affinity_cookie_name                = null
      name                                = "backend-http-set1"
      path                                = null
      port                                = 80
      protocol                            = "Http"
      request_timeout                     = 20
      probe_name                          = null
      host_name                           = null
      pick_host_name_from_backend_address = false
      authentication_certificate          = {}
      trusted_root_certificate_names      = null
      connection_draining = {
        enabled           = false
        drain_timeout_sec = 60
      }
    }
  }
}
variable "http_listeners" {
  description = "(Required) One or more http_listener blocks"
  type = map(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    host_name                      = string # For multi-site/PathBasedRouting routing to backends
    require_sni                    = bool   # Defult=false
    ssl_certificate_name           = string # Optional
    custom_error_configuration = map(object({
      status_code           = string
      custom_error_page_url = string
    }))
  }))
  default = {
    listener1 = {
      name                           = "listener1"
      frontend_ip_configuration_name = "private"
      frontend_port_name             = "frontend-port1"
      protocol                       = "Http"
      host_name                      = null
      require_sni                    = false
      ssl_certificate_name           = null
      custom_error_configuration     = {}
    }
  }
}
variable "request_routing_rules" {
  description = "(Required) One or more request_routing_rule blocks"
  type = map(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = string # Optional
    backend_http_settings_name  = string # Optional
    redirect_configuration_name = string # Optional
    rewrite_rule_set_name       = string # Optional
    url_path_map_name           = string # Optional
  }))
  default = {
    req-route-rule1 = {
      name                        = "req-route-rule1"
      rule_type                   = "Basic"
      http_listener_name          = "listener1"
      backend_address_pool_name   = "backend-pool1"
      backend_http_settings_name  = "backend-http-set1"
      redirect_configuration_name = null
      rewrite_rule_set_name       = null
      url_path_map_name           = null
    }
  }
}

# Web Application Firewall
variable "waf_configuration" {
  description = "(Required) Configuration block for WAF"
  type = object({
    enabled                  = bool
    firewall_mode            = string
    rule_set_type            = string
    rule_set_version         = string
    file_upload_limit_mb     = number
    max_request_body_size_kb = number
    request_body_check       = bool
    disabled_rule_group = map(object({ # (Optional) one or more disabled_rule_group blocks
      rule_group_name = list(string)
      rules           = list(string)
    }))
    exclusion = map(object({ #(Optional) one or more exclusion blocks as defined below
      match_variable          = string
      selector_match_operator = string
      selector                = string
    }))
  })
  default = {
    enabled                  = true
    firewall_mode            = "Detection"
    rule_set_type            = "OWASP"
    rule_set_version         = "3.1"
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
    request_body_check       = true
    disabled_rule_group      = {}
    exclusion                = {}
  }
}

# Gateway NSG 
variable "security_rules" {
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
    description                = string
  }))
  description = "(Required) NSG rules for Private Application Gateway"
  default = {
    GatewayManager = {
      name                       = "GatewayManager"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "tcp"
      source_port_range          = "*"
      destination_port_range     = "65200-65535"
      source_address_prefix      = "GatewayManager"
      destination_address_prefix = "*"
      description                = "Azure infrastructure communication"
    },
    AzureLoadBalancer = {
      name                       = "AzureLoadBalancer"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "AzureLoadBalancer"
      destination_address_prefix = "*"
      description                = "Azure Load Balancer"
    },
    DenyInternet = {
      name                       = "DenyInternet"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "Internet"
      destination_address_prefix = "*"
      description                = "Deny Internet raffic"
    },
    VirtualNetwork = {
      name                       = "VirtualNetwork"
      priority                   = 130
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "tcp"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = "*"
      description                = "Unblcok access to Private IP address"
    }
  }
}

# Gateway Public IP
variable "pip_zones" {
  type        = list(string)
  description = "(Optional) A collection containing the availability zone to allocate the Public IP in"
  default     = []
}
variable "pip_sku" {
  type        = string
  description = "(Optional) The SKU of the Public IP"
  default     = "standard"
}
variable "allocation_method" {
  type        = string
  description = "(Optional) Defines the allocation method for this IP address"
  default     = "Static"
}
variable "ip_version" {
  type        = string
  description = "(Optional) The IP Version to use, IPv6 or IPv4"
  default     = "IPv4"
}
variable "idle_timeout_in_minutes" {
  type        = number
  description = "(Optional) Specifies the timeout for the TCP idle connection"
  default     = 15
}
variable "public_ip_prefix_id" {
  type        = string
  description = " - (Optional) If specified then public IP address allocated will be provided from the public IP prefix resource"
  default     = null
}
variable "domain_name_label" {
  type        = string
  description = "(Optional) Label for the Domain Name. Will be used to make up the FQDN"
  default     = null
}
variable "reverse_fqdn" {
  type        = string
  description = "(Optional) A fully qualified domain name that resolves to this public IP address"
  default     = null
}

# Diagnostic Settings
variable "diagnostics" {
  description = "(Optional) Diagnostic settings for those resources that support it."
  type        = object({ logs = list(string), metrics = list(string) })
  default = {
    logs    = ["ApplicationGatewayAccessLog", "ApplicationGatewayPerformanceLog", "ApplicationGatewayFirewallLog"]
    metrics = ["AllMetrics"]
  }
}
//**********************************************************************************************


// Local Values
//**********************************************************************************************
locals {
  timeout_duration            = "1h"
  timeout_duration_appgateway = "3h"
  appgateway_name             = "appgw-${var.env}-${var.app_name}"
  subnet_name                 = "vnet-subnet-${var.env}-${var.app_name}"
  nsg_name                    = "nsg-appgw_subnet-${var.env}-${var.app_name}-network"
  pip_name                    = "appgw-vnet-${var.env}-${var.app_name}"
}
//**********************************************************************************************