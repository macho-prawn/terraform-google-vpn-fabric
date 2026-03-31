check "unique_gateway_names_per_env_key" {
  assert {
    condition     = length(local.duplicate_gateway_names_by_env_key) == 0
    error_message = "Each env_key must resolve each gw_name exactly once. Duplicate env_key/gw_name values found for: ${join(", ", local.duplicate_gateway_names_by_env_key)}"
  }
}

check "tunnel_peer_targets_exist" {
  assert {
    condition     = length(local.tunnel_link_missing_peer_targets) == 0
    error_message = "Each tunnel peer reference must resolve to an existing remote tunnel. Missing peer targets for: ${join(", ", local.tunnel_link_missing_peer_targets)}"
  }
}

check "tunnel_peer_links_are_reciprocal" {
  assert {
    condition     = length(local.tunnel_link_reciprocity_mismatches) == 0
    error_message = "Each tunnel pair must declare reciprocal peer references. Reciprocity mismatches for: ${join(", ", local.tunnel_link_reciprocity_mismatches)}"
  }
}

check "tunnel_peer_targets_are_unique" {
  assert {
    condition     = length(local.tunnel_peer_targets_with_multiple_sources) == 0
    error_message = "Each tunnel endpoint may be targeted by at most one remote tunnel. Conflicting targets: ${join(", ", local.tunnel_peer_targets_with_multiple_sources)}"
  }
}

check "tunnel_pairs_match_declared_adjacency" {
  assert {
    condition     = length(local.tunnel_link_adjacency_errors) == 0
    error_message = "Each reciprocal tunnel pair must match a declared vpn_adjacency in one direction. Missing adjacency for: ${join(", ", local.tunnel_link_adjacency_errors)}"
  }
}

check "tunnel_pairs_have_unambiguous_direction" {
  assert {
    condition     = length(local.tunnel_link_ambiguous_adjacency) == 0
    error_message = "Each reciprocal tunnel pair must match vpn_adjacency in exactly one direction. Ambiguous adjacency for: ${join(", ", local.tunnel_link_ambiguous_adjacency)}"
  }
}

check "tunnel_pair_interfaces_match" {
  assert {
    condition     = length(local.tunnel_link_interface_mismatches) == 0
    error_message = "Paired tunnels must use the same interface. Interface mismatches for: ${join(", ", local.tunnel_link_interface_mismatches)}"
  }
}

check "tunnel_pair_regions_match" {
  assert {
    condition     = length(local.tunnel_link_region_mismatches) == 0
    error_message = "Paired VPN gateways must use the same region. Region mismatches for: ${join(", ", local.tunnel_link_region_mismatches)}"
  }
}

check "resolved_tunnel_secrets" {
  assert {
    condition     = length(local.tunnel_keys_with_missing_secret) == 0
    error_message = "Each tunnel pair must resolve both secret name and version via tunnel-level or project-level configuration. Missing secrets for: ${join(", ", local.tunnel_keys_with_missing_secret)}"
  }
}

resource "null_resource" "resolved_tunnel_secrets_guard" {
  triggers = {
    missing_tunnel_keys = join(",", local.tunnel_keys_with_missing_secret)
    region_mismatch_keys = join(",", local.tunnel_link_region_mismatches)
  }

  lifecycle {
    precondition {
      condition     = length(local.tunnel_link_region_mismatches) == 0
      error_message = "Paired VPN gateways must use the same region. Region mismatches for: ${join(", ", local.tunnel_link_region_mismatches)}"
    }

    precondition {
      condition     = length(local.tunnel_keys_with_missing_secret) == 0
      error_message = "Each tunnel pair must resolve both secret name and version via tunnel-level or project-level configuration. Missing secrets for: ${join(", ", local.tunnel_keys_with_missing_secret)}"
    }
  }
}
