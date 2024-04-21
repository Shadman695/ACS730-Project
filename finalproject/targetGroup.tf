# target_group.tf

# Create target group
resource "aws_lb_target_group" "shadman_target_group" {
  name        = "shadman-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.dev_vpc.id # Use the VPC "dev"
  target_type = "instance" # Target type is EC2 instance

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "shadman-target-group"
  }
}

# Output target group ARN
output "shadman_target_group_arn" {
  value = aws_lb_target_group.shadman_target_group.arn
}
