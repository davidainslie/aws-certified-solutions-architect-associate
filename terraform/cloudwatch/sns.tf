resource "aws_sns_topic" "alarm" {
  name = "alarms-topic"

  delivery_policy = <<-EOT
  {
    "http": {
      "defaultHealthyRetryPolicy": {
        "minDelayTarget": 20,
        "maxDelayTarget": 20,
        "numRetries": 3,
        "numMaxDelayRetries": 0,
        "numNoDelayRetries": 0,
        "numMinDelayRetries": 0,
        "backoffFunction": "linear"
      },
      "disableSubscriptionOverrides": false,
      "defaultThrottlePolicy": {
        "maxReceivesPerSecond": 1
      }
    }
  }
  EOT

  /*
  Automatice alarm subscription notification acceptance (to get this to work, think I need the option --profile)
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alarm-email}"
  }
  */
}

resource "aws_sns_topic_subscription" "alarm-topic-subscription" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.alarm-email

  depends_on = [
    aws_sns_topic.alarm
  ]
}