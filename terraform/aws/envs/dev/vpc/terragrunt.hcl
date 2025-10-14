include "root" { 
  path = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  project = include.root.locals.project

  env     = "dev"
  region  = "eu-central-1"
  profile = "dev"

  name    = "${local.project}-${local.env}"

  cidr    = "10.20.0.0/16"
  azs     = ["eu-central-1a", "eu-central-1b"]
  subnets = ["10.20.1.0/24", "10.20.2.0/24"]

  state_key = "envs/${local.env}/vpc-lite/terraform.tfstate"
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    module "vpc_lite" {
      source  = "../../../modules/vpc-lite"

      project = var.project
      env     = var.env

      name    = "${var.project}-${var.env}-vpc-pro"

      cidr    = var.cidr
      azs     = var.azs
      subnets = var.subnets
    }

    output "vpc_id"            { value = module.vpc_lite.vpc_id }
    output "public_subnet_ids" { value = module.vpc_lite.public_subnet_ids }
  EOF
}

inputs = {
  aws_region  = local.region
  aws_profile = local.profile

  project = local.project
  env     = local.env

  name    = local.name
  cidr    = local.cidr
  azs     = local.azs
  subnets = local.subnets
}
