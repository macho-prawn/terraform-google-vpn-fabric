locals {
  gateways = values(module.vpn_infra.gateways)
  src_project_ids = sort(distinct([for gateway in local.gateways : gateway.peer1_gws.project]))
  dst_project_ids = sort(distinct([for gateway in local.gateways : gateway.peer2_gws.project]))

  src_projects = {
    for project_id in local.src_project_ids : project_id => {
      for region in sort(distinct([
        for gateway in local.gateways : gateway.peer1_gws.region
        if gateway.peer1_gws.project == project_id
      ])) : region => {
        router_names = sort(distinct([
          for gateway in local.gateways :
          "cr-${gateway.peer1_gws.env_name}-${gateway.peer1_gws.gw_index[0]}-${gateway.peer1_gws.region_abbr}-${gateway.peer1_gws.gw_name}"
          if gateway.peer1_gws.project == project_id && gateway.peer1_gws.region == region
        ]))

        gateway_names = sort(distinct([
          for gateway in local.gateways :
          "gw-${gateway.peer1_gws.env_name}-${gateway.peer1_gws.gw_index[0]}-${gateway.peer1_gws.region_abbr}-${gateway.peer1_gws.gw_name}"
          if gateway.peer1_gws.project == project_id && gateway.peer1_gws.region == region
        ]))

        tunnel_names = sort(distinct([
          for tunnel in values(module.vpn_infra.tunnels) :
          "tunnel-${tunnel.peer1_gws.env_name}-${tunnel.peer1_gws.gw_index[0]}-${tunnel.peer1_gws.region_abbr}-${tunnel.peer1_tunnels.tunnel_name}"
          if tunnel.peer1_gws.project == project_id && tunnel.peer1_gws.region == region
        ]))
      }
    }
  }

  dst_projects = {
    for project_id in local.dst_project_ids : project_id => {
      for region in sort(distinct([
        for gateway in local.gateways : gateway.peer2_gws.region
        if gateway.peer2_gws.project == project_id
      ])) : region => {
        router_names = sort(distinct([
          for gateway in local.gateways :
          "cr-${gateway.peer2_gws.env_name}-${gateway.peer2_gws.gw_index[0]}-${gateway.peer2_gws.region_abbr}-${gateway.peer2_gws.gw_name}"
          if gateway.peer2_gws.project == project_id && gateway.peer2_gws.region == region
        ]))

        gateway_names = sort(distinct([
          for gateway in local.gateways :
          "gw-${gateway.peer2_gws.env_name}-${gateway.peer2_gws.gw_index[0]}-${gateway.peer2_gws.region_abbr}-${gateway.peer2_gws.gw_name}"
          if gateway.peer2_gws.project == project_id && gateway.peer2_gws.region == region
        ]))

        tunnel_names = sort(distinct([
          for tunnel in values(module.vpn_infra.tunnels) :
          "tunnel-${tunnel.peer2_gws.env_name}-${tunnel.peer2_gws.gw_index[0]}-${tunnel.peer2_gws.region_abbr}-${tunnel.peer2_tunnels.tunnel_name}"
          if tunnel.peer2_gws.project == project_id && tunnel.peer2_gws.region == region
        ]))
      }
    }
  }
}

output "src_projects" {
  value = local.src_projects
}

output "dst_projects" {
  value = local.dst_projects
}
