# autoscaling.tf

# Create Launch Configuration
resource "aws_launch_configuration" "shadman_launch_configuration" {
  name          = "shadman-launch-configuration"
  image_id      = "ami-04e5276ebb8451442" # Amazon Linux 2023 AMI ID
  instance_type = "t2.micro"
  security_groups = "securitygroup1" Attach the security group
  key_name      = "vockey" # Your key pair

  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "shadman_autoscaling_group" {
  name                 = "shadman-autoscaling-group"
  launch_configuration = aws_launch_configuration.shadman_launch_configuration.name
  min_size             = 1
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.dev_public_subnets[0].id] # Use one of the public subnets in VPC "dev"
  target_group_arns    = [aws_lb_target_group.shadman_target_group.arn] # Use the target group ARN

  tag {
    key                 = "Name"
    value               = "shadman-instance"
    propagate_at_launch = true
  }
}
