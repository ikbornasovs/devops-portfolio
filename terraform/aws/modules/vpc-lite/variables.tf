variable "project" { type = string }
variable "env"     { type = string }

variable "name"    { type = string }
variable "cidr"    { type = string }
variable "azs"     { type = list(string) }
variable "subnets" { type = list(string) }