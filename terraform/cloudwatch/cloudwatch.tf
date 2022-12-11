resource "aws_ssm_parameter" "cw-agent" {
  name  = "/cloudwatch-agent/config"
  description = "CloudWatch agent config to configure custom logs"
  type  = "String"
  value = file("cw-agent-config.json")
}

resource "aws_cloudwatch_metric_alarm" "cpu-utilization" {
  alarm_name                = "high-cpu-utilization-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "1" # Percent
  alarm_description         = "This metric monitors ec2 cpu utilization exceeding 70%"
  alarm_actions             = [aws_sns_topic.alarm.arn]
  insufficient_data_actions = [aws_sns_topic.alarm.arn]

  dimensions = {
    InstanceId = aws_instance.ec2-public.id
  }
}

resource "aws_cloudwatch_metric_alarm" "instance-health-check" {
  alarm_name                = "instance-health-check"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "1"
  alarm_description         = "This metric monitors ec2 health status"
  alarm_actions             = [aws_sns_topic.alarm.arn]
  insufficient_data_actions = [aws_sns_topic.alarm.arn]

  dimensions = {
    InstanceId = aws_instance.ec2-public.id
  }
}