variable "project" { type = string }
variable "env"     { type = string }
variable "name"    { type = string }

variable "cidr_block" { type = string }

variable "azs"           { type = list(string) }
variable "public_cidrs"  { type = list(string) }
variable "private_cidrs" { type = list(string) }

variable "enable_nat" { type = bool  default = true }

variable "extra_tags" { type = map(string) default = {} }

locals {
  lens_ok = length(var.azs) == length(var.public_cidrs) && length(var.azs) == length(var.private_cidrs)
}
validation {
  condition     = local.lens_ok
  error_message = "azs, public_cidrs & private_cidrs must have the same length."
}
