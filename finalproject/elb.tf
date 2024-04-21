# alb.tf

# Create Application Load Balancer
resource "aws_lb" "shadman_alb" {
  name               = "shadman-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.shadman_sg.id]
  subnets            = [aws_subnet.dev_public_subnets[0].id] # Use one of the public subnets in VPC "dev"

  tags = {
    Name = "shadman-alb"
  }
}

# Define security group for ALB
resource "aws_security_group" "shadman_sg" {
  name        = "shadman-alb-sg"
  description = "Allow HTTP inbound traffic for ALB"

  vpc_id = aws_vpc.dev_vpc.id # Attach the security group to VPC "dev"

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

# Output ALB DNS name
output "shadman_alb_dns_name" {
  value = aws_lb.shadman_alb.dns_name
}
