resource "random_string" "secret" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

# https://github.com/settings/tokens/new
# admin:repo_hook

locals {
  webhook_secret  = random_string.secret.result
  github_token    = var.github_token
  github_username = var.github_username
}