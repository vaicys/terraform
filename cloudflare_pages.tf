resource "cloudflare_pages_project" "vaicys_com" {
  account_id        = var.cloudflare_account_id
  name              = "vaicys-com"
  production_branch = "master"
  source = {
    type = "github"
    config = {
      owner                          = "vaicys"
      repo_name                      = "website"
      production_branch              = "master"
      production_deployments_enabled = true
      preview_deployment_setting     = "all"
      pr_comments_enabled            = true
      path_includes                  = ["*"]
      preview_branch_includes        = ["*"]
    }
  }

  lifecycle {
    ignore_changes = [
      build_config,
      deployment_configs,
    ]
  }
}

resource "cloudflare_pages_domain" "vaicys_com_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.vaicys_com.name
  name         = "vaicys.com"
}

resource "cloudflare_pages_domain" "www_vaicys_com_domain" {
  account_id   = var.cloudflare_account_id
  project_name = cloudflare_pages_project.vaicys_com.name
  name         = "www.vaicys.com"
}
