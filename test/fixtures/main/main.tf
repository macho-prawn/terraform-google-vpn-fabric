# load the sensitive workspace's state
# the Terraform in test/fixtures/sensitive used this workspace to create the project we need
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
  vpn_preshared_key_1 = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_1
  vpn_preshared_key = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key
}
