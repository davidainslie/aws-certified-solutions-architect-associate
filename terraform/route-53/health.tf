resource "aws_route53_health_check" "health-check" {
  fqdn              = "cmcloudlab1631.info"
  port              = 80
  type              = "HTTP"
  resource_path     = "/"
  failure_threshold = "3"
  request_interval  = "30"
  measure_latency   = "1"
  regions           = ["us-east-1", "us-west-2", "eu-west-1"]

  tags = {
    Name = "health-check"
   }
}