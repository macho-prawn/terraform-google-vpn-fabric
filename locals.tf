locals {
  abbr_region = {
    asia-east1              = "ases1"
    asia-east2              = "ases2"
    asia-northeast1         = "asne1"
    asia-northeast2         = "asne2"
    asia-northeast3         = "asne3"
    asia-south1             = "asso1"
    asia-south2             = "asso2"
    asia-southeast1         = "asse1"
    asia-southeast2         = "asse2"
    australia-southeast1    = "ause1"
    australia-southeast2    = "ause2"
    europe-central2         = "euce2"
    europe-north1           = "euno1"
    europe-southwest1       = "eusw1"
    europe-west1            = "euwe1"
    europe-west2            = "euwe2"
    europe-west3            = "euwe3"
    europe-west4            = "euwe4"
    europe-west6            = "euwe6"
    europe-west8            = "euwe8"
    europe-west9            = "euwe9"
    europe-west10           = "euwe10"
    northamerica-northeast1 = "nane1"
    northamerica-northeast2 = "nane2"
    southamerica-east1      = "saea1"
    southamerica-west1      = "sawe1"
    us-central1             = "usce1"
    us-east1                = "usea1"
    us-east4                = "usea4"
    us-east5                = "usea5"
    us-south5               = "useo5"
    us-west1                = "uswe1"
    us-west2                = "uswe2"
    us-west3                = "uswe3"
    us-west4                = "uswe4"
  }

  vpn_details_list = flatten([
    for o in var.vpn_env_details : flatten([
      for e in o.env : flatten([
        for s in e.sub_env : [
          for g in s.gw : {
            gateway_id             = "${o.org_name}-${e.env_name}-${s.sub_env_name}-${s.region}-gw-${g.gw_name}"
            gateway_key            = "${e.env_name}-${s.sub_env_name}-${g.gw_name}"
            gateway_lookup_key     = "${e.env_name}-${s.sub_env_name}:${g.gw_name}"
            org_name               = o.org_name
            env_name               = e.env_name
            sub_env_name           = s.sub_env_name
            env_key                = "${e.env_name}-${s.sub_env_name}"
            region_abbr            = local.abbr_region[s.region]
            region                 = s.region
            project                = s.project.name
            project_secret         = try(s.project.secret, null)
            project_secret_version = try(s.project.secret_version, null)
            vpc                    = s.vpc
            gw_name                = g.gw_name
            gw_index               = regex("-([0-9]+)$", s.vpc)
            gw_key                 = "gw-${g.gw_name}"
            asn                    = g.asn
            tunnels = {
              for tunnel_key, t in g.tunnels : tunnel_key => {
                local_tunnel_key      = tunnel_key
                tunnel_name           = t.tunnel_name
                tunnel_key            = "tunnel-${t.tunnel_name}"
                interface             = t.interface
                bgp_peer_routes       = t.bgp_peer_routes
                tunnel_secret         = try(t.secret, null)
                tunnel_secret_version = try(t.secret_version, null)
                peer_env_name         = t.peer.env_name
                peer_sub_env_name     = t.peer.sub_env_name
                peer_gw_name          = t.peer.gw_name
                peer_local_tunnel_key = t.peer.tunnel_key
              }
            }
          }
        ]
      ])
    ])
  ])

  vpn_details_map = {
    for gateway in local.vpn_details_list : gateway.gateway_key => gateway
  }

  routers_map = {
    for gateway_key, gateway in local.vpn_details_map : gateway_key => {
      gateway_key  = gateway_key
      env_key      = gateway.env_key
      env_name     = gateway.env_name
      sub_env_name = gateway.sub_env_name
      gw_name      = gateway.gw_name
      name         = "cr-${gateway.env_name}-${gateway.gw_index[0]}-${gateway.region_abbr}-${gateway.gw_name}"
      project      = gateway.project
      region       = gateway.region
      network      = gateway.vpc
      asn          = gateway.asn
      region_abbr  = gateway.region_abbr
      org_name     = gateway.org_name
    }
  }

  gateway_lookup_keys = distinct([
    for gateway in local.vpn_details_list : gateway.gateway_lookup_key
  ])

  gateway_lookup_key_counts = {
    for lookup_key in local.gateway_lookup_keys :
    lookup_key => length([
      for gateway in local.vpn_details_list : gateway
      if gateway.gateway_lookup_key == lookup_key
    ])
  }

  duplicate_gateway_names_by_env_key = [
    for lookup_key, count in local.gateway_lookup_key_counts : lookup_key
    if count > 1
  ]

  tunnel_inventory_list = flatten([
    for gateway in local.vpn_details_list : [
      for tunnel_key, tunnel in gateway.tunnels : {
        tunnel_lookup_key       = "${gateway.env_key}:${gateway.gw_name}:${tunnel_key}"
        peer_env_key            = "${tunnel.peer_env_name}-${tunnel.peer_sub_env_name}"
        peer_gateway_lookup_key = "${tunnel.peer_env_name}-${tunnel.peer_sub_env_name}:${tunnel.peer_gw_name}"
        peer_tunnel_lookup_key  = "${tunnel.peer_env_name}-${tunnel.peer_sub_env_name}:${tunnel.peer_gw_name}:${tunnel.peer_local_tunnel_key}"
        gateway_id              = gateway.gateway_id
        gateway_key             = gateway.gateway_key
        gateway_lookup_key      = gateway.gateway_lookup_key
        org_name                = gateway.org_name
        env_name                = gateway.env_name
        sub_env_name            = gateway.sub_env_name
        env_key                 = gateway.env_key
        region_abbr             = gateway.region_abbr
        region                  = gateway.region
        project                 = gateway.project
        project_secret          = gateway.project_secret
        project_secret_version  = gateway.project_secret_version
        vpc                     = gateway.vpc
        gw_name                 = gateway.gw_name
        gw_index                = gateway.gw_index
        gw_key                  = gateway.gw_key
        asn                     = gateway.asn
        local_tunnel_key        = tunnel.local_tunnel_key
        tunnel_name             = tunnel.tunnel_name
        tunnel_key              = tunnel.tunnel_key
        interface               = tunnel.interface
        bgp_peer_routes         = tunnel.bgp_peer_routes
        tunnel_secret           = tunnel.tunnel_secret
        tunnel_secret_version   = tunnel.tunnel_secret_version
        peer_env_name           = tunnel.peer_env_name
        peer_sub_env_name       = tunnel.peer_sub_env_name
        peer_gw_name            = tunnel.peer_gw_name
        peer_local_tunnel_key   = tunnel.peer_local_tunnel_key
      }
    ]
  ])

  tunnel_inventory_map = {
    for tunnel in local.tunnel_inventory_list : tunnel.tunnel_lookup_key => tunnel
  }

  tunnel_link_missing_peer_targets = [
    for tunnel in local.tunnel_inventory_list : tunnel.tunnel_lookup_key
    if !contains(keys(local.tunnel_inventory_map), tunnel.peer_tunnel_lookup_key)
  ]

  tunnel_link_reciprocity_mismatches = [
    for tunnel in local.tunnel_inventory_list : tunnel.tunnel_lookup_key
    if contains(keys(local.tunnel_inventory_map), tunnel.peer_tunnel_lookup_key)
    && local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].peer_tunnel_lookup_key != tunnel.tunnel_lookup_key
  ]

  tunnel_peer_target_keys = [
    for tunnel in local.tunnel_inventory_list : tunnel.peer_tunnel_lookup_key
  ]

  tunnel_peer_target_key_counts = {
    for target_key in distinct(local.tunnel_peer_target_keys) :
    target_key => length([
      for peer_target_key in local.tunnel_peer_target_keys : peer_target_key
      if peer_target_key == target_key
    ])
  }

  tunnel_peer_targets_with_multiple_sources = [
    for target_key, count in local.tunnel_peer_target_key_counts : target_key
    if count > 1
  ]

  tunnel_link_adjacency_errors = [
    for tunnel in local.tunnel_inventory_list : tunnel.tunnel_lookup_key
    if contains(keys(local.tunnel_inventory_map), tunnel.peer_tunnel_lookup_key)
    && local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].peer_tunnel_lookup_key == tunnel.tunnel_lookup_key
    && !contains(lookup(var.vpn_adjacency, tunnel.env_key, []), tunnel.peer_env_key)
    && !contains(lookup(var.vpn_adjacency, tunnel.peer_env_key, []), tunnel.env_key)
  ]

  tunnel_link_ambiguous_adjacency = [
    for tunnel in local.tunnel_inventory_list : tunnel.tunnel_lookup_key
    if contains(keys(local.tunnel_inventory_map), tunnel.peer_tunnel_lookup_key)
    && local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].peer_tunnel_lookup_key == tunnel.tunnel_lookup_key
    && contains(lookup(var.vpn_adjacency, tunnel.env_key, []), tunnel.peer_env_key)
    && contains(lookup(var.vpn_adjacency, tunnel.peer_env_key, []), tunnel.env_key)
  ]

  tunnel_link_interface_mismatches = [
    for tunnel in local.tunnel_inventory_list : tunnel.tunnel_lookup_key
    if contains(keys(local.tunnel_inventory_map), tunnel.peer_tunnel_lookup_key)
    && local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].peer_tunnel_lookup_key == tunnel.tunnel_lookup_key
    && tunnel.interface != local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].interface
  ]

  tunnel_pairs_list = [
    for tunnel in local.tunnel_inventory_list : {
      key           = "${tunnel.tunnel_lookup_key}->${tunnel.peer_tunnel_lookup_key}"
      adjacency_key = "${tunnel.env_key}-${tunnel.peer_env_key}"
      peer1_gws     = local.vpn_details_map[tunnel.gateway_key]
      peer2_gws     = local.vpn_details_map[local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].gateway_key]
      peer1_tunnels = {
        local_tunnel_key      = tunnel.local_tunnel_key
        tunnel_name           = tunnel.tunnel_name
        tunnel_key            = tunnel.tunnel_key
        interface             = tunnel.interface
        bgp_peer_routes       = tunnel.bgp_peer_routes
        tunnel_secret         = tunnel.tunnel_secret
        tunnel_secret_version = tunnel.tunnel_secret_version
      }
      peer2_tunnels = {
        local_tunnel_key      = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].local_tunnel_key
        tunnel_name           = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].tunnel_name
        tunnel_key            = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].tunnel_key
        interface             = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].interface
        bgp_peer_routes       = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].bgp_peer_routes
        tunnel_secret         = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].tunnel_secret
        tunnel_secret_version = local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].tunnel_secret_version
      }
      peer1_tunnel_secret         = coalesce(try(tunnel.tunnel_secret, null), try(tunnel.project_secret, null), "empty")
      peer1_tunnel_secret_version = coalesce(try(tunnel.tunnel_secret_version, null), try(tunnel.project_secret_version, null), "empty")
      peer2_tunnel_secret         = coalesce(try(local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].tunnel_secret, null), try(local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].project_secret, null), "empty")
      peer2_tunnel_secret_version = coalesce(try(local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].tunnel_secret_version, null), try(local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].project_secret_version, null), "empty")
    }
    if contains(keys(local.tunnel_inventory_map), tunnel.peer_tunnel_lookup_key)
    && local.tunnel_inventory_map[tunnel.peer_tunnel_lookup_key].peer_tunnel_lookup_key == tunnel.tunnel_lookup_key
    && contains(lookup(var.vpn_adjacency, tunnel.env_key, []), tunnel.peer_env_key)
  ]

  tunnels_map = {
    for tunnel_pair in local.tunnel_pairs_list : tunnel_pair.key => {
      adjacency_key               = tunnel_pair.adjacency_key
      peer1_gws                   = tunnel_pair.peer1_gws
      peer2_gws                   = tunnel_pair.peer2_gws
      peer1_tunnels               = tunnel_pair.peer1_tunnels
      peer2_tunnels               = tunnel_pair.peer2_tunnels
      peer1_tunnel_secret         = tunnel_pair.peer1_tunnel_secret
      peer1_tunnel_secret_version = tunnel_pair.peer1_tunnel_secret_version
      peer2_tunnel_secret         = tunnel_pair.peer2_tunnel_secret
      peer2_tunnel_secret_version = tunnel_pair.peer2_tunnel_secret_version
    }
  }

  gateways_map = {
    for gateway_pair in values(local.tunnels_map) :
    "${gateway_pair.adjacency_key}-${gateway_pair.peer1_gws.gw_name}-${gateway_pair.peer2_gws.gw_name}" => {
      adjacency_key = gateway_pair.adjacency_key
      peer1_gws     = gateway_pair.peer1_gws
      peer2_gws     = gateway_pair.peer2_gws
    }
  }

  tunnel_keys_with_missing_secret = [
    for tunnel_key, tunnel in local.tunnels_map : tunnel_key
    if tunnel.peer1_tunnel_secret == null
    || tunnel.peer1_tunnel_secret == ""
    || tunnel.peer1_tunnel_secret_version == null
    || tunnel.peer1_tunnel_secret_version == ""
    || tunnel.peer2_tunnel_secret == null
    || tunnel.peer2_tunnel_secret == ""
    || tunnel.peer2_tunnel_secret_version == null
    || tunnel.peer2_tunnel_secret_version == ""
    || (tunnel.peer1_tunnel_secret == "empty" && tunnel.peer1_tunnel_secret_version == "empty")
    || (tunnel.peer2_tunnel_secret == "empty" && tunnel.peer2_tunnel_secret_version == "empty")
  ]
}
