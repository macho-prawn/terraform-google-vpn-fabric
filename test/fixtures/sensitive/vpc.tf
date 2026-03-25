module "src_shared_vpc" {
  source  = "tfe.gcp.db.com/PMR/gns-shared-vpc/google"
  version = "1.3.3"

  name = "shared"

  # This will be used for the names of resources
  suffix = "${lower(var.environment)}-01"

  # Project to deploy the Shared VPC on
  project_id = module.src_host_project.project_id

  # VPC address ranges allocated for this shared VPC
  vpc_address_ranges = [""]
  depends_on         = [module.src_host_project]
}

module "dst_shared_vpc_1" {
  source  = "tfe.gcp.db.com/PMR/gns-shared-vpc/google"
  version = "1.3.3"

  name = "shared"

  # This will be used for the names of resources
  suffix = "${lower(var.environment)}-01"

  # Project to deploy the Shared VPC on
  project_id = module.dst_host_project_1.project_id

  # VPC address ranges allocated for this shared VPC
  vpc_address_ranges = [""]
  depends_on         = [module.dst_host_project_1]
}

module "dst_shared_vpc_2" {
  source  = "tfe.gcp.db.com/PMR/gns-shared-vpc/google"
  version = "1.3.3"

  name = "shared"

  # This will be used for the names of resources
  suffix = "${lower(var.environment)}-01"

  # Project to deploy the Shared VPC on
  project_id = module.dst_host_project_2.project_id

  # VPC address ranges allocated for this shared VPC
  vpc_address_ranges = [""]
  depends_on         = [module.dst_host_project_2]
}

module "dst_shared_vpc_3" {
  source  = "tfe.gcp.db.com/PMR/gns-shared-vpc/google"
  version = "1.3.3"

  name = "shared"

  # This will be used for the names of resources
  suffix = "${lower(var.environment)}-01"

  # Project to deploy the Shared VPC on
  project_id = module.dst_host_project_3.project_id

  # VPC address ranges allocated for this shared VPC
  vpc_address_ranges = [""]
  depends_on         = [module.dst_host_project_3]
}

module "dst_shared_vpc_4" {
  source  = "tfe.gcp.db.com/PMR/gns-shared-vpc/google"
  version = "1.3.3"

  name = "shared"

  # This will be used for the names of resources
  suffix = "${lower(var.environment)}-01"

  # Project to deploy the Shared VPC on
  project_id = module.dst_host_project_4.project_id

  # VPC address ranges allocated for this shared VPC
  vpc_address_ranges = [""]
  depends_on         = [module.dst_host_project_4]
}

module "dst_shared_vpc_5" {
  source  = "tfe.gcp.db.com/PMR/gns-shared-vpc/google"
  version = "1.3.3"

  name = "shared"

  # This will be used for the names of resources
  suffix = "${lower(var.environment)}-01"

  # Project to deploy the Shared VPC on
  project_id = module.dst_host_project_5.project_id

  # VPC address ranges allocated for this shared VPC
  vpc_address_ranges = [""]
  depends_on         = [module.dst_host_project_5]
}