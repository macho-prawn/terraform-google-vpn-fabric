locals {
  vpn_env_details = [
    {
      org_name = "dbc"
      env = [{
        env_name = "ctl"
        sub_env = [{
          sub_env_name = "native"
          project = {
            name = data.terraform_remote_state.sensitive_state.outputs.src_host_project_id
          }
          gw = [{
            gw_name = "native-internal-01"
            region  = "europe-west3"
            vpc     = data.terraform_remote_state.sensitive_state.outputs.src_shared_vpc.name
            asn     = 4288348160
            tunnels = {
              dev_g0_if1 = {
                bgp_peer_routes = ["10.1.1.0/24"]
                interface       = 1
                tunnel_name     = "native-internal-02"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "dev"
                  sub_env_name = "g0"
                  gw_name      = "g0-internal-01"
                  tunnel_key   = "src_if1"
                }
              }
              dev_g0_if0 = {
                bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
                interface       = 0
                tunnel_name     = "native-internal-01"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "dev"
                  sub_env_name = "g0"
                  gw_name      = "g0-internal-01"
                  tunnel_key   = "src_if0"
                }
              }
              dev_native_if1 = {
                bgp_peer_routes = ["10.1.1.0/24"]
                interface       = 1
                tunnel_name     = "native-internal-04"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "dev"
                  sub_env_name = "native"
                  gw_name      = "native-internal-01"
                  tunnel_key   = "src_if1"
                }
              }
              dev_native_if0 = {
                bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
                interface       = 0
                tunnel_name     = "native-internal-03"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "dev"
                  sub_env_name = "native"
                  gw_name      = "native-internal-01"
                  tunnel_key   = "src_if0"
                }
              }
              dev_dws_if1 = {
                bgp_peer_routes = ["10.1.1.0/24"]
                interface       = 1
                tunnel_name     = "native-internal-06"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "dev"
                  sub_env_name = "dws"
                  gw_name      = "dws-native-internal-01"
                  tunnel_key   = "src_if1"
                }
              }
              dev_dws_if0 = {
                bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
                interface       = 0
                tunnel_name     = "native-internal-05"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "dev"
                  sub_env_name = "dws"
                  gw_name      = "dws-native-internal-01"
                  tunnel_key   = "src_if0"
                }
              }
              uat_native_if1 = {
                bgp_peer_routes = ["10.1.1.0/24"]
                interface       = 1
                tunnel_name     = "native-internal-08"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "uat"
                  sub_env_name = "native"
                  gw_name      = "native-internal-01"
                  tunnel_key   = "src_if1"
                }
              }
              uat_native_if0 = {
                bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
                interface       = 0
                tunnel_name     = "native-internal-07"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "uat"
                  sub_env_name = "native"
                  gw_name      = "native-internal-01"
                  tunnel_key   = "src_if0"
                }
              }
              uat_dws_if1 = {
                bgp_peer_routes = ["10.1.1.0/24"]
                interface       = 1
                tunnel_name     = "native-internal-10"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "uat"
                  sub_env_name = "dws"
                  gw_name      = "dws-native-internal-01"
                  tunnel_key   = "src_if1"
                }
              }
              uat_dws_if0 = {
                bgp_peer_routes = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
                interface       = 0
                tunnel_name     = "native-internal-09"
                secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                peer = {
                  env_name     = "uat"
                  sub_env_name = "dws"
                  gw_name      = "dws-native-internal-01"
                  tunnel_key   = "src_if0"
                }
              }
            }
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
            gw = [{
              gw_name = "g0-internal-01"
              region  = "europe-west3"
              vpc     = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_1.name
              asn     = 4289724416
              tunnels = {
                src_if1 = {
                  bgp_peer_routes = ["192.168.1.0/24", "192.168.2.0/24"]
                  interface       = 1
                  tunnel_name     = "g0-internal-02"
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "dev_g0_if1"
                  }
                }
                src_if0 = {
                  bgp_peer_routes = ["192.168.1.0/24"]
                  interface       = 0
                  tunnel_name     = "g0-internal-01"
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "dev_g0_if0"
                  }
                }
              }
            }]
          }]
        },
        {
          env_name = "dev"
          sub_env = [{
            sub_env_name = "native"
            project = {
              name = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_2
            }
            gw = [{
              gw_name = "native-internal-01"
              region  = "europe-west3"
              vpc     = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_2.name
              asn     = 4289724416
              tunnels = {
                src_if1 = {
                  bgp_peer_routes = ["192.168.3.0/24", "192.168.4.0/24", "192.168.5.0/24", "192.168.6.0/24"]
                  interface       = 1
                  tunnel_name     = "native-internal-02"
                  secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                  secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "dev_native_if1"
                  }
                }
                src_if0 = {
                  bgp_peer_routes = ["192.168.6.0/24"]
                  interface       = 0
                  tunnel_name     = "native-internal-01"
                  secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                  secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "dev_native_if0"
                  }
                }
              }
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
            gw = [{
              gw_name = "dws-native-internal-01"
              region  = "europe-west3"
              vpc     = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_3.name
              asn     = 4289724416
              tunnels = {
                src_if1 = {
                  bgp_peer_routes = ["192.168.7.0/24", "192.168.8.0/24", "192.168.9.0/24", "192.168.10.0/24", "192.168.11.0/24"]
                  interface       = 1
                  tunnel_name     = "dws-native-internal-02"
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "dev_dws_if1"
                  }
                }
                src_if0 = {
                  bgp_peer_routes = ["192.168.10.0/24"]
                  interface       = 0
                  tunnel_name     = "dws-native-internal-01"
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "dev_dws_if0"
                  }
                }
              }
            }]
          }]
        },
        {
          env_name = "uat"
          sub_env = [{
            sub_env_name = "native"
            project = {
              name = data.terraform_remote_state.sensitive_state.outputs.dst_host_project_id_4
            }
            gw = [{
              gw_name = "native-internal-01"
              region  = "europe-west3"
              vpc     = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_4.name
              asn     = 4289724416
              tunnels = {
                src_if1 = {
                  bgp_peer_routes = ["192.168.12.0/24", "192.168.13.0/24"]
                  interface       = 1
                  tunnel_name     = "native-internal-02"
                  secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                  secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "uat_native_if1"
                  }
                }
                src_if0 = {
                  bgp_peer_routes = ["192.168.14.0/24"]
                  interface       = 0
                  tunnel_name     = "native-internal-01"
                  secret          = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret
                  secret_version  = data.terraform_remote_state.sensitive_state.outputs.vpn_preshared_key_tunnel.secret_version
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "uat_native_if0"
                  }
                }
              }
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
            gw = [{
              gw_name = "dws-native-internal-01"
              region  = "europe-west3"
              vpc     = data.terraform_remote_state.sensitive_state.outputs.dst_shared_vpc_5.name
              asn     = 4289724416
              tunnels = {
                src_if1 = {
                  bgp_peer_routes = ["192.168.15.0/24", "192.168.16.0/24"]
                  interface       = 1
                  tunnel_name     = "dws-native-internal-02"
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "uat_dws_if1"
                  }
                }
                src_if0 = {
                  bgp_peer_routes = ["192.168.17.0/24"]
                  interface       = 0
                  tunnel_name     = "dws-native-internal-01"
                  peer = {
                    env_name     = "ctl"
                    sub_env_name = "native"
                    gw_name      = "native-internal-01"
                    tunnel_key   = "uat_dws_if0"
                  }
                }
              }
            }]
          }]
      }]
    }
  ]
}
