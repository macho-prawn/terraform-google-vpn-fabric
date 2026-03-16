resource "google_secret_manager_secret" "vpn_preshared_key" {
  
  secret_id = "vpn_preshared_key_for_org"
  project   = module.project_for_secrets.project_id
  replication {
    user_managed {
      replicas {
        location = "europe-west3"
      }
    }
  }
  depends_on = [module.project_for_secrets]
}

resource "google_secret_manager_secret_version" "vpn_preshared_key" {  

  secret      = google_secret_manager_secret.vpn_preshared_key.id
  secret_data = "bumbumbhole" 

}

resource "google_secret_manager_secret" "vpn_preshared_key_1" {
 for_each = local.all_envs_map

  secret_id = "vpn_preshared_key_${each.key}"
  project   = module.project_for_secrets.project_id
  replication {
    user_managed {
      replicas {
        location = "europe-west3"
      }
    }
  }
  depends_on = [module.project_for_secrets]
}

resource "google_secret_manager_secret_version" "vpn_preshared_key_1" {
  for_each = local.all_envs_map

  secret      = google_secret_manager_secret.vpn_preshared_key_1[each.key].id
  secret_data = "million_voices"
}


