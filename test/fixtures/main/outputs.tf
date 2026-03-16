locals {
  gateways = values(module.vpn_infra.gateways)

  src_router_names = sort(distinct([
    for gateway in local.gateways :
    "cr-${gateway.peer1_gws.env_name}-${gateway.peer1_gws.gw_index[0]}-${gateway.peer1_gws.region_abbr}-${gateway.peer1_gws.gw_name}"
  ]))

  dst_router_names = sort(distinct([
    for gateway in local.gateways :
    "cr-${gateway.peer2_gws.env_name}-${gateway.peer2_gws.gw_index[0]}-${gateway.peer2_gws.region_abbr}-${gateway.peer2_gws.gw_name}"
  ]))

  src_gateway_names = sort(distinct([
    for gateway in local.gateways :
    "gw-${gateway.peer1_gws.env_name}-${gateway.peer1_gws.gw_index[0]}-${gateway.peer1_gws.region_abbr}-${gateway.peer1_gws.gw_name}"
  ]))

  dst_gateway_names = sort(distinct([
    for gateway in local.gateways :
    "gw-${gateway.peer2_gws.env_name}-${gateway.peer2_gws.gw_index[0]}-${gateway.peer2_gws.region_abbr}-${gateway.peer2_gws.gw_name}"
  ]))

  src_tunnel_names = sort([
    for tunnel in values(module.vpn_infra.tunnels) :
    "tunnel-${tunnel.peer1_gws.env_name}-${tunnel.peer1_gws.gw_index[0]}-${tunnel.peer1_gws.region_abbr}-${tunnel.peer1_gws.gw_name}-${tunnel.peer1_tunnels.tunnel_name}"
  ])

  dst_tunnel_names = sort([
    for tunnel in values(module.vpn_infra.tunnels) :
    "tunnel-${tunnel.peer2_gws.env_name}-${tunnel.peer2_gws.gw_index[0]}-${tunnel.peer2_gws.region_abbr}-${tunnel.peer2_gws.gw_name}-${tunnel.peer2_tunnels.tunnel_name}"
  ])
}

output "src_project_id" {
  value = one(distinct([for gateway in local.gateways : gateway.peer1_gws.project]))
}

output "dst_project_id" {
  value = one(distinct([for gateway in local.gateways : gateway.peer2_gws.project]))
}

output "src_region" {
  value = one(distinct([for gateway in local.gateways : gateway.peer1_gws.region]))
}

output "dst_region" {
  value = one(distinct([for gateway in local.gateways : gateway.peer2_gws.region]))
}

output "src_router_names" {
  value = local.src_router_names
}

output "dst_router_names" {
  value = local.dst_router_names
}

output "src_gateway_names" {
  value = local.src_gateway_names
}

output "dst_gateway_names" {
  value = local.dst_gateway_names
}

output "src_tunnel_names" {
  value = local.src_tunnel_names
}

output "dst_tunnel_names" {
  value = local.dst_tunnel_names
}
