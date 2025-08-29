variable "project" { type = string }
variable "env"     { type = string }

variable "name"    { type = string }        # удобное короткое имя (обычно "${project}-${env}")
variable "cidr"    { type = string }
variable "azs"     { type = list(string) }  # ["eu-central-1a","eu-central-1b"]
variable "subnets" { type = list(string) }  # по числу AZ