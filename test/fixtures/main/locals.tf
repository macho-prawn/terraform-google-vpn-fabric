locals {
  vpn_env_details = [
    {
      org_name = "db"
      env = [{
        env_name = "ctl"
        sub_env = [{
          sub_env_name = "native"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.src_host_project_id
            secret         = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret
            secret_version = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret_version
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.src_shared_vpc.name
          gw = [{
            asn     = 4288348160
            gw_name = "g0-internal-01"
            tunnels = [{
              bgp_peer_routes = "10.1.1.0/24"
              interface       = 1
              tunnel_name     = "g0-internal-02"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.version
            },
            {
              bgp_peer_routes = "10.1.1.0/24"
              interface       = 0
              tunnel_name     = "g0-internal-01"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.version
            }]
          }]
        }]
      },
      {
        env_name = "dev"
        sub_env = [{
          sub_env_name = "g0"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id
            secret         = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret
            secret_version = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret_version
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc.name
          gw = [{
            asn     = 4289724416
            gw_name = "g0-internal-01"
            tunnels = [{
              bgp_peer_routes = "192.168.1.0/24"
              interface       = 1
              tunnel_name     = "g0-internal-02"
            },
            {
              bgp_peer_routes = "192.168.1.0/24"
              interface       = 0
              tunnel_name     = "g0-internal-01"
            }]
          }]
        }]
      }]
    }
  ]
}
