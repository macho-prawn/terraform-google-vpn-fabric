ephemeral "google_secret_manager_secret_version" "peer1_vpn_preshared_key" {
  for_each = local.tunnels_map

  secret  = each.value.peer1_tunnel_secret         #"${var.vpn_preshared_key.secret}"
  version = each.value.peer1_tunnel_secret_version #each.value.tunnel_secret_version #"${var.vpn_preshared_key.version}"
}

ephemeral "google_secret_manager_secret_version" "peer2_vpn_preshared_key" {
  for_each = local.tunnels_map

  secret  = each.value.peer2_tunnel_secret         #"${var.vpn_preshared_key.secret}"
  version = each.value.peer2_tunnel_secret_version #each.value.tunnel_secret_version #"${var.vpn_preshared_key.version}"
}

# ephemeral "google_secret_manager_secret_version" "vpn_preshared_key_default" {

#   secret = "${var.vpn_preshared_key_default.secret}"
#   version = "${var.vpn_preshared_key_default.version}"
# }