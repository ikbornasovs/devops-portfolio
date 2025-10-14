include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/vpc-pro"
}

inputs = {
  project       = "vpc-pro"
  aws_profile   = "dev"
  aws_region    = "eu-central-1"
  env           = "dev"
  name          = "vpc-pro-main"
  cidr_block    = "10.0.0.0/16"
  azs           = ["eu-central-1a", "eu-central-1b"]
  public_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidrs = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat    = true
}