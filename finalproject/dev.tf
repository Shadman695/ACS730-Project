# Define provider (AWS in this case)
provider "aws" {
  region = "us-east-1"
}

# Configure the backend to store the Terraform state in the main S3 bucket
terraform {
  backend "s3" {
    bucket         = "finalprojectssk"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    # dynamodb_table = "terraform_locks" # Optionally, if you want to use DynamoDB for locking
  }
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.100.0.0/16"
}

# Create public subnets
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.dev.id
  cidr_block        = cidrsubnet(aws_vpc.dev.cidr_block, 4, count.index)
  availability_zone = "us-east-1a"
}

# Create private subnets
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.dev.cidr_block, 4, count.index + 3) # Start from the 4th subnet
  availability_zone = "us-east-1b"
}
output "main_vpc_id" {
  value = aws_vpc.dev.id
}