# ec2.tf

# Define EC2 instance
resource "aws_instance" "example_ec2" {
  ami           = "ami-04e5276ebb8451442" # Amazon Linux 2023 AMI ID
  instance_type = "t2.micro" # Instance type

  subnet_id     = aws_subnet.dev_public_subnets[0].id # Choose one of the public subnets in VPC "dev"
  key_name      = "your-keypair" # Your key pair
  security_groups = [aws_security_group.example_sg.id] # Attach the security group

  tags = {
    Name = "example-ec2"
  }

  # Provisioning script
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World!" > index.html
              nohup python -m SimpleHTTPServer 80 &
              EOF

  # Timeout for the instance to be in running state
  timeouts {
    create = "10m"
  }
}

# Output instance's public IP address
output "example_ec2_public_ip" {
  value = aws_instance.example_ec2.public_ip
}

# Define security group
resource "aws_security_group" "example_sg" {
  name        = "example-sg"
  description = "Allow SSH and HTTP inbound traffic"

  vpc_id = aws_vpc.dev_vpc.id # Attach the security group to VPC "dev"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
