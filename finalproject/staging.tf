# Create the second VPC
resource "aws_vpc" "staging" {
  cidr_block = "10.200.0.0/16"
}

# Create public subnets for the second VPC
resource "aws_subnet" "public_staging" {
  count             = 3
  vpc_id            = aws_vpc.staging.id
  cidr_block        = cidrsubnet(aws_vpc.staging.cidr_block, 4, count.index)
  availability_zone = "us-east-1a"
}

# Create private subnets for the second VPC
resource "aws_subnet" "private_staging" {
  count             = 3
  vpc_id            = aws_vpc.staging.id
  cidr_block        = cidrsubnet(aws_vpc.staging.cidr_block, 4, count.index + 3) # Start from the 4th subnet
  availability_zone = "us-east-1b"
}

output "staging_vpc_id" {
  value = aws_vpc.main.id
}