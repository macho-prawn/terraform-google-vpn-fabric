check "unique_gateway_names_per_env_key" {
  assert {
    condition     = length(local.duplicate_gateway_names_by_env_key) == 0
    error_message = "Each env_key must resolve each gw_name exactly once. Duplicate env_key/gw_name values found for: ${join(", ", local.duplicate_gateway_names_by_env_key)}"
  }
}

check "matched_gateway_names_per_adjacency" {
  assert {
    condition     = length(local.adjacency_keys_with_unmatched_gateways) == 0
    error_message = "Each adjacency can only pair gateways with matching gw_name values on both sides. Unmatched gateways found for: ${join(", ", local.adjacency_keys_with_unmatched_gateways)}"
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
  }

  lifecycle {
    precondition {
      condition     = length(local.tunnel_keys_with_missing_secret) == 0
      error_message = "Each tunnel pair must resolve both secret name and version via tunnel-level or project-level configuration. Missing secrets for: ${join(", ", local.tunnel_keys_with_missing_secret)}"
    }
  }
}
