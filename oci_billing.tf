# Billing Budget & Alerts

resource "oci_budget_budget" "monthly_spend_alert" {
  compartment_id         = var.oci_tenancy_ocid
  amount                 = 1 # Interpreted in the tenancy's rate-card currency
  reset_period           = "MONTHLY"
  processing_period_type = "MONTH"
  display_name           = "Monthly-1-${var.oci_billing_currency_code}-Spend-Alert"
  description            = "Monthly 1 ${var.oci_billing_currency_code} spend budget across the OCI tenancy"
  target_type            = "COMPARTMENT"
  targets                = [var.oci_tenancy_ocid]
}

resource "oci_budget_alert_rule" "actual_50_percent" {
  budget_id      = oci_budget_budget.monthly_spend_alert.id
  display_name   = "Actual-50-Percent-Alert"
  type           = "ACTUAL"
  threshold      = 50
  threshold_type = "PERCENTAGE"
  recipients     = join(",", var.oci_budget_alert_emails)
  message        = "OCI monthly spend has reached 50% of the 1 ${var.oci_billing_currency_code} budget."
}

resource "oci_budget_alert_rule" "actual_100_percent" {
  budget_id      = oci_budget_budget.monthly_spend_alert.id
  display_name   = "Actual-100-Percent-Alert"
  type           = "ACTUAL"
  threshold      = 100
  threshold_type = "PERCENTAGE"
  recipients     = join(",", var.oci_budget_alert_emails)
  message        = "OCI monthly spend has reached 100% of the 1 ${var.oci_billing_currency_code} budget."
}

resource "oci_budget_alert_rule" "forecast_100_percent" {
  budget_id      = oci_budget_budget.monthly_spend_alert.id
  display_name   = "Forecast-100-Percent-Alert"
  type           = "FORECAST"
  threshold      = 100
  threshold_type = "PERCENTAGE"
  recipients     = join(",", var.oci_budget_alert_emails)
  message        = "OCI monthly spend is forecasted to reach 100% of the 1 ${var.oci_billing_currency_code} budget."
}
