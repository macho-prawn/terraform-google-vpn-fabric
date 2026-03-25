# terraform-google-vpn-fabric

Provision Google Cloud HA VPN gateways, Cloud Routers, tunnels, and BGP peers from a nested Terraform input model. Gateway inventory stays nested under environments, while tunnel pairing is expressed explicitly per tunnel and `vpn_adjacency` provides source-to-destination direction.

## Table of Contents

- [Requirements](#requirements)
- [Providers](#providers)
- [Usage](#usage)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Validation Rules](#validation-rules)
- [Naming Behavior](#naming-behavior)

## Requirements

- Terraform `>= 1.12.0`

## Providers

- `hashicorp/google`

The module does not configure the provider for you. The caller must supply Google provider configuration and credentials.

## Usage

```hcl
module "vpn_fabric" {
  source = "path/to/terraform-google-vpn-fabric"

  vpn_adjacency = {
    ctl-native = ["dev-g0"]
  }

  vpn_env_details = [
    {
      org_name = "db"
      env = [
        {
          env_name = "ctl"
          sub_env = [
            {
              sub_env_name = "native"
              region       = "europe-west3"
              vpc          = "projects/example/global/networks/ctl-native-vpc-01"
              project = {
                name           = "ctl-host-project"
                secret         = "vpn-shared-secret"
                secret_version = "1"
              }
              gw = [
                {
                  gw_name = "g0-internal-01"
                  asn     = 64512
                  tunnels = {
                    dev_g0_if0 = {
                      tunnel_name     = "if0"
                      interface       = 0
                      bgp_peer_routes = ["10.10.0.0/24"]
                      peer = {
                        env_name     = "dev"
                        sub_env_name = "g0"
                        gw_name      = "dev-edge-01"
                        tunnel_key   = "ctl_if0"
                      }
                    }
                    dev_g0_if1 = {
                      tunnel_name     = "if1"
                      interface       = 1
                      bgp_peer_routes = ["10.10.1.0/24", "10.10.2.0/24"]
                      peer = {
                        env_name     = "dev"
                        sub_env_name = "g0"
                        gw_name      = "dev-edge-01"
                        tunnel_key   = "ctl_if1"
                      }
                    }
                  }
                }
              ]
            }
          ]
        },
        {
          env_name = "dev"
          sub_env = [
            {
              sub_env_name = "g0"
              region       = "europe-west3"
              vpc          = "projects/example/global/networks/dev-g0-vpc-01"
              project = {
                name           = "dev-host-project"
                secret         = "vpn-shared-secret"
                secret_version = "1"
              }
              gw = [
                {
                  gw_name = "dev-edge-01"
                  asn     = 64513
                  tunnels = {
                    ctl_if0 = {
                      tunnel_name     = "if0"
                      interface       = 0
                      bgp_peer_routes = ["192.168.10.0/24"]
                      peer = {
                        env_name     = "ctl"
                        sub_env_name = "native"
                        gw_name      = "g0-internal-01"
                        tunnel_key   = "dev_g0_if0"
                      }
                    }
                    ctl_if1 = {
                      tunnel_name     = "if1"
                      interface       = 1
                      bgp_peer_routes = ["192.168.11.0/24", "192.168.12.0/24"]
                      peer = {
                        env_name     = "ctl"
                        sub_env_name = "native"
                        gw_name      = "g0-internal-01"
                        tunnel_key   = "dev_g0_if1"
                      }
                    }
                  }
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
```

## Inputs

### `vpn_adjacency`

`map(list(string))` of environment adjacencies. Keys and values use the environment key format:

- `${env_name}-${sub_env_name}`

Example:

```hcl
vpn_adjacency = {
  ctl-native = ["dev-g0"]
}
```

### `vpn_env_details`

Nested description of organizations, environments, sub-environments, projects, gateways, and tunnels.

Important fields:

- `org_name`: top-level organization label for the environment set
- `env[].env_name`: environment name
- `env[].sub_env[].sub_env_name`: sub-environment name
- `env[].sub_env[].region`: GCP region for the gateway/router resources
- `env[].sub_env[].project.name`: target project ID
- `env[].sub_env[].project.secret` and `secret_version`: optional project-level fallback for tunnel shared secrets
- `env[].sub_env[].vpc`: network self-link/name used by the HA VPN gateway and Cloud Router
- `env[].sub_env[].gw[].gw_name`: gateway identifier used in resource names and outputs
- `env[].sub_env[].gw[].asn`: local router ASN
- `env[].sub_env[].gw[].tunnels`: map of tunnel definitions keyed by a stable local tunnel key

Tunnel fields:

- `tunnel_name`
- `interface`
- `bgp_peer_routes`: one or more CIDRs as `list(string)`
- optional `secret`
- optional `secret_version`
- `peer.env_name`
- `peer.sub_env_name`
- `peer.gw_name`
- `peer.tunnel_key`

## Outputs

### `gateways`

Map of resolved gateway pairs keyed by adjacency, peer1 gateway name, and peer2 gateway name. Each value includes the concrete `peer1_gws` and `peer2_gws` objects used to build routers, gateways, and tunnels.

### `router_map`

Map of concrete router definitions keyed by `gateway_key`. Each value includes the resolved router name, project, region, network, ASN, and gateway metadata.

### `tunnels`

Map of resolved tunnel pairs keyed by the explicit source tunnel lookup key and remote tunnel lookup key. Each value includes both peer tunnel definitions plus the resolved secret references.

## Validation Rules

- A given `${env_name}-${sub_env_name}` can contain multiple gateways, but each `gw_name` must be unique within that environment key.
- Every tunnel peer reference must resolve to an existing remote tunnel and be declared reciprocally.
- Every reciprocal tunnel pair must match exactly one directed `vpn_adjacency` edge.
- Every tunnel endpoint can be targeted by at most one remote tunnel.
- Paired tunnels must use the same interface.
- Each tunnel pair must resolve both a secret name and secret version, either from the tunnel or from the parent project block.

## Naming Behavior

- Cloud Routers are named as `cr-<env>-<vpc-index>-<region-abbr>-<gw_name>`
- HA VPN gateways are named as `gw-<env>-<vpc-index>-<region-abbr>-<gw_name>`
- VPN tunnels are named as `tunnel-<env>-<vpc-index>-<region-abbr>-<gw_name>-<tunnel_name>`

Including `gw_name` in tunnel names avoids collisions when an environment contains multiple gateways.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_ha_vpn_gateway.gateway](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_ha_vpn_gateway) | resource |
| [google_compute_router.router](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_interface.peer1_cloud_router_interface](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_interface.peer2_cloud_router_interface](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_interface) | resource |
| [google_compute_router_peer.peer1_router_peer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_router_peer.peer2_router_peer](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_peer) | resource |
| [google_compute_vpn_tunnel.peer1_tunnel_0](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [google_compute_vpn_tunnel.peer1_tunnel_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [google_compute_vpn_tunnel.peer2_tunnel_0](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [google_compute_vpn_tunnel.peer2_tunnel_1](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_vpn_tunnel) | resource |
| [null_resource.resolved_tunnel_secrets_guard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_vpn_adjacency"></a> [vpn\_adjacency](#input\_vpn\_adjacency) | A map of all the source/destination workload/environments | `map(list(string))` | <pre>{<br>  "ctl-native": [<br>    "dev-g0",<br>    "dev-native",<br>    "dev-dws",<br>    "uat-native",<br>    "uat-dws",<br>    "prd-native",<br>    "prd-dws"<br>  ],<br>  "dev-g0": [<br>    "dev-g0-dms",<br>    "dev-g0-vpc02"<br>  ],<br>  "dev-native": [<br>    "dev-vpc02",<br>    "dev-dws",<br>    "dev-dms"<br>  ],<br>  "prd-native": [<br>    "prd-vpc02",<br>    "prd-dws",<br>    "prd-dms"<br>  ],<br>  "tfe-prd": [<br>    "prd-native"<br>  ],<br>  "tfe-preprd-zeus": [<br>    "prd-native"<br>  ],<br>  "tfe-sparta": [<br>    "dev-native"<br>  ],<br>  "uat-native": [<br>    "uat-vpc02",<br>    "uat-dws",<br>    "uat-02",<br>    "uat-dms"<br>  ]<br>}</pre> | no |
| <a name="input_vpn_env_details"></a> [vpn\_env\_details](#input\_vpn\_env\_details) | A map of all the Src/Dst HA VPN GW/Tunnels | <pre>list(object({<br>    org_name = string<br>    env = list(object({<br>      env_name = string<br>      sub_env = list(object({<br>        sub_env_name = string<br>        region       = string<br>        project = object({<br>          name           = string<br>          secret         = optional(string, null)<br>          secret_version = optional(string, null)<br>        })<br>        vpc = string<br>        gw = list(object({<br>          gw_name = string<br>          asn     = number<br>          tunnels = map(object({<br>            tunnel_name     = string<br>            interface       = number<br>            bgp_peer_routes = list(string)<br>            secret          = optional(string, null)<br>            secret_version  = optional(string, null)<br>            peer = object({<br>              env_name     = string<br>              sub_env_name = string<br>              gw_name      = string<br>              tunnel_key   = string<br>            })<br>          }))<br>        }))<br>      }))<br>    }))<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateways"></a> [gateways](#output\_gateways) | n/a |
| <a name="output_router_map"></a> [router\_map](#output\_router\_map) | n/a |
| <a name="output_tunnels"></a> [tunnels](#output\_tunnels) | n/a |
