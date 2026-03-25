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

  vpn_adj_map = merge(flatten([
    for p1k, p1v in var.vpn_adjacency : {
      for p2v in p1v : format("%s-%s", p1k, p2v) => {
        peer1 = p1k
        peer2 = p2v
      }
    }
  ])...)

  vpn_details_list = flatten([
    for o in var.vpn_env_details : flatten([
      for e in o.env : flatten([
        for s in e.sub_env : [
          for g in s.gw : {
            gateway_id             = "${o.org_name}-${e.env_name}-${s.sub_env_name}-${s.region}-gw-${g.gw_name}"
            gateway_key            = "${e.env_name}-${s.sub_env_name}-${g.gw_name}"
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
              for t in g.tunnels : tostring(t.interface) => {
                tunnel_name           = t.tunnel_name
                tunnel_key            = "tunnel-${t.tunnel_name}"
                interface             = t.interface
                bgp_peer_routes       = t.bgp_peer_routes
                tunnel_secret         = try(t.secret, null)
                tunnel_secret_version = try(t.secret_version, null)
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

  gateways_by_env_key = {
    for env_key in distinct([for gateway in local.vpn_details_list : gateway.env_key]) :
    env_key => [for gateway in local.vpn_details_list : gateway if gateway.env_key == env_key]
  }

  gateway_lookup_keys = distinct([
    for gateway in local.vpn_details_list : "${gateway.env_key}:${gateway.gw_name}"
  ])

  gateway_lookup_key_counts = {
    for lookup_key in local.gateway_lookup_keys :
    lookup_key => length([
      for gateway in local.vpn_details_list : gateway
      if "${gateway.env_key}:${gateway.gw_name}" == lookup_key
    ])
  }

  duplicate_gateway_names_by_env_key = [
    for lookup_key, count in local.gateway_lookup_key_counts : lookup_key
    if count > 1
  ]

  adjacency_keys_with_mismatched_gateway_counts = [
    for adjkey, adjval in local.vpn_adj_map : format(
      "%s:%s=%d:%s=%d",
      adjkey,
      adjval.peer1,
      length(lookup(local.gateways_by_env_key, adjval.peer1, [])),
      adjval.peer2,
      length(lookup(local.gateways_by_env_key, adjval.peer2, []))
    )
    if length(lookup(local.gateways_by_env_key, adjval.peer1, [])) != length(lookup(local.gateways_by_env_key, adjval.peer2, []))
  ]

  gateways_map = {
    for gateway_pair in flatten([
      for adjkey, adjval in local.vpn_adj_map : [
        for index in range(length(lookup(local.gateways_by_env_key, adjval.peer1, []))) : {
          key           = "${adjkey}-${local.gateways_by_env_key[adjval.peer1][index].gw_name}-${local.gateways_by_env_key[adjval.peer2][index].gw_name}"
          adjacency_key = adjkey
          peer1_gws     = local.gateways_by_env_key[adjval.peer1][index]
          peer2_gws     = local.gateways_by_env_key[adjval.peer2][index]
        }
      ]
      if length(lookup(local.gateways_by_env_key, adjval.peer1, [])) == length(lookup(local.gateways_by_env_key, adjval.peer2, []))
      ]) : gateway_pair.key => {
      adjacency_key = gateway_pair.adjacency_key
      peer1_gws     = gateway_pair.peer1_gws
      peer2_gws     = gateway_pair.peer2_gws
    }
  }

  tunnels_map = {
    for tunnel_pair in flatten([
      for gateway_pair_key, gateway_pair in local.gateways_map : [
        for interface, peer1_tunnel in gateway_pair.peer1_gws.tunnels : {
          key                         = "${gateway_pair.peer1_gws.gateway_id}-t-${peer1_tunnel.tunnel_name}-${interface}"
          adjacency_key               = gateway_pair.adjacency_key
          peer1_gws                   = gateway_pair.peer1_gws
          peer2_gws                   = gateway_pair.peer2_gws
          peer1_tunnels               = peer1_tunnel
          peer2_tunnels               = gateway_pair.peer2_gws.tunnels[interface]
          peer1_tunnel_secret         = coalesce(try(peer1_tunnel.tunnel_secret, null), try(gateway_pair.peer1_gws.project_secret, null), "empty")
          peer1_tunnel_secret_version = coalesce(try(peer1_tunnel.tunnel_secret_version, null), try(gateway_pair.peer1_gws.project_secret_version, null), "empty")
          peer2_tunnel_secret         = coalesce(try(gateway_pair.peer2_gws.tunnels[interface].tunnel_secret, null), try(gateway_pair.peer2_gws.project_secret, null), "empty")
          peer2_tunnel_secret_version = coalesce(try(gateway_pair.peer2_gws.tunnels[interface].tunnel_secret_version, null), try(gateway_pair.peer2_gws.project_secret_version, null), "empty")
        }
        if contains(keys(gateway_pair.peer2_gws.tunnels), interface)
      ]
      ]) : tunnel_pair.key => {
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
