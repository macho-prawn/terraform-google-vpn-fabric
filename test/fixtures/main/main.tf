data "terraform_remote_state" "sensitive_state" {
  backend = "remote"
  config = {
    hostname     = "tfe.gcp.db.com"
    organization = var.sensitive_workspace_organization
    workspaces = {
      name = var.sensitive_workspace_name
    }
  }
}

module "vpn_infra" {
  source          = "../../.."
  vpn_env_details = local.vpn_env_details
}
