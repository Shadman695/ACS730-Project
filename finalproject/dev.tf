# dev.tf

# Provider configuration for AWS
provider "aws" {
  region = "us-east-1"  
}
# Create VPC
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.100.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "dev"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = aws_vpc.dev_vpc.id
}

# Create public subnets
resource "aws_subnet" "public_subnets" {
  count = 3

  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.100.${1+count.index}.0/24"
  availability_zone = "us-east-1a"  
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Create private subnets
resource "aws_subnet" "private_subnets" {
  count = 3

  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.100.${4+count.index}.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# Create NAT Gateway in each public subnet
resource "aws_nat_gateway" "nat_gateway" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  allocation_id  = aws_eip.nat_eips[count.index].id
}

# Create Elastic IPs for NAT Gateways
resource "aws_eip" "nat_eips" {
  count = 3
}

# Create route tables for public subnets
resource "aws_route_table" "public_route_table" {
  count = 3

  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  tags = {
    Name = "public-route-table-${count.index}"
  }
}

# Associate public subnets with public route tables
resource "aws_route_table_association" "public_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index].id
}

# Create route tables for private subnets
resource "aws_route_table" "private_route_table" {
  count = 3

  vpc_id = aws_vpc.dev_vpc.id

  tags = {
    Name = "private-route-table-${count.index}"
  }
}

# Associate private subnets with private route tables
resource "aws_route_table_association" "private_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

# Create routes in private route tables to route traffic through NAT Gateway
resource "aws_route" "private_subnet_nat_gateway_route" {
  count = 3

  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}
