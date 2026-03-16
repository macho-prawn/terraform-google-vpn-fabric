# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [Unreleased]

### Added

- Added support for Google Cloud HA VPN Farm defined from Terraform inputs for environment adjacency and nested gateway details.
- Added support for multiple HA VPN gateways within the same `${env_name}-${sub_env_name}` environment key.
- Added support for per-tunnel or per-project secret resolution via Secret Manager secret name and version references.
- Added support for one or more advertised BGP peer route CIDRs per tunnel via `bgp_peer_routes = list(string)`.
- Added outputs for resolved gateway pairs and tunnel pairs.
- Added validation to ensure each `gw_name` is unique within an environment key.
- Added validation to ensure environment adjacencies only resolve gateway pairs with matching `gw_name` values.
- Added validation to ensure each tunnel pair resolves both a secret name and secret version.

### Changed

- Changed gateway resolution from single-gateway-per-environment to same-`gw_name` pairing across adjacent environments.
- Changed router and HA VPN gateway resources to be created once per concrete gateway instead of once per adjacency.
- Changed tunnel naming to include `gw_name` to avoid collisions when multiple gateways exist in the same environment.
- Changed the documented module contract to center on Terraform `>= 1.12.0`, `hashicorp/google`, `vpn_adjacency` as `map(list(string))`, and `vpn_env_details` as the nested environment, project, gateway, and tunnel definition model.
- Changed test fixtures and integration assertions to cover multiple gateways per environment adjacency.

### Documentation

- Added a concise Terraform-centric README covering requirements, provider expectations, usage, inputs, outputs, validation rules, and naming behavior.
