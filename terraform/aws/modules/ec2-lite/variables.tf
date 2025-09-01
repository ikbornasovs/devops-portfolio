variable "project"        { type = string }
variable "env"            { type = string }
variable "name"           { type = string }
variable "vpc_id"         { type = string }
variable "subnet_id"      { type = string }
variable "key_name"       { type = string }
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "ssh_cidr"       { 
  type = string
  default = "84.15.222.29/32"
}
