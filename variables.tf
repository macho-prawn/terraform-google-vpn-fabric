variable "vpn_adjacency" {
  type        = map(list(string))
  description = "A map of all the source/destination workload/environments"
  default = {
    ctl-native      = ["dev-g0", "dev-native", "dev-dws", "uat-native", "uat-dws", "prd-native", "prd-dws"]
    tfe-sparta      = ["dev-native"]
    tfe-preprd-zeus = ["prd-native"]
    tfe-prd         = ["prd-native"]
    dev-g0          = ["dev-g0-dms", "dev-g0-vpc02"]
    dev-native      = ["dev-vpc02", "dev-dws", "dev-dms"]
    uat-native      = ["uat-vpc02", "uat-dws", "uat-02", "uat-dms"]
    prd-native      = ["prd-vpc02", "prd-dws", "prd-dms"]
  }
}

variable "vpn_env_details" {
  type = list(object({
    org_name = string
    env = list(object({
      env_name = string
      sub_env = list(object({
        sub_env_name = string
        region       = string
        project = object({
          name           = string
          secret         = optional(string, null)
          secret_version = optional(string, null)
        })
        vpc = string
        gw = list(object({
          gw_name = string
          asn     = number
          tunnels = list(object({
            tunnel_name     = string
            interface       = number
            bgp_peer_routes = list(string)
            secret          = optional(string, null)
            secret_version  = optional(string, null)
          }))
        }))
      }))
    }))
  }))
  description = "A map of all the Src/Dst HA VPN GW/Tunnels"
  default     = []
}
