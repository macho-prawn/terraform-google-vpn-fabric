resource "google_compute_router" "peer1_router" {
  for_each = local.gateway_map
  name     = "cr-${each.value.peer1_gws.env_name}-${each.value.peer1_gws.gw_index[0]}-${each.value.peer1_gws.region_abbr}-${each.value.peer1_gws.gw_name}"
  project  = each.value.peer1_gws.project
  region   = each.value.peer1_gws.region
  network  = each.value.peer1_gws.vpc
  bgp {
    asn = each.value.peer1_gws.asn
  }
}

resource "google_compute_router" "peer2_router" {
  for_each = local.gateway_map
  name     = "cr-${each.value.peer2_gws.env_name}-${each.value.peer2_gws.gw_index[0]}-${each.value.peer2_gws.region_abbr}-${each.value.peer2_gws.gw_name}"
  project  = each.value.peer2_gws.project
  region   = each.value.peer2_gws.region
  network  = each.value.peer2_gws.vpc
  bgp {
    asn = each.value.peer2_gws.asn
  }
}

resource "google_compute_ha_vpn_gateway" "peer1_gateway" {
  for_each = local.gateway_map

  name    = "gw-${each.value.peer1_gws.env_name}-${each.value.peer1_gws.gw_index[0]}-${each.value.peer1_gws.region_abbr}-${each.value.peer1_gws.gw_name}"
  project = each.value.peer1_gws.project
  region  = each.value.peer1_gws.region
  network = each.value.peer1_gws.vpc
}

resource "google_compute_ha_vpn_gateway" "peer2_gateway" {
  for_each = local.gateway_map

  name    = "gw-${each.value.peer2_gws.env_name}-${each.value.peer2_gws.gw_index[0]}-${each.value.peer2_gws.region_abbr}-${each.value.peer2_gws.gw_name}"
  project = each.value.peer2_gws.project
  region  = each.value.peer2_gws.region
  network = each.value.peer2_gws.vpc
}

resource "google_compute_vpn_tunnel" "peer1_tunnel_0" {
  for_each = { for k, t in local.tunnels_map : k => t if t.peer1_tunnels.interface == 0 }

  name                     = "tunnel-${each.value.peer1_gws.env_name}-${each.value.peer1_gws.gw_index[0]}-${each.value.peer1_gws.region_abbr}-${each.value.peer1_tunnels.tunnel_name}"
  project                  = each.value.peer1_gws.project
  shared_secret_wo         = ephemeral.google_secret_manager_secret_version.peer1_vpn_preshared_key[each.key].secret_data
  shared_secret_wo_version = each.value.peer1_tunnel_secret_version
  region                   = each.value.peer1_gws.region
  ike_version              = 2
  router                   = google_compute_router.peer1_router[each.value.adjacency_key].name
  vpn_gateway              = google_compute_ha_vpn_gateway.peer1_gateway[each.value.adjacency_key].id
  vpn_gateway_interface    = each.value.peer1_tunnels.interface
  peer_gcp_gateway         = google_compute_ha_vpn_gateway.peer2_gateway[each.value.adjacency_key].id
}

resource "google_compute_vpn_tunnel" "peer2_tunnel_0" {
  for_each = { for k, t in local.tunnels_map : k => t if t.peer2_tunnels.interface == 0 }

  name                     = "tunnel-${each.value.peer2_gws.env_name}-${each.value.peer2_gws.gw_index[0]}-${each.value.peer2_gws.region_abbr}-${each.value.peer2_tunnels.tunnel_name}"
  project                  = each.value.peer2_gws.project
  shared_secret_wo         = ephemeral.google_secret_manager_secret_version.peer2_vpn_preshared_key[each.key].secret_data
  shared_secret_wo_version = each.value.peer2_tunnel_secret_version
  region                   = each.value.peer2_gws.region
  ike_version              = 2
  router                   = google_compute_router.peer2_router[each.value.adjacency_key].name
  vpn_gateway              = google_compute_ha_vpn_gateway.peer2_gateway[each.value.adjacency_key].id
  vpn_gateway_interface    = each.value.peer2_tunnels.interface
  peer_gcp_gateway         = google_compute_ha_vpn_gateway.peer1_gateway[each.value.adjacency_key].id
}

resource "google_compute_vpn_tunnel" "peer1_tunnel_1" {
  for_each = { for k, t in local.tunnels_map : k => t if t.peer1_tunnels.interface == 1 }

  name                     = "tunnel-${each.value.peer1_gws.env_name}-${each.value.peer1_gws.gw_index[0]}-${each.value.peer1_gws.region_abbr}-${each.value.peer1_tunnels.tunnel_name}"
  project                  = each.value.peer1_gws.project
  shared_secret_wo         = ephemeral.google_secret_manager_secret_version.peer1_vpn_preshared_key[each.key].secret_data
  shared_secret_wo_version = each.value.peer1_tunnel_secret_version
  region                   = each.value.peer1_gws.region
  ike_version              = 2
  router                   = google_compute_router.peer1_router[each.value.adjacency_key].name
  vpn_gateway              = google_compute_ha_vpn_gateway.peer1_gateway[each.value.adjacency_key].id
  vpn_gateway_interface    = each.value.peer1_tunnels.interface
  peer_gcp_gateway         = google_compute_ha_vpn_gateway.peer2_gateway[each.value.adjacency_key].id

  depends_on = [google_compute_vpn_tunnel.peer1_tunnel_0, google_compute_vpn_tunnel.peer2_tunnel_0]

}

