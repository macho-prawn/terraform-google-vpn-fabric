# terraform-google-vpn-fabric

Provision Google Cloud HA VPN gateways, Cloud Routers, tunnels, and BGP peers from a nested Terraform input model. Environment adjacencies stay environment-level, while concrete gateway pairs are matched by shared `gw_name`.

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
                  tunnels = [
                    {
                      tunnel_name     = "if0"
                      interface       = 0
                      bgp_peer_routes = ["10.10.0.0/24"]
                    },
                    {
                      tunnel_name     = "if1"
                      interface       = 1
                      bgp_peer_routes = ["10.10.1.0/24", "10.10.2.0/24"]
                    }
                  ]
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
                  gw_name = "g0-internal-01"
                  asn     = 64513
                  tunnels = [
                    {
                      tunnel_name     = "if0"
                      interface       = 0
                      bgp_peer_routes = ["192.168.10.0/24"]
                    },
                    {
                      tunnel_name     = "if1"
                      interface       = 1
                      bgp_peer_routes = ["192.168.11.0/24", "192.168.12.0/24"]
                    }
                  ]
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
- `env[].sub_env[].gw[].gw_name`: gateway name used for pairing across adjacent environments
- `env[].sub_env[].gw[].asn`: local router ASN
- `env[].sub_env[].gw[].tunnels[]`: interface-specific tunnel definitions

Tunnel fields:

- `tunnel_name`
- `interface`
- `bgp_peer_routes`: one or more CIDRs as `list(string)`
- optional `secret`
- optional `secret_version`

## Outputs

### `gateways`

Map of resolved gateway pairs keyed by adjacency and `gw_name`. Each value includes the concrete `peer1_gws` and `peer2_gws` objects used to build routers, gateways, and tunnels.

### `tunnels`

Map of resolved tunnel pairs keyed by adjacency, gateway name, and interface. Each value includes both peer tunnel definitions plus the resolved secret references.

## Validation Rules

- A given `${env_name}-${sub_env_name}` can contain multiple gateways, but each `gw_name` must be unique within that environment key.
- For any adjacency, gateways are paired only when both sides contain the same `gw_name`.
- If one side has a `gw_name` with no match on the other side, the module fails validation.
- Each tunnel pair must resolve both a secret name and secret version, either from the tunnel or from the parent project block.

## Naming Behavior

- Cloud Routers are named as `cr-<env>-<vpc-index>-<region-abbr>-<gw_name>`
- HA VPN gateways are named as `gw-<env>-<vpc-index>-<region-abbr>-<gw_name>`
- VPN tunnels are named as `tunnel-<env>-<vpc-index>-<region-abbr>-<gw_name>-<tunnel_name>`

Including `gw_name` in tunnel names avoids collisions when an environment contains multiple gateways.
