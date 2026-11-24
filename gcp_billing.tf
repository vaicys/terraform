# APIs

resource "google_project_service" "billingbudgets" {
  project            = var.gcp_project_id
  service            = "billingbudgets.googleapis.com"
  disable_on_destroy = false
}

# Billing Budget & Alert

resource "google_billing_budget" "monthly_spend_alert" {
  billing_account = var.gcp_billing_account_id
  display_name    = "Monthly 1 ${var.gcp_billing_currency_code} Spend Alert"

  budget_filter {
    calendar_period = "MONTH"
    # Subtract Always Free / promotional credits so only payable spend triggers alerts
    credit_types_treatment = "INCLUDE_ALL_CREDITS"
  }

  amount {
    specified_amount {
      # Must match the billing account currency
      currency_code = var.gcp_billing_currency_code
      units         = "1"
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  depends_on = [
    google_project_service.billingbudgets,
  ]
}
