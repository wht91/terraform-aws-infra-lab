# CloudWatch alarms for EC2 instance CPU utilization
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_alarm" {
  alarm_name          = "EC2CPUUtilizationHigh"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Alarm when CPU exceeds 70%"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_asg.name
  }

}

# CloudWatch logs for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/ecs/app-logs"
  retention_in_days = 30
}
