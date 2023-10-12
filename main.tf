provider "aws" {
  region     = var.region
}

resource "aws_vpc" "vpc_main" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = {
    Name = "VPC-${var.vpc_name}"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.zones)
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = element(var.subnet_cidr_block_public, count.index)
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "PUBLIC-${element(var.zones, count.index)}"
  }
}

resource "aws_subnet" "private_subnet" {
  count                   = length(var.zones)
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = element(var.subnet_cidr_block_private, count.index)
  availability_zone       = element(var.zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = "PRIVATE-${element(var.zones, count.index)}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_main.id
  tags = {
    Name = "INTERNET-GATEWAY"
  }
}

resource "aws_eip" "eip" {
}

resource "aws_nat_gateway" "nat_gateway" {
  tags = {
    Name = "NAT-GATEWAY"
  }
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_main.id
  tags   = {
    Name = "PRIVATE-ROUTE-TABLE"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  count         = length(var.zones)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_main.id
  tags   = {
    Name = "PUBLIC-ROUTE-TABLE"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  count         = length(var.zones)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}
