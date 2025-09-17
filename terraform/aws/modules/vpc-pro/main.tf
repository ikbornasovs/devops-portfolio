terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  common_tags = merge({
    Project = var.project
    Env     = var.env
    Module  = "vpc-pro"
  }, var.extra_tags)
}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.common_tags, {
    Name = var.name
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-igw" })
}

locals {
  public_map  = { for i, az in var.azs : az => var.public_cidrs[i] }
  private_map = { for i, az in var.azs : az => var.private_cidrs[i] }
}

resource "aws_subnet" "public" {
  for_each                = local.public_map
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.name}-pub-${each.key}"
    Tier = "public"
  })
}

resource "aws_subnet" "private" {
  for_each                = local.private_map
  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value
  map_public_ip_on_launch = false

  tags = merge(local.common_tags, {
    Name = "${var.name}-priv-${each.key}"
    Tier = "private"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-pub-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "nat" {
  count      = var.enable_nat ? 1 : 0
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(local.common_tags, { Name = "${var.name}-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  count         = var.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[ keys(aws_subnet.public)[0] ].id
  tags          = merge(local.common_tags, { Name = "${var.name}-nat" })
}

resource "aws_route_table" "private" {
  count = var.enable_nat ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags   = merge(local.common_tags, { Name = "${var.name}-priv-rt" })
}

resource "aws_route" "private_default" {
  count                  = var.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = var.enable_nat ? aws_subnet.private : {}
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[0].id
}
