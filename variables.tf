// Required Variables
//**********************************************************************************************
variable "resource_group_name" {
  type        = string
  description = "(Required) The name of the resource group in which to the Application Gateway should exist"
}

variable "location" {
  type        = string
  description = "(Required) The Azure region where the Application Gateway should exist. Changing this forces a new resource to be created"
}

variable "name" {
  type        = string
  description = "(Required) The name of the Application Gateway"
}

// Required Pre-requisites
# Subnet
variable "virtual_network_name" {
  type        = string
  description = "(Required) The name of the virtual network to which to attach the subnet"
}

variable "address_prefixes" {
  type        = list(string)
  description = "(Required) The address prefixes to use for the subnet"
}


// Optional Variables
//**********************************************************************************************
// Optional Pre-requisites
# Subnet
variable "service_endpoints" {
  type        = list(string)
  description = "(Optional) The list of Service endpoints to associate with the subnet"
  default     = []
}
variable "enforce_private_link_endpoint_network_policies" {
  type        = bool
  description = "(Optional) Enable or Disable network policies for the private link endpoint on the subnet"
  default     = false
}
variable "enforce_private_link_service_network_policies" {
  type        = bool
  description = "(Optional) Enable or Disable network policies for the private link service on the subnet"
  default     = false
}

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
    name = string #(Required) The name of the Frontend Port
    port = number #(Required) The port used for this Frontend Port
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
    name                          = string #(Required) The name of the Frontend IP Configuration
    subnet_id                     = string #(Optional) The ID of the Subnet
    public_ip_address_id          = string #(Optional) The ID of a Public IP Address which the Application Gateway should use
    private_ip_address            = string #(Optional) The Private IP Address to use for the Application Gateway
    private_ip_address_allocation = string #(Optional) The Allocation Method for the Private IP Address. Possible values are Dynamic and Static
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
    name         = string       #(Required) The name of the Backend Address Pool
    fqdns        = list(string) #(Optional) A list of FQDN's which should be part of the Backend Address Pool
    ip_addresses = list(string) #(Optional) A list of IP Addresses which should be part of the Backend Address Pool
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
  description = "(Required) One or more backend_http_settings blocks "
  type = map(object({
    cookie_based_affinity               = string       #(Required) Is Cookie-Based Affinity enabled?
    affinity_cookie_name                = string       #(Optional) The name of the affinity cookie
    name                                = string       #(Required) The name of the Backend HTTP Settings Collection
    path                                = string       #(Optional) The Path which should be used as a prefix for all HTTP requests
    port                                = number       #(Required) The port which should be used for this Backend HTTP Settings Collection
    probe_name                          = string       #(Optional) The name of an associated HTTP Probe
    protocol                            = string       #(Required) The Protocol which should be used. Possible values are Http and Https
    request_timeout                     = number       #(Required) The request timeout in seconds, which must be between 1 and 86400 seconds
    host_name                           = string       #(Optional) Host header to be sent to the backend servers. Cannot be set if pick_host_name_from_backend_address is set to true
    pick_host_name_from_backend_address = bool         #(Optional) Whether host header should be picked from the host name of the backend server
    trusted_root_certificate_names      = list(string) #(Optional) A list of trusted_root_certificate names
    authentication_certificate = map(object({
      name = string #(Required) The Name of the Authentication Certificate to use
      data = string #(Required) The contents of the Authentication Certificate which should be used
    }))
    connection_draining = object({
      enabled           = bool   #(Required) If connection draining is enabled or not
      drain_timeout_sec = number #(Required) The number of seconds connection draining is active. Acceptable values are from 1 second to 3600 seconds
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
    name                           = string       #(Required) The Name of the HTTP Listener
    frontend_ip_configuration_name = string       #(Required) The Name of the Frontend IP Configuration used for this HTTP Listener
    frontend_port_name             = string       #(Required) The Name of the Frontend Port use for this HTTP Listener
    protocol                       = string       #(Required) The Protocol to use for this HTTP Listener. Possible values are Http and Https
    host_name                      = string       #(Optional) The Hostname which should be used for this HTTP Listener
    host_names                     = list(string) #(Optional) A list of Hostname(s) should be used for this HTTP Listener. It allows special wildcard characters
    require_sni                    = bool         #(Optional) Should Server Name Indication be Required? Defaults to false
    ssl_certificate_name           = string       #(Optional) The name of the associated SSL Certificate which should be used for this HTTP Listener
    firewall_policy_id             = string       #(Optional) The ID of the Web Application Firewall Policy which should be used as a HTTP Listener
    custom_error_configuration = map(object({
      status_code           = string #(Required) Status code of the application gateway customer error. Possible values are HttpStatus403 and HttpStatus502
      custom_error_page_url = string #(Required) Error page URL of the application gateway customer error
    }))
  }))
  default = {
    listener1 = {
      name                           = "listener1"
      frontend_ip_configuration_name = "public"
      frontend_port_name             = "frontend-port1"
      protocol                       = "Http"
      host_name                      = null
      host_names                     = null
      require_sni                    = false
      ssl_certificate_name           = null
      firewall_policy_id             = null
      custom_error_configuration     = {}
    }
  }
}
variable "request_routing_rules" {
  description = "(Required) One or more request_routing_rule blocks"
  type = map(object({
    name                        = string #(Required) The Name of this Request Routing Rule
    rule_type                   = string #(Required) The Type of Routing that should be used for this Rule. Possible values are Basic and PathBasedRouting
    http_listener_name          = string #(Required) The Name of the HTTP Listener which should be used for this Routing Rule
    backend_address_pool_name   = string #(Optional) The Name of the Backend Address Pool which should be used for this Routing Rule
    backend_http_settings_name  = string #(Optional) The Name of the Backend HTTP Settings Collection which should be used for this Routing Rule
    redirect_configuration_name = string #(Optional) The Name of the Redirect Configuration which should be used for this Routing Rule
    rewrite_rule_set_name       = string #(Optional) The Name of the Rewrite Rule Set which should be used for this Routing Rule. Only valid for v2 SKUs
    url_path_map_name           = string #(Optional) The Name of the URL Path Map which should be associated with this Routing Rule
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
    enabled                  = bool    #(Required) Is the Web Application Firewall be enabled?
    firewall_mode            = string  #(Required) The Web Application Firewall Mode. Possible values are Detection and Prevention 
    rule_set_type            = string  #(Required) The Type of the Rule Set used for this Web Application Firewall. Currently, only OWASP is supported
    rule_set_version         = string  #(Required) The Version of the Rule Set used for this Web Application Firewall. Possible values are 2.2.9, 3.0, and 3.1
    file_upload_limit_mb     = number  #(Optional) The File Upload Limit in MB. Accepted values are in the range 1MB to 500MB. Defaults to 100MB
    max_request_body_size_kb = number  #(Optional) The Maximum Request Body Size in KB. Accepted values are in the range 1KB to 128KB. Defaults to 128KB
    request_body_check       = bool    #(Optional) Is Request Body Inspection enabled? Defaults to true
    disabled_rule_group = map(object({ # (Optional) one or more disabled_rule_group blocks
      rule_group_name = list(string)   #(Required) The rule group where specific rules should be disabled.
      rules           = list(string)   #(Optional) A list of rules which should be disabled in that group. Disables all rules in the specified group if rules is not specified
    }))
    exclusion = map(object({           #(Optional) one or more exclusion blocks as defined below
      match_variable          = string #(Required) Match variable of the exclusion rule to exclude header, cookie or GET arguments
      selector_match_operator = string #(Optional) Operator which will be used to search in the variable content
      selector                = string #(Optional) String value which will be used for the filter operation
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
    name                                       = string       #(Required) The name of the security rule
    priority                                   = number       #(Required) Specifies the priority of the rule. The value can be between 100 and 4096
    direction                                  = string       #(Required) The direction specifies if rule will be evaluated on incoming or outgoing traffic
    access                                     = string       #(Required) Specifies whether network traffic is allowed or denied
    protocol                                   = string       #(Required) Network protocol this rule applies to. Can be Tcp, Udp, Icmp, or * to match all
    source_port_range                          = string       #(Optional) Source Port or Range. Integer or range between 0 and 65535 or * to match any
    source_port_ranges                         = list(string) #(Optional) List of source ports or port ranges
    destination_port_range                     = string       #(Optional) Destination Port or Range. Integer or range between 0 and 65535 or * to match any
    destination_port_ranges                    = list(string) #(Optional) List of destination ports or port ranges
    source_address_prefix                      = string       #(Optional) CIDR or source IP range or * to match any IP
    source_address_prefixes                    = list(string) #(Optional) List of source address prefixes. Tags may not be used
    destination_address_prefix                 = string       #(Optional) CIDR or destination IP range or * to match any IP
    destination_address_prefixes               = list(string) #(Optional) List of destination address prefixes
    source_application_security_group_ids      = list(string) #(Optional) A List of source Application Security Group ID's
    destination_application_security_group_ids = list(string) #(Optional) A List of destination Application Security Group ID's
    description                                = string       #(Optional) A description for this rule. Restricted to 140 characters
  }))
  description = "(Required) NSG rules for Private Application Gateway"
  default = {
    GatewayManager = {
      name                                       = "GatewayManager"
      priority                                   = 100
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "tcp"
      source_port_range                          = "*"
      source_port_ranges                         = null
      destination_port_range                     = null
      destination_port_ranges                    = ["65200-65535"]
      source_address_prefix                      = "GatewayManager"
      source_address_prefixes                    = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      source_application_security_group_ids      = null
      destination_application_security_group_ids = null
      description                                = "Azure infrastructure communication"
    },
    AzureLoadBalancer = {
      name                                       = "AzureLoadBalancer"
      priority                                   = 110
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "tcp"
      source_port_range                          = "*"
      source_port_ranges                         = null
      destination_port_range                     = null
      destination_port_ranges                    = ["0-65535"]
      source_address_prefix                      = "AzureLoadBalancer"
      source_address_prefixes                    = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      source_application_security_group_ids      = null
      destination_application_security_group_ids = null
      description                                = "Azure Load Balancer"
    },
    allow_http = {
      name                                       = "AllowHTTP"
      priority                                   = 120
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "tcp"
      source_port_range                          = "*"
      source_port_ranges                         = null
      destination_port_range                     = null
      destination_port_ranges                    = ["80"]
      source_address_prefix                      = "0.0.0.0/0"
      source_address_prefixes                    = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      source_application_security_group_ids      = null
      destination_application_security_group_ids = null
      description                                = "HTTP access from anywhere"
    },
    allow_https = {
      name                                       = "AllowHTTPS"
      priority                                   = 130
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "tcp"
      source_port_range                          = "*"
      source_port_ranges                         = null
      destination_port_range                     = null
      destination_port_ranges                    = ["443"]
      source_address_prefix                      = "0.0.0.0/0"
      source_address_prefixes                    = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      source_application_security_group_ids      = null
      destination_application_security_group_ids = null
      description                                = "HTTPS access from anywhere"
    },
    DenyInternet = {
      name                                       = "DenyInternet"
      priority                                   = 140
      direction                                  = "Inbound"
      access                                     = "Deny"
      protocol                                   = "*"
      source_port_range                          = "*"
      source_port_ranges                         = null
      destination_port_range                     = null
      destination_port_ranges                    = ["0-65535"]
      source_address_prefix                      = "Internet"
      source_address_prefixes                    = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      source_application_security_group_ids      = null
      destination_application_security_group_ids = null
      description                                = "Deny Internet raffic"
    },
    VirtualNetwork = {
      name                                       = "VirtualNetwork"
      priority                                   = 150
      direction                                  = "Inbound"
      access                                     = "Allow"
      protocol                                   = "tcp"
      source_port_range                          = "*"
      source_port_ranges                         = null
      destination_port_range                     = null
      destination_port_ranges                    = ["0-65535"]
      source_address_prefix                      = "VirtualNetwork"
      source_address_prefixes                    = null
      destination_address_prefix                 = "*"
      destination_address_prefixes               = null
      source_application_security_group_ids      = null
      destination_application_security_group_ids = null
      description                                = "Unblcok access to Private IP address"
    }
  }
}

# Public IP
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

variable "appgateway_prefix" {
  type        = string
  description = "(Required) Prefix for the appgateway name"
  default     = ""
}

variable "appgateway_suffix" {
  type        = string
  description = "(Optional) Suffix for the appgateway name"
  default     = ""
}

variable "resource_tags" {
  type        = map(string)
  description = "(Optional) Tags for the resources"
  default     = {}
}

variable "deployment_tags" {
  type        = map(string)
  description = "(Optional) Additional Tags for the deployment"
  default     = {}
}

variable "it_depends_on" {
  type        = any
  description = "(Optional) To define explicit dependencies if required"
  default     = null
}

variable "timeout" {
  type        = string
  description = "(Optional) Timeout"
  default     = "30m"
}

variable "appgateway_timeout" {
  type        = string
  description = "(Optional) Timeout"
  default     = "90m"
}
//**********************************************************************************************


// Local Values
//**********************************************************************************************
locals {
  timeout_duration            = var.timeout
  timeout_duration_appgateway = var.appgateway_timeout
  appgateway_name             = "${var.appgateway_prefix}${var.name}${var.appgateway_suffix}"
  subnet_name                 = "${local.appgateway_name}-subnet"
  nsg_name                    = "${local.appgateway_name}-nsg"
  pip_name                    = "${local.appgateway_name}-pip"
}
//**********************************************************************************************