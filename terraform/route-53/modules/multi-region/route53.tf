resource "aws_route53_zone" "primary" {
  name = "cmcloudlab1631.info"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "cmcloudlab1631.info"
  type    = "A"
  ttl     = 60
  records = [aws_instance.ec2-public.public_ip]
}