environment_name = "test"
instance_count = 7
enabled = true
regions = ["westus", "eastus"]
region_instance_count = {
    "westus" = 4
    "eastus" = 8
}
region_set = ["westus", "eastus"]
sku_settings = {
    kind = "P"
    tier = "Business"
}