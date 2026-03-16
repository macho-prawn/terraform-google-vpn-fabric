module "src_host_project" {
  source  = "tfe.gcp.db.com/PMR/cpt-project/google"
  version = "2.3.0"

  project_name       = format("src-hstprj-%s", var.module_name)
  nar_id             = var.nar_id
  environment        = var.environment
  folder_id          = var.folder_id
  organization_id    = var.organization_id
  billing_account_id = var.billing_account_id
  instance_id        = var.instance_id
  lz_version         = var.lz_version
  activate_apis      = local.apis
  contacts           = { "cloud_net_eng@list.db.com" = { language = "en", category = ["ALL"] } }
  cloud_armor_tier   = "CA_STANDARD"
}

module "dst_host_project" {
  source  = "tfe.gcp.db.com/PMR/cpt-project/google"
  version = "2.3.0"

  project_name       = format("dst-hstprj-%s", var.module_name)
  nar_id             = var.nar_id
  environment        = var.environment
  folder_id          = var.folder_id
  organization_id    = var.organization_id
  billing_account_id = var.billing_account_id
  instance_id        = var.instance_id
  lz_version         = var.lz_version
  activate_apis      = local.apis
  contacts           = { "cloud_net_eng@list.db.com" = { language = "en", category = ["ALL"] } }
  cloud_armor_tier   = "CA_STANDARD"
}

module "project_for_secrets" {
  source  = "tfe.gcp.db.com/PMR/cpt-project/google"
  version = "2.3.0"

  project_name       = format("prj-secret-%s", var.module_name)
  nar_id             = var.nar_id
  environment        = var.environment
  folder_id          = var.folder_id
  organization_id    = var.organization_id
  billing_account_id = var.billing_account_id
  instance_id        = var.instance_id
  lz_version         = var.lz_version
  activate_apis      = local.apis
  contacts           = { "cloud_net_eng@list.db.com" = { language = "en", category = ["ALL"] } }
  cloud_armor_tier   = "CA_STANDARD"
}
