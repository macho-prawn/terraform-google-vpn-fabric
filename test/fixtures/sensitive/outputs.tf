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

# output "vpn_preshared_key" {
#   value = {
#     secret  = google_secret_manager_secret_version.vpn_preshared_key.secret
#     version = google_secret_manager_secret_version.vpn_preshared_key.version
#   }
# }

# output "vpn_preshared_key_1" {
#   value = {
#     secret  = google_secret_manager_secret_version.vpn_preshared_key_1.secret
#     secret_version = google_secret_manager_secret_version.vpn_preshared_key_1.version
#   }
# }

output "vpn_preshared_key" {
  value = {
    secret  = google_secret_manager_secret_version.vpn_preshared_key.secret
    secret_version = google_secret_manager_secret_version.vpn_preshared_key.version
  }
}


output "vpn_preshared_key_1" {
  value = { for key, s in google_secret_manager_secret_version.vpn_preshared_key_1 :
    key => { secret = s.secret
    secret_version = s.version }
  }
}