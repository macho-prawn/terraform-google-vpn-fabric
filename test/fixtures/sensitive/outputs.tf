output "src_host_project_id" {
  value = module.src_host_project.project_id
}

output "src_shared_vpc" {
  value = module.src_shared_vpc.network
}

output "dst_host_project_id" {
  value = module.dst_host_project.project_id
}

output "dst_shared_vpc" {
  value = module.dst_shared_vpc.network
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
