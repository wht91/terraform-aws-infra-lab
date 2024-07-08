# Define a key pair resource
resource "aws_key_pair" "test" {
  key_name   = "test"
  public_key = file("~/.ssh/test.pem.pub")
}

# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "EC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create EC2 instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}

# Create launch configuration for EC2 instances
resource "aws_launch_configuration" "ec2_launch_config" {
  name_prefix          = "EC2LaunchConfig"
  image_id             = "ami-04a81a99f5ec58529" # Specify your AMI ID
  instance_type        = "t2.medium"             # Specify instance type
  key_name             = aws_key_pair.test.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups      = [aws_security_group.app_sg.id] # Attach security group

   # Cloud-init user data to install Nginx
  user_data = <<-EOF
    #!/bin/bash
    exec > /var/log/user-data.log 2>&1
    set -x
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Create auto scaling group
resource "aws_autoscaling_group" "app_asg" {
  name                      = "AppAutoScalingGroup"
  max_size                  = 2 # Adjust according to your scaling needs
  min_size                  = 1 # Adjust according to your scaling needs
  desired_capacity          = 1 # Adjust according to your scaling needs
  vpc_zone_identifier       = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  launch_configuration      = aws_launch_configuration.ec2_launch_config.name
  health_check_type         = "EC2"
  health_check_grace_period = 300

  # Attach to Application Load Balancer target group
  target_group_arns = [aws_lb_target_group.app_target_group.arn]

  tag {
    key                 = "Name"
    value               = "test-app"
    propagate_at_launch = true
  }
}

# Create Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "AppLoadBalancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "AppLoadBalancer"
  }
}

# Create target group for the load balancer
resource "aws_lb_target_group" "app_target_group" {
  name     = "AppTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }

  depends_on = [aws_lb.app_lb]
}

# Create ALB listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
