include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/vpc-pro"
}

generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    module "vpc_pro" {
      source = "../../../modules/vpc-pro"

      project       = var.project
      env           = var.env
      name          = var.name
      cidr_block    = var.cidr_block
      azs           = var.azs
      public_cidrs  = var.public_cidrs
      private_cidrs = var.private_cidrs
      enable_nat    = var.enable_nat
    }

    output "vpc_id" {
      value = module.vpc_pro.vpc_id
    }

    output "public_subnet_ids" {
      value = module.vpc_pro.public_subnet_ids
    }

    output "private_subnet_ids" {
      value = module.vpc_pro.private_subnet_ids
    }

    output "nat_gateway_id" {
      value = module.vpc_pro.nat_gateway_id
    }
  EOF
}

generate "variables_env" {
  path      = "variables_env.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    variable "project"        { type = string }
    variable "env"            { type = string }
    variable "name"           { type = string }
    variable "cidr_block"     { type = string }
    variable "azs"            { type = list(string) }
    variable "public_cidrs"   { type = list(string) }
    variable "private_cidrs"  { type = list(string) }
    variable "enable_nat"     { type = bool }
  EOF
}
