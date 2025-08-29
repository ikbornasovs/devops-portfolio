locals {
  default_region  = "eu-central-1"
  default_profile = "dev"
  project         = "devops-portfolio"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "my-tf-state-ikb"
    region         = local.default_region
    profile        = local.default_profile
    dynamodb_table = "my-tf-locks"
    encrypt        = true
    key            = "${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      backend "s3" {}
    }
  EOF
}

generate "providers" {
  path      = "providers.tf"
  if_exists = "overwrite"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.6"
      required_providers {
        aws = {
          source  = "hashicorp/aws"
          version = "~> 5.0"
        }
      }
    }

    variable "aws_region"  { type = string }
    variable "aws_profile" { type = string }

    provider "aws" {
      region  = var.aws_region
      profile = var.aws_profile
    }
  EOF
}

inputs = {
  aws_region  = local.default_region
  aws_profile = local.default_profile
  project     = local.project
}
