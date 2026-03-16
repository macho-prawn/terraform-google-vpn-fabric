locals {
  apis = [
    "compute.googleapis.com",
    "logging.googleapis.com",
    "secretmanager.googleapis.com"
  ]

  vpn_adjacency = {
    ctl-native      = ["dev-g0", "dev-native", "dev-dws", "uat-native", "uat-dws", "prd-native", "prd-dws"]
    tfe-sparta      = ["dev-native"]
    tfe-preprd-zeus = ["prd-native"]
    tfe-prd         = ["prd-native"]
    dev-g0          = ["dev-g0-dms", "dev-g0-vpc02"]
    dev-native      = ["dev-vpc02", "dev-dws", "dev-dms"]
    uat-native      = ["uat-vpc02", "uat-dws", "uat-02", "uat-dms"]
    prd-native      = ["prd-vpc02", "prd-dws", "prd-dms"]
  }

    # flat list of all value names (from the adjacency values)
  env_names = flatten([
    for vals in values(local.vpn_adjacency) : [
      for v in vals : v
    ]
  ])

  # unique, sorted list of all env names (keys + values)
  all_envs_list = sort(distinct(concat(keys(local.vpn_adjacency), local.env_names)))

  # produce a flat list where each env appears as "0-<env>" and "1-<env>"
  all_envs_prefixed_list = sort(distinct(flatten([
    for e in local.all_envs_list : [
      "0-${e}",
      "1-${e}"
    ]
  ])))

  # optional: map suitable for for_each (key -> value)
  all_envs_map = zipmap(local.all_envs_prefixed_list, local.all_envs_prefixed_list)
}
