locals {
  vpn_env_details = [
    {
      org_name = "dbc"
      env = [{
        env_name = "ctl"
        sub_env = [{
          sub_env_name = "native"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.src_host_project_id
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.src_shared_vpc.name
          gw = [{
            asn     = 4288348160
            gw_name = "native-internal-01"
            tunnels = [{
              bgp_peer_routes = ["10.1.1.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-02"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-01"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-04"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-03"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-06"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-05"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-08"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-07"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-10"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-09"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            }]
          }]
        }]
      },
      {
        env_name = "dev"
        sub_env = [{
          sub_env_name = "g0"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_1
            secret         = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret
            secret_version = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret_version
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_1.name
          gw = [{
            asn     = 4289724416
            gw_name = "g0-internal-01"
            tunnels = [{
              bgp_peer_routes = ["192.168.1.0/24", "192.168.2.0/24"]
              interface       = 1
              tunnel_name     = "g0-internal-02"
            },
            {
              bgp_peer_routes = ["192.168.1.0/24"]
              interface       = 0
              tunnel_name     = "g0-internal-01"
            }]
          }]
        }]
      },
      {
        env_name = "dev"
        sub_env = [{
          sub_env_name = "native"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_2
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_2.name
          gw = [{
            asn     = 4289724416
            gw_name = "native-internal-01"
            tunnels = [{
              bgp_peer_routes = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-02"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["192.168.6.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-01"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            }]
          }]
        }]
      },
      {
        env_name = "dev"
        sub_env = [{
          sub_env_name = "dws"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_3
            secret         = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret
            secret_version = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret_version
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_3.name
          gw = [{
            asn     = 4289724416
            gw_name = "dws-native-internal-01"
            tunnels = [{
              bgp_peer_routes = ["192.168.7.0/24", "192.168.8.0/24", "192.168.9.0/24", "192.168.10.0/24", "192.168.11.0/24"]
              interface       = 1
              tunnel_name     = "dws-native-internal-02"
            },
            {
              bgp_peer_routes = ["192.168.10.0/24"]
              interface       = 0
              tunnel_name     = "dws-native-internal-01"
            }]
          }]
        }]
      },
      {
        env_name = "uat"
        sub_env = [{
          sub_env_name = "native"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_4

          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_4.name
          gw = [{
            asn     = 4289724416
            gw_name = "native-internal-01"
            tunnels = [{
              bgp_peer_routes = ["192.168.12.0/24", "192.168.13.0/24"]
              interface       = 1
              tunnel_name     = "native-internal-02"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            },
            {
              bgp_peer_routes = ["192.168.14.0/24"]
              interface       = 0
              tunnel_name     = "native-internal-01"
              secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
              secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
            }]
          }]
        }]
      },
      {
        env_name = "uat"
        sub_env = [{
          sub_env_name = "dws"
          project = {
            name           = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_5
            secret         = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret
            secret_version = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_project.secret_version
          }
          region = "europe-west3"
          vpc    = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_5.name
          gw = [{
            asn     = 4289724416
            gw_name = "dws-native-internal-01"
            tunnels = [{
              bgp_peer_routes = ["192.168.15.0/24", "192.168.16.0/24"]
              interface       = 1
              tunnel_name     = "dws-native-internal-02"
            },
            {
              bgp_peer_routes = ["192.168.17.0/24"]
              interface       = 0
              tunnel_name     = "dws-native-internal-01"
            }]
          }]
        }]
      },
      ]
    }
  ]
}
