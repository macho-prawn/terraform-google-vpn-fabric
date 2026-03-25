output "src_host_project_id" {
  value = module.src_host_project.project_id
}

output "src_shared_vpc" {
  value = module.src_shared_vpc.network
}

output "dst_host_project_id_1" {
  value = module.dst_host_project_1.project_id
}

output "dst_host_project_id_2" {
  value = module.dst_host_project_2.project_id
}

output "dst_host_project_id_3" {
  value = module.dst_host_project_3.project_id
}

output "dst_host_project_id_4" {
  value = module.dst_host_project_4.project_id
}

output "dst_host_project_id_5" {
  value = module.dst_host_project_5.project_id
}

output "secret_project_id" {
  value = module.project_for_secrets.project_id
}

output "dst_shared_vpc_1" {
  value = module.dst_shared_vpc_1.network
}

output "dst_shared_vpc_2" {
  value = module.dst_shared_vpc_2.network
}

output "dst_shared_vpc_3" {
  value = module.dst_shared_vpc_3.network
}

output "dst_shared_vpc_4" {
  value = module.dst_shared_vpc_4.network
}

output "dst_shared_vpc_5" {
  value = module.dst_shared_vpc_5.network
}

output "vpn_preshared_key_project" {
  value = {
    secret         = google_secret_manager_secret_version.vpn_preshared_key_project.secret
    secret_version = google_secret_manager_secret_version.vpn_preshared_key_project.version
  }
}

output "vpn_preshared_key_tunnel" {
  value = {
    secret         = google_secret_manager_secret_version.vpn_preshared_key_tunnel.secret
    secret_version = google_secret_manager_secret_version.vpn_preshared_key_tunnel.version
  }
}
