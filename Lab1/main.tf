resource "random_string" "suffix" {
  length = 6
  upper = false
  special = false
}

locals {
    environment_prefix = "${var.application_name}-${var.environment_name}-${random_string.suffix.result}"

    regional_stamps = {
      "foo" = {
        region = "westus"
        min_node_count = 4
        max_node_count = 8
      },
      "bar" = {
        region = "eastus"
        min_node_count = 4
        max_node_count = 8
      }
    }
}

module "region_stamps" {
  source = "./modules/regional-stamp"

  for_each = local.regional_stamps

  region         = each.value.region
  name           = each.key
  min_node_count = each.value.min_node_count
  max_node_count = each.value.max_node_count
}
