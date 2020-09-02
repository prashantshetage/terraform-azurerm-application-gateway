// Application Gateway
resource "azurerm_application_gateway" "application_gateway" {
  name                = local.appgateway_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.sku.name == "WAF_v2" || var.sku.name == "Standard_v2" ? var.zones : null
  enable_http2        = var.enable_http2

  sku {
    name     = var.sku.name
    tier     = var.sku.tier
    capacity = var.sku.capacity
  }

  autoscale_configuration {
    min_capacity = var.autoscale_configurations.min_capacity
    max_capacity = var.autoscale_configurations.max_capacity
  }

  dynamic "gateway_ip_configuration" {
    for_each = var.gateway_ip_configurations
    content {
      name      = "${local.appgateway_name}-${gateway_ip_configuration.value.name}"
      subnet_id = azurerm_subnet.appgateway.id
    }
  }

  dynamic "frontend_port" {
    for_each = var.frontend_ports
    content {
      name = "${local.appgateway_name}-${frontend_port.value.name}"
      port = frontend_port.value.port
    }
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations
    content {
      name                          = "${local.appgateway_name}-${frontend_ip_configuration.value.name}"
      subnet_id                     = frontend_ip_configuration.value.subnet_id == "" ? azurerm_subnet.appgateway.id : null
      private_ip_address            = frontend_ip_configuration.value.private_ip_address == "" ? cidrhost(element(var.address_prefixes, 0), 20) : null
      public_ip_address_id          = frontend_ip_configuration.value.public_ip_address_id == "" ? azurerm_public_ip.public_ip.id : null
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools
    content {
      name         = "${local.appgateway_name}-${backend_address_pool.value.name}"
      fqdns        = backend_address_pool.value.fqdns != [] ? backend_address_pool.value.fqdns : null
      ip_addresses = backend_address_pool.value.ip_addresses != [] ? backend_address_pool.value.ip_addresses : null
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings
    content {
      name                                = "${local.appgateway_name}-${backend_http_settings.value.name}"
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      affinity_cookie_name                = backend_http_settings.value.affinity_cookie_name
      path                                = backend_http_settings.value.path
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = backend_http_settings.value.probe_name
      host_name                           = backend_http_settings.value.pick_host_name_from_backend_address ? backend_http_settings.value.host_name : null
      pick_host_name_from_backend_address = backend_http_settings.value.pick_host_name_from_backend_address ? true : false
      trusted_root_certificate_names      = backend_http_settings.value.trusted_root_certificate_names

      dynamic "authentication_certificate" {
        for_each = backend_http_settings.value.authentication_certificate
        content {
          name = authentication_certificate.value.name
        }
      }
      connection_draining {
        enabled           = backend_http_settings.value.connection_draining.enabled
        drain_timeout_sec = backend_http_settings.value.connection_draining.drain_timeout_sec
      }
    }
  }

  dynamic "http_listener" {
    for_each = var.http_listeners
    content {
      name                           = "${local.appgateway_name}-${http_listener.value.name}"
      frontend_ip_configuration_name = "${local.appgateway_name}-${http_listener.value.frontend_ip_configuration_name}"
      frontend_port_name             = "${local.appgateway_name}-${http_listener.value.frontend_port_name}"
      protocol                       = http_listener.value.protocol
      host_name                      = http_listener.value.host_name
      ssl_certificate_name           = http_listener.value.ssl_certificate_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configuration
        content {
          status_code           = custom_error_configuration.value.status_code
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules
    content {
      name                        = "${local.appgateway_name}-${request_routing_rule.value.name}"
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = "${local.appgateway_name}-${request_routing_rule.value.http_listener_name}"
      backend_address_pool_name   = "${local.appgateway_name}-${request_routing_rule.value.backend_address_pool_name}"
      backend_http_settings_name  = "${local.appgateway_name}-${request_routing_rule.value.backend_http_settings_name}"
      redirect_configuration_name = request_routing_rule.value.redirect_configuration_name
      rewrite_rule_set_name       = request_routing_rule.value.rewrite_rule_set_name
      url_path_map_name           = request_routing_rule.value.url_path_map_name
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations
    content {
      name                 = "${local.appgateway_name}-${redirect_configuration.value.name}"
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = "${local.appgateway_name}-${redirect_configuration.value.target_listener_name}"
      target_url           = redirect_configuration.value.target_url
      include_path         = redirect_configuration.value.include_path
      include_query_string = redirect_configuration.value.include_query_string
    }
  }

  # WAF Configurations
  waf_configuration {
    enabled                  = var.waf_configuration.enabled
    firewall_mode            = var.waf_configuration.firewall_mode
    rule_set_type            = var.waf_configuration.rule_set_type
    rule_set_version         = var.waf_configuration.rule_set_version
    file_upload_limit_mb     = var.waf_configuration.file_upload_limit_mb
    max_request_body_size_kb = var.waf_configuration.max_request_body_size_kb
    request_body_check       = var.waf_configuration.request_body_check

    dynamic "disabled_rule_group" {
      for_each = var.waf_configuration.disabled_rule_group
      content {
        rule_group_name = disabled_rule_group.value.rule_group_name
        rules           = disabled_rule_group.value.rules
      }
    }

    dynamic "exclusion" {
      for_each = var.waf_configuration.exclusion
      content {
        match_variable          = waf_configuration.exclusion.value.match_variable
        selector_match_operator = waf_configuration.exclusion.value.selector_match_operator
        selector                = waf_configuration.exclusion.value.selector
      }
    }
  }

  tags       = merge(var.resource_tags, var.deployment_tags)
  depends_on = [var.it_depends_on]


  timeouts {
    create = local.timeout_duration_appgateway
    delete = local.timeout_duration_appgateway
  }

  #depends_on = [azurerm_subnet_route_table_association.appgw_rt_associate]

  lifecycle {
    ignore_changes = [
      backend_address_pool,
      backend_http_settings,
      frontend_port,
      http_listener,
      probe,
      request_routing_rule,
      redirect_configuration,
      url_path_map,
      ssl_certificate,
      tags,
    ]
  }
}





 