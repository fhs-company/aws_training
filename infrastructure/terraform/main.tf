provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
}

locals {
  tags = {
    Name = "main"
  }
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/27"
  enable_dns_hostnames = true
  enable_dns_support   = false
  instance_tenancy     = "default"

  tags = local.tags
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = local.tags
}

resource "aws_eip" "nat_gateway_ip" {
  vpc                       = true
  associate_with_private_ip = "10.0.0.10"

  tags = local.tags
}

resource "aws_nat_gateway" "nat_gateway" {
  vpc_id        = aws_vpc.vpc.id
  allocation_id = aws_eip.nat_gateway_ip.id
  subnet_id     = module.public_subnet.subnet_id

  tags = local.tags
}

//public subnet
module "public_subnet" {
  source = "./subnet"

  vpc_id                         = aws_vpc.vpc.id
  gateway_id                     = aws_internet_gateway.internet_gateway.id
  subnet_availability_zone       = "us-east-1a"
  subnet_cidr_block              = "10.0.0.0/28"
  subnet_map_public_ip_on_launch = true

  tags = local.tags
}

//private subnet
module "private_subnet" {
  source = "./subnet"

  vpc_id                         = aws_vpc.vpc.id
  gateway_id                     = aws_nat_gateway.nat_gateway.id
  subnet_availability_zone       = "us-east-1a"
  subnet_cidr_block              = "10.0.0.16/28"
  subnet_map_public_ip_on_launch = false

  tags = local.tags
}