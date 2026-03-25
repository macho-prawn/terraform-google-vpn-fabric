locals {
  gateways = values(module.vpn_infra.gateways)

  src_router_names = sort(distinct([
    for gateway in local.gateways :
    "cr-${gateway.peer1_gws.env_name}-${gateway.peer1_gws.gw_index[0]}-${gateway.peer1_gws.region_abbr}-${gateway.peer1_gws.gw_name}"
  ]))

  src_gateway_names = sort(distinct([
    for gateway in local.gateways :
    "gw-${gateway.peer1_gws.env_name}-${gateway.peer1_gws.gw_index[0]}-${gateway.peer1_gws.region_abbr}-${gateway.peer1_gws.gw_name}"
  ]))

  src_tunnel_names = sort([
    for tunnel in values(module.vpn_infra.tunnels) :
    "tunnel-${tunnel.peer1_gws.env_name}-${tunnel.peer1_gws.gw_index[0]}-${tunnel.peer1_gws.region_abbr}-${tunnel.peer1_tunnels.tunnel_name}"
  ])

  dst_project_ids = sort(distinct([
    for gateway in local.gateways : gateway.peer2_gws.project
  ]))

  dst_projects = {
    for project_id in local.dst_project_ids : project_id => {
      region = one(distinct([
        for gateway in local.gateways : gateway.peer2_gws.region
        if gateway.peer2_gws.project == project_id
      ]))

      router_names = sort(distinct([
        for gateway in local.gateways :
        "cr-${gateway.peer2_gws.env_name}-${gateway.peer2_gws.gw_index[0]}-${gateway.peer2_gws.region_abbr}-${gateway.peer2_gws.gw_name}"
        if gateway.peer2_gws.project == project_id
      ]))

      gateway_names = sort(distinct([
        for gateway in local.gateways :
        "gw-${gateway.peer2_gws.env_name}-${gateway.peer2_gws.gw_index[0]}-${gateway.peer2_gws.region_abbr}-${gateway.peer2_gws.gw_name}"
        if gateway.peer2_gws.project == project_id
      ]))

      tunnel_names = sort(distinct([
        for tunnel in values(module.vpn_infra.tunnels) :
        "tunnel-${tunnel.peer2_gws.env_name}-${tunnel.peer2_gws.gw_index[0]}-${tunnel.peer2_gws.region_abbr}-${tunnel.peer2_tunnels.tunnel_name}"
        if tunnel.peer2_gws.project == project_id
      ]))
    }
  }
}

output "src_project_id" {
  value = one(distinct([for gateway in local.gateways : gateway.peer1_gws.project]))
}

output "src_region" {
  value = one(distinct([for gateway in local.gateways : gateway.peer1_gws.region]))
}

output "src_router_names" {
  value = local.src_router_names
}

output "src_gateway_names" {
  value = local.src_gateway_names
}

output "src_tunnel_names" {
  value = local.src_tunnel_names
}

output "dst_projects" {
  value = local.dst_projects
}
