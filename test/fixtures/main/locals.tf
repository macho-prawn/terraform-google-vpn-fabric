locals {
  vpn_env_details = [
    {
      org_name = "db"
      org_secret = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key.secret
      org_secret_version = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key.secret_version
      env = [{
        env_name = "ctl"
        sub_env = [{
          sub_env_name = "native"
          project      = data.terraform_remote_state.sensitive_state.outputs.src_host_project_id
          region       = "europe-west3"
          vpc          = data.terraform_remote_state.sensitive_state.outputs.src_shared_vpc.name
          gw = [{
            asn     = 4288348160
            gw_name = "g0-internal-01"
            tunnels = [{
              bgp_peer_routes = "10.1.1.0/24"
              interface       = 1
              tunnel_name     = "g0-internal-02"
              #t_secret     = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_1.secret
              #t_secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_1.secret_version
              },
              {
                bgp_peer_routes = "10.1.1.0/24"
                interface       = 0
                tunnel_name     = "g0-internal-01"
                #secret     = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_default.secret
                #version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_default.version
            }]
          }]
        }]
        },
        {
          env_name = "dev"
          sub_env = [{
            sub_env_name = "g0"
            project      = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id
            region       = "europe-west3"
            psk          = "vpn_preshared_key"
            vpc          = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc.name
            gw = [{
              asn     = 4289724416
              gw_name = "g0-internal-01"
              tunnels = [{
                bgp_peer_routes = "192.168.1.0/24"
                interface       = 1
                tunnel_name     = "g0-internal-02"
               # t_secret     = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_1.secret
               # t_secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_1.secret_version
                },
                {
                  bgp_peer_routes = "192.168.1.0/24"
                  interface       = 0
                  tunnel_name     = "g0-internal-01"
                  #   secret   = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_default.secret
                  # version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_default.version

              }]
            }]
          }]
      }]
    }
  ]
}
