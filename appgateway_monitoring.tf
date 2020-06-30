// Required Variables
//**********************************************************************************************
variable "action_group_id" {
  type        = string
  description = "(Required) The ID of the Action Group"
}
//**********************************************************************************************
 
 
// Optional Variables
//**********************************************************************************************
variable "monitoring_enabled" {
  type        = bool
  description = "Enable or Disable resource monitoring and alerting"
  default     = true
}
 
### Metric Alerts ###
variable "metric_alert_enabled" {
  type        = bool
  description = "(Optional) Should this Metric Alert be enabled?"
  default     = true
}
variable "auto_mitigate" {
  type        = bool
  description = "(Optional) Should the alerts in this Metric Alert be auto resolved?"
  default     = true
}
 
# Inputs for creation Metric Alert along with conditions(critetias)
variable "metric_alerts" {
  type = map(object({
    name        = string
    description = string
    frequency   = string
    window_size = string
    severity    = number
    metric_criterias = map(object({
      metric_namespace = string
      metric_name      = string
      aggregation      = string
      operator         = string
      threshold        = number
      dimension = map(object({
        name     = string
        operator = string
        values   = list(string)
      }))
    }))
  }))
  description = "(Required) One or more criteria blocks"
  default = {
    # App Gatewway Number of unhealthy backend hosts
    UnhealthyHostCount = {
      name        = "appgateway_UnhealthyHostCount"
      description = "Application Gateway     contains unhealthy hosts"
      frequency   = "PT1M"
      window_size = "PT5M"
      severity    = 0
      metric_criterias = {
        criteria1 = {
          metric_namespace = "Microsoft.Network/applicationGateways"
          metric_name      = "UnhealthyHostCount"
          aggregation      = "Average"
          operator         = "GreaterThan"
          threshold        = 0
          dimension = {
            BackendSettingsPool = {
              name     = "BackendSettingsPool"
              operator = "Include"
              values   = ["*"]
            }
          }
        }
      }
    },
    # Count of failed requests that Application Gateway has served
    FailedRequests = {
      name        = "appgateway_FailedRequests"
      description = "Application Gateway requests not processed"
      frequency   = "PT5M"
      window_size = "PT30M"
      severity    = 3
      metric_criterias = {
        criteria1 = {
          metric_namespace = "Microsoft.Network/applicationGateways"
          metric_name      = "FailedRequests"
          aggregation      = "Total"
          operator         = "GreaterThan"
          threshold        = 100
          dimension = {
            BackendSettingsPool = {
              name     = "BackendSettingsPool"
              operator = "Include"
              values   = ["*"]
            }
          }
        }
      }
    }
  }
}
 
### Activity Log Alerts ###
variable "log_alerts" {
  type = map(object({
    name        = string
    description = string
    log_criterias = object({
      category       = string
      operation_name = string
      level          = string
      status         = string
      sub_status     = string
    })
  }))
  description = "(Required) A criteria block"
  default = {
    appgateway_delete = {
      name        = "appgateway_delete"
      description = "Application Gateway deleted"
      log_criterias = {
        category       = "Administrative"
        operation_name = "Microsoft.Network/applicationGateways/delete"
        level          = null
        status         = null
        sub_status     = null
      }
    }
  }
}
//**********************************************************************************************
 
// Set up Azure Monitor Alert For Metrics
//**********************************************************************************************
resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each            = var.monitoring_enabled ? var.metric_alerts : {}
  name                = each.value.name
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.application_gateway.id]
  description         = each.value.description
 
  enabled       = var.metric_alert_enabled
  auto_mitigate = var.auto_mitigate
  frequency     = each.value.frequency
  severity      = each.value.severity
  window_size   = each.value.window_size
 
  dynamic "criteria" {
    for_each = each.value.metric_criterias
    content {
      metric_namespace = criteria.value.metric_namespace
      metric_name      = criteria.value.metric_name
      aggregation      = criteria.value.aggregation
      operator         = criteria.value.operator
      threshold        = criteria.value.threshold
 
      dynamic "dimension" {
        for_each = criteria.value.dimension
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }
 
  action {
    action_group_id = var.action_group_id
  }
 
  tags = var.tags
 
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//****************************************************************************************
 
 
// Set up Azure Monitor Alert For Activity Logs
//****************************************************************************************
resource "azurerm_monitor_activity_log_alert" "log_alert" {
  for_each            = var.monitoring_enabled ? var.log_alerts : {}
  name                = each.value.name
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_gateway.application_gateway.id]
  description         = each.value.description
 
  criteria {
    resource_id    = azurerm_application_gateway.application_gateway.id
    category       = each.value.log_criterias.category
    operation_name = each.value.log_criterias.operation_name
    level          = each.value.log_criterias.level
    status         = each.value.log_criterias.status
    sub_status     = each.value.log_criterias.sub_status
  }
 
  action {
    action_group_id = var.action_group_id
  }
 
  tags = var.tags
 
  timeouts {
    create = local.timeout_duration
    delete = local.timeout_duration
  }
}
//****************************************************************************************