resource "google_compute_vpn_tunnel" "peer2_tunnel_1" {
  for_each = { for k, t in local.tunnels_map : k => t if t.peer2_tunnels.interface == 1 }

  name                     = "tunnel-${each.value.peer2_gws.env_name}-${each.value.peer2_gws.gw_index[0]}-${each.value.peer2_gws.region_abbr}-${each.value.peer2_tunnels.tunnel_name}"
  project                  = each.value.peer2_gws.project
  shared_secret_wo         = ephemeral.google_secret_manager_secret_version.peer2_vpn_preshared_key[each.key].secret_data
  shared_secret_wo_version = each.value.peer2_tunnel_secret_version
  region                   = each.value.peer2_gws.region
  ike_version              = 2
  router                   = google_compute_router.peer2_router[each.value.adjacency_key].name
  vpn_gateway              = google_compute_ha_vpn_gateway.peer2_gateway[each.value.adjacency_key].id
  vpn_gateway_interface    = each.value.peer2_tunnels.interface
  peer_gcp_gateway         = google_compute_ha_vpn_gateway.peer1_gateway[each.value.adjacency_key].id

  depends_on = [google_compute_vpn_tunnel.peer1_tunnel_0, google_compute_vpn_tunnel.peer2_tunnel_0]

}

resource "google_compute_router_interface" "peer1_cloud_router_interface" {
  for_each = local.tunnels_map

  name       = each.value.peer1_tunnels.interface == 0 ? "if-bgp-${google_compute_vpn_tunnel.peer1_tunnel_0[each.key].name}" : "if-bgp-${google_compute_vpn_tunnel.peer1_tunnel_1[each.key].name}"
  project    = each.value.peer1_gws.project
  router     = google_compute_router.peer1_router[each.value.adjacency_key].name
  region     = each.value.peer1_gws.region
  vpn_tunnel = each.value.peer1_tunnels.interface == 0 ? google_compute_vpn_tunnel.peer1_tunnel_0[each.key].name : google_compute_vpn_tunnel.peer1_tunnel_1[each.key].name
}

resource "google_compute_router_peer" "peer1_router_peer" {
  for_each = local.tunnels_map

  name           = each.value.peer1_tunnels.interface == 0 ? "bgp-${google_compute_vpn_tunnel.peer1_tunnel_0[each.key].name}" : "bgp-${google_compute_vpn_tunnel.peer1_tunnel_1[each.key].name}"
  project        = each.value.peer1_gws.project
  router         = google_compute_router.peer1_router[each.value.adjacency_key].name
  interface      = each.value.peer1_tunnels.interface == 0 ? "if-bgp-${google_compute_vpn_tunnel.peer1_tunnel_0[each.key].name}" : "if-bgp-${google_compute_vpn_tunnel.peer1_tunnel_1[each.key].name}"
  peer_asn       = each.value.peer2_gws.asn
  advertise_mode = "CUSTOM"
  advertised_ip_ranges {
    range = each.value.peer1_tunnels.bgp_peer_routes
  }
  region = each.value.peer1_gws.region
}

resource "google_compute_router_interface" "peer2_cloud_router_interface" {
  for_each = local.tunnels_map

  name       = each.value.peer2_tunnels.interface == 0 ? "if-bgp-${google_compute_vpn_tunnel.peer2_tunnel_0[each.key].name}" : "if-bgp-${google_compute_vpn_tunnel.peer2_tunnel_1[each.key].name}"
  project    = each.value.peer2_gws.project
  router     = google_compute_router.peer2_router[each.value.adjacency_key].name
  region     = each.value.peer2_gws.region
  ip_range   = "${google_compute_router_peer.peer1_router_peer[each.key].peer_ip_address}/30"
  vpn_tunnel = each.value.peer2_tunnels.interface == 0 ? google_compute_vpn_tunnel.peer2_tunnel_0[each.key].name : google_compute_vpn_tunnel.peer2_tunnel_1[each.key].name
}

resource "google_compute_router_peer" "peer2_router_peer" {
  for_each = local.tunnels_map

  name           = each.value.peer2_tunnels.interface == 0 ? "bgp-${google_compute_vpn_tunnel.peer2_tunnel_0[each.key].name}" : "bgp-${google_compute_vpn_tunnel.peer2_tunnel_1[each.key].name}"
  project        = each.value.peer2_gws.project
  router         = google_compute_router.peer2_router[each.value.adjacency_key].name
  interface      = each.value.peer2_tunnels.interface == 0 ? "if-bgp-${google_compute_vpn_tunnel.peer2_tunnel_0[each.key].name}" : "if-bgp-${google_compute_vpn_tunnel.peer2_tunnel_1[each.key].name}"
  peer_asn       = each.value.peer1_gws.asn
  advertise_mode = "CUSTOM"
  advertised_ip_ranges {
    range = each.value.peer2_tunnels.bgp_peer_routes
  }
  region          = each.value.peer2_gws.region
  ip_address      = google_compute_router_peer.peer1_router_peer[each.key].peer_ip_address
  peer_ip_address = google_compute_router_peer.peer1_router_peer[each.key].ip_address
}
