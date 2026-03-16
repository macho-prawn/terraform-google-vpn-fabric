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
    org_secret = optional(string, null)
    org_secret_version = optional(string, null)
    env = list(object({
      env_name = string
      sub_env = list(object({
        sub_env_name = string
        region       = string
        project      = string
        vpc          = string
        gw = list(object({
          gw_name = string
          asn     = number
          tunnels = list(object({
            tunnel_name     = string
            interface       = number
            bgp_peer_routes = string
            #t_secret     = optional(string, null)
            #t_secret_version  = optional(string, null)
          }))
        }))
      }))
    }))
  }))
  description = "A map of all the Src/Dst HA VPN GW/Tunnels"
  default     = []
}

variable "vpn_preshared_key" {
  type = object({
    secret = string
    secret_version = string
  })
   default = {
    secret         = ""
    secret_version = null
  }
}

variable "vpn_preshared_key_1" {
  type = map(object({
    secret = string
    secret_version = string
  }))
   default = {  }
}
