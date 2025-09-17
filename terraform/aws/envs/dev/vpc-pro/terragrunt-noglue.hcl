include "root" {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../../modules/vpc-pro"
}

# генерим пустой main.tf, если используешь inputs/tfvars — не нужен glue-код
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
