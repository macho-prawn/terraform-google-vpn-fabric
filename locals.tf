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

  tunnels_map = merge(flatten([
    for adjkey, adjval in local.vpn_adj_map : [
      for gw1_key, gw1 in local.vpn_details_map : [
        for tk_1, t_1 in gw1.tunnels : [
          for gw2_key, gw2 in local.vpn_details_map : [
            for o_key, o_val in local.vpn_details_map : [
            for tk_2, t_2 in gw2.tunnels : {
              
              "${t_1.interface}-${adjkey}" = {

                peer1_gws = lookup(local.vpn_details_map, gw1_key, {})
                peer2_gws = lookup(local.vpn_details_map, gw2_key, {})

                peer1_tunnels = t_1
                peer2_tunnels = t_2
                
                peer1_tunnel_secret = coalesce(try(t_1.t_secret, null), o_val.org_secret) 
                peer1_tunnel_secret_version = coalesce(try(t_1.t_secret_version, null), o_val.org_secret_version)
                
                peer2_tunnel_secret = coalesce(try(t_2.t_secret, null), o_val.org_secret) 
                peer2_tunnel_secret_version = coalesce(try(t_2.t_secret_version, null), o_val.org_secret_version)

                #tunnel_secret         = var.vpn_preshared_key["${t_1.interface}-${adjkey}"].secret
                #tunnel_secret_version = var.vpn_preshared_key["${t_1.interface}-${adjkey}"].version

              }
            } if t_1.interface == t_2.interface 
            && strcontains(gw1_key, adjval.peer1) 
            && strcontains(gw2_key, adjval.peer2)
          ]
          ]
        ]
      ]
    ]
  ])...)

  gateway_map = merge(flatten([
    for adjkey, adjval in local.vpn_adj_map : [
      for gw1_key, gw1 in local.vpn_details_map : [
        for gw2_key, gw2 in local.vpn_details_map : {
          "${adjkey}" = {

            peer1_gw_key = gw1_key
            peer2_gw_key = gw2_key

            peer1_gws = lookup(local.vpn_details_map, gw1_key, {})
            peer2_gws = lookup(local.vpn_details_map, gw2_key, {})

          }
        } if strcontains(gw1_key, adjval.peer1) && strcontains(gw2_key, adjval.peer2)
      ]
    ]
  ])...)


  vpn_details_map = merge([
    for o in var.vpn_env_details : merge([
      for e in o.env : merge([
        for s in e.sub_env : merge([
          for g in s.gw : {
            "${o.org_name}-${e.env_name}-${s.sub_env_name}-${s.region}-gw-${g.gw_name}" = {
              
              org_name     = o.org_name
              org_secret = o.org_secret
              org_secret_version = o.org_secret_version

              env_name     = e.env_name
              sub_env_name = s.sub_env_name
              env_key      = "${e.env_name}-${s.sub_env_name}"
              region_abbr  = local.abbr_region[s.region]
              region       = s.region
              project      = s.project
              vpc          = s.vpc
              gw_name      = g.gw_name
              gw_index     = regex("-([0-9]+)$", s.vpc)
              gw_key       = "gw-${g.gw_name}"
              asn          = g.asn
              tunnels = {
                for t in g.tunnels : "${t.interface}" => {
                  tunnel_name      = t.tunnel_name
                  tunnel_key       = "tunnel-${t.tunnel_name}"
                  interface        = t.interface
                  bgp_peer_routes  = t.bgp_peer_routes
                  t_secret         =  var.vpn_preshared_key_1["${t.interface}-${e.env_name}-${s.sub_env_name}"].secret # t.t_secret
                  t_secret_version = var.vpn_preshared_key_1["${t.interface}-${e.env_name}-${s.sub_env_name}"].secret_version
                }
              }
            }
          }
        ]...)
      ]...)
    ]...)
  ]...)

}
