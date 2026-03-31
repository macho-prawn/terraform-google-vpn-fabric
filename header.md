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
              project = {
                name           = "ctl-host-project"
                secret         = "vpn-shared-secret"
                secret_version = "1"
              }
              gw = [
                {
                  gw_name = "g0-internal-01"
                  region  = "europe-west3"
                  vpc     = "projects/example/global/networks/ctl-native-vpc-01"
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
              project = {
                name           = "dev-host-project"
                secret         = "vpn-shared-secret"
                secret_version = "1"
              }
              gw = [
                {
                  gw_name = "dev-edge-01"
                  region  = "europe-west3"
                  vpc     = "projects/example/global/networks/dev-g0-vpc-01"
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
- `env[].sub_env[].project.name`: target project ID
- `env[].sub_env[].project.secret` and `secret_version`: optional project-level fallback for tunnel shared secrets
- `env[].sub_env[].gw[].gw_name`: gateway identifier used in resource names and outputs
- `env[].sub_env[].gw[].region`: GCP region for this gateway and its router/tunnels
- `env[].sub_env[].gw[].vpc`: network self-link/name used by this gateway and router
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
- Paired source and destination VPN gateways must use the same region.
- Each tunnel pair must resolve both a secret name and secret version, either from the tunnel or from the parent project block.

## Naming Behavior

- Cloud Routers are named as `cr-<env>-<vpc-index>-<region-abbr>-<gw_name>`
- HA VPN gateways are named as `gw-<env>-<vpc-index>-<region-abbr>-<gw_name>`
- VPN tunnels are named as `tunnel-<env>-<vpc-index>-<region-abbr>-<gw_name>-<tunnel_name>`

Including `gw_name` in tunnel names avoids collisions when an environment contains multiple gateways.
