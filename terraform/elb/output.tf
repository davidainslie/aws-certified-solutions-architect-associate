output "private_ip" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_instance.ec2-public.*.private_ip)
}

output "public_ip" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_eip.eip.*.public_ip)
}

output "public_dns" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_eip.eip.*.public_dns)
}

output "private_dns" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_instance.ec2-public.*.private_dns)
}

output "alb_id" {
  value = aws_lb.lb.dns_name
}