# staging.tf

# Provider configuration for AWS (staging)
provider "aws" {
  alias  = "staging"
  region = "us-east-1"  # Update with your desired AWS region for staging
}

# Create VPC for staging
resource "aws_vpc" "staging_vpc" {
  cidr_block          = "10.200.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support  = true

  tags = {
    Name = "staging"
  }

  provider = aws.staging
}

# Create internet gateway for staging
resource "aws_internet_gateway" "staging_igw" {
  vpc_id = aws_vpc.staging_vpc.id

  provider = aws.staging
}

# Create public subnets for staging
resource "aws_subnet" "staging_public_subnets" {
  count = 3

  vpc_id            = aws_vpc.staging_vpc.id
  cidr_block        = "10.200.${1+count.index}.0/24"
  availability_zone = "us-east-1a"  # Update with desired availability zone for staging

  tags = {
    Name = "staging-public-subnet-${count.index}"
  }

  provider = aws.staging
}

# Create private subnets for staging
resource "aws_subnet" "staging_private_subnets" {
  count = 3

  vpc_id            = aws_vpc.staging_vpc.id
  cidr_block        = "10.200.${4+count.index}.0/24"
  availability_zone = "us-east-1a"  # Update with desired availability zone for staging

  tags = {
    Name = "staging-private-subnet-${count.index}"
  }

  provider = aws.staging
}

# Create NAT Gateway in each public subnet for staging
resource "aws_nat_gateway" "staging_nat_gateway" {
  count          = 3
  subnet_id      = aws_subnet.staging_public_subnets[count.index].id
  allocation_id = aws_eip.staging_nat_eips[count.index].id
  provider = aws.staging
}

# Create Elastic IPs for NAT Gateways for staging
resource "aws_eip" "staging_nat_eips" {
  count = 3

  provider = aws.staging
}

# Create route tables for public subnets for staging
resource "aws_route_table" "staging_public_route_table" {
  count = 3

  vpc_id = aws_vpc.staging_vpc.id

  provider = aws.staging
}

# Associate public subnets with public route tables for staging
resource "aws_route_table_association" "staging_public_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.staging_public_subnets[count.index].id
  route_table_id = aws_route_table.staging_public_route_table[count.index].id

  provider = aws.staging
}

# Create route tables for private subnets for staging
resource "aws_route_table" "staging_private_route_table" {
  count = 3

  vpc_id = aws_vpc.staging_vpc.id

  provider = aws.staging
}

# Associate private subnets with private route tables for staging
resource "aws_route_table_association" "staging_private_subnet_association" {
  count = 3

  subnet_id      = aws_subnet.staging_private_subnets[count.index].id
  route_table_id = aws_route_table.staging_private_route_table[count.index].id

  provider = aws.staging
}

# Create routes in private route tables to route traffic through NAT Gateway for staging
resource "aws_route" "staging_private_subnet_nat_gateway_route" {
  count = 3

  route_table_id         = aws_route_table.staging_private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.staging_nat_gateway[count.index].id

  provider = aws.staging
}
