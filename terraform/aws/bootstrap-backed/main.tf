terraform {
  required_version = ">1.6"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

variable "aws_region" { type = string }
variable "aws_profile" { type = string }
variable "bucket_name" { type = string }
variable "table_name" { type = string }

resource "aws_s3_bucket" "tf_state" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state" {
  bucket = aws_s3_bucket.tf_state.id
  rule { 
    apply_server_side_encryption_by_default { 
      sse_algorithm = "AES256" 
    } 
  }
}

resource "aws_dynamodb_table" "tf_locks" {
  name = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute { 
    name = "LockID" 
    type = "S" 
  }
}

output "state" {
  value = {
    bucket = aws_s3_bucket.tf_state.bucket
    table = aws_dynamodb_table.tf_locks.name
  }
}

