# Create the third VPC
resource "aws_vpc" "prod" {
  cidr_block = "10.250.0.0/16"
}

# Create public subnets for the third VPC
resource "aws_subnet" "public_prod" {
  count             = 3
  vpc_id            = aws_vpc.prod.id
  cidr_block        = cidrsubnet(aws_vpc.prod.cidr_block, 4, count.index)
  availability_zone = "us-east-1a"
}

# Create private subnets for the third VPC
resource "aws_subnet" "private_prod" {
  count             = 3
  vpc_id            = aws_vpc.prod.id
  cidr_block        = cidrsubnet(aws_vpc.prod.cidr_block, 4, count.index + 3) # Start from the 4th subnet
  availability_zone = "us-east-1b"
}

output "prod_vpc_id" {
  value = aws_vpc.prod.id
}