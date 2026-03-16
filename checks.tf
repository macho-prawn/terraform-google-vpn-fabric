check "single_gateway_per_env_key" {
  assert {
    condition     = length(local.env_keys_with_multiple_gateways) == 0
    error_message = "Each env_key must resolve to exactly one gateway. Duplicate env_key values found for: ${join(", ", local.env_keys_with_multiple_gateways)}"
  }
}

check "resolved_tunnel_secrets" {
  assert {
    condition     = length(local.tunnel_keys_with_missing_secret) == 0
    error_message = "Each tunnel pair must resolve both secret name and version via tunnel-level or project-level configuration. Missing secrets for: ${join(", ", local.tunnel_keys_with_missing_secret)}"
  }
}

resource "terraform_data" "resolved_tunnel_secrets_guard" {
  input = local.tunnel_keys_with_missing_secret

  lifecycle {
    precondition {
      condition     = length(local.tunnel_keys_with_missing_secret) == 0
      error_message = "Each tunnel pair must resolve both secret name and version via tunnel-level or project-level configuration. Missing secrets for: ${join(", ", local.tunnel_keys_with_missing_secret)}"
    }
  }
}
