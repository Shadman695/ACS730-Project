# prod.tf

# Provider configuration for AWS (prod)
provider "aws" {
  alias  = "prod"
  region = "us-east-1"  # Update with your desired AWS region for prod
}

# Create VPC for staging
resource "aws_vpc" "prod_vpc" {
  cidr_block          = "10.250.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support  = true

  tags = {
    Name = "prod"
  }

  provider = aws.prod
}

# Create internet gateway for prod
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  provider = aws.prod
}

# Create public subnets for prod
resource "aws_subnet" "prod_public_subnets" {
  count = 3

  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.200.${1+count.index}.0/24"
  availability_zone = "us-east-1a"  # Update with desired availability zone for staging

  tags = {
    Name = "staging-public-subnet-${count.index}"
  }

  provider = aws.prod
}

# Create private subnets for staging
resource "aws_subnet" "prod_private_subnets" {
  count = 3

  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.200.${4+count.index}.0/24"
  availability_zone = "us-east-1a"  # Update with desired availability zone for staging

  tags = {
    Name = "prod-private-subnet-${count.index}"
  }

  provider = aws.prod
}

# Create NAT Gateway in each public subnet for staging
resource "aws_nat_gateway" "prod_nat_gateway" {
  count          = 3
  subnet_id      = aws_subnet.prod_public_subnets[count.index].id
  allocation_id = aws_eip.prod_nat_eips[count.index].id
  provider = aws.prod
}

# Create Elastic IPs for NAT Gateways for staging
resource "aws_eip" "prod_nat_eips" {
  count = 3

  provider = aws.prod
}

# Create route tables for public subnets for staging
resource "aws_route_table" "prod_public_route_table" {
  count = 3

  vpc_id = aws_vpc.prod_vpc.id

  provider = aws.prod
}
# Associate public subnets with public route tables for staging
resource "aws_route_table_association" "prod_public_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.prod_public_subnets[count.index].id
  route_table_id = aws_route_table.prod_public_route_table[count.index].id

  provider = aws.prod
}

# Create route tables for private subnets for staging
resource "aws_route_table" "prod_private_route_table" {
  count = 3

  vpc_id = aws_vpc.prod_vpc.id

  provider = aws.prod
}

# Associate private subnets with private route tables for staging
resource "aws_route_table_association" "prod_private_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.prod_private_subnets[count.index].id
  route_table_id = aws_route_table.prod_private_route_table[count.index].id

  provider = aws.prod
}

# Create routes in private route tables to route traffic through NAT Gateway for staging
resource "aws_route" "prod_private_subnet_nat_gateway_route" {
  count = 3

  route_table_id         = aws_route_table.prod_private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.prod_nat_gateway[count.index].id

  provider = aws.prod
}