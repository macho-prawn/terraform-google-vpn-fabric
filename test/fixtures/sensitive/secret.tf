resource "google_secret_manager_secret" "vpn_preshared_key_project" {
  secret_id = "vpn_preshared_key_project"
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

resource "google_secret_manager_secret_version" "vpn_preshared_key_project" {
  secret      = google_secret_manager_secret.vpn_preshared_key_project.id
  secret_data = "bumbumbhole"
}

resource "google_secret_manager_secret" "vpn_preshared_key_tunnel" {
  secret_id = "vpn_preshared_key_tunnel"
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

resource "google_secret_manager_secret_version" "vpn_preshared_key_tunnel" {
  secret      = google_secret_manager_secret.vpn_preshared_key_tunnel.id
  secret_data = "bumbumbhole"
}
