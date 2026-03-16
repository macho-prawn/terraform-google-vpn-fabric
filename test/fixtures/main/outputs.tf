locals {
  gateway = one(values(module.vpn_infra.gateways))

  src_tunnel_names = sort([
    for tunnel in values(module.vpn_infra.tunnels) :
    "tunnel-${tunnel.peer1_gws.env_name}-${tunnel.peer1_gws.gw_index[0]}-${tunnel.peer1_gws.region_abbr}-${tunnel.peer1_tunnels.tunnel_name}"
  ])

  dst_tunnel_names = sort([
    for tunnel in values(module.vpn_infra.tunnels) :
    "tunnel-${tunnel.peer2_gws.env_name}-${tunnel.peer2_gws.gw_index[0]}-${tunnel.peer2_gws.region_abbr}-${tunnel.peer2_tunnels.tunnel_name}"
  ])
}

output "src_project_id" {
  value = local.gateway.peer1_gws.project
}

output "dst_project_id" {
  value = local.gateway.peer2_gws.project
}

output "src_region" {
  value = local.gateway.peer1_gws.region
}

output "dst_region" {
  value = local.gateway.peer2_gws.region
}

output "src_router_name" {
  value = "cr-${local.gateway.peer1_gws.env_name}-${local.gateway.peer1_gws.gw_index[0]}-${local.gateway.peer1_gws.region_abbr}-${local.gateway.peer1_gws.gw_name}"
}

output "dst_router_name" {
  value = "cr-${local.gateway.peer2_gws.env_name}-${local.gateway.peer2_gws.gw_index[0]}-${local.gateway.peer2_gws.region_abbr}-${local.gateway.peer2_gws.gw_name}"
}

output "src_gateway_name" {
  value = "gw-${local.gateway.peer1_gws.env_name}-${local.gateway.peer1_gws.gw_index[0]}-${local.gateway.peer1_gws.region_abbr}-${local.gateway.peer1_gws.gw_name}"
}

output "dst_gateway_name" {
  value = "gw-${local.gateway.peer2_gws.env_name}-${local.gateway.peer2_gws.gw_index[0]}-${local.gateway.peer2_gws.region_abbr}-${local.gateway.peer2_gws.gw_name}"
}

output "src_tunnel_names" {
  value = local.src_tunnel_names
}

output "dst_tunnel_names" {
  value = local.dst_tunnel_names
}
