ephemeral "google_secret_manager_secret_version" "peer1_vpn_preshared_key" {
  for_each   = local.tunnels_map

  secret     = each.value.peer1_tunnel_secret
  version    = each.value.peer1_tunnel_secret_version
  depends_on = [ null_resource.resolved_tunnel_secrets_guard ]
}

ephemeral "google_secret_manager_secret_version" "peer2_vpn_preshared_key" {
  for_each   = local.tunnels_map

  secret     = each.value.peer2_tunnel_secret
  version    = each.value.peer2_tunnel_secret_version
  depends_on = [ null_resource.resolved_tunnel_secrets_guard ]
}
