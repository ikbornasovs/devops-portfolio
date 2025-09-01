include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  project = include.root.locals.project
  env     = "dev"
  region  = "eu-central-1"
  profile = "dev"

  name          = "${local.project}-${local.env}-bastion"
  instance_type = "t3.micro"

  key_name = "my-ec2-key"

  ssh_cidr = "84.15.222.29/32"
}

# Зависимость на VPC Lite
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id            = "vpc-000000"
    public_subnet_ids = ["subnet-111111"]
  }
}

# Terraform-код для этого стека
generate "main" {
  path      = "main.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    module "ec2_lite" {
      source = "../../../modules/ec2-lite"

      project       = var.project
      env           = var.env
      name          = var.name

      vpc_id        = "${dependency.vpc.outputs.vpc_id}"
      subnet_id     = "${dependency.vpc.outputs.public_subnet_ids[0]}"

      instance_type = var.instance_type
      key_name      = var.key_name
      ssh_cidr      = var.ssh_cidr
    }

    output "instance_id" { value = module.ec2_lite.instance_id }
    output "public_ip"   { value = module.ec2_lite.public_ip }
    output "sg_id"       { value = module.ec2_lite.sg_id }
  EOF
}

generate "variables_env" {
  path      = "variables_env.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    variable "project"       { type = string }
    variable "env"           { type = string }
    variable "name"          { type = string }
    variable "instance_type" { type = string }
    variable "key_name"      { type = string }
    variable "ssh_cidr"      { type = string }
  EOF
}

inputs = {
  aws_region  = local.region
  aws_profile = local.profile

  project       = local.project
  env           = local.env
  name          = local.name
  instance_type = local.instance_type
  key_name      = local.key_name
  ssh_cidr      = local.ssh_cidr
}
