output "application-load-balancer-endpoint" {
  value = aws_lb.lb.dns_name
}

output "public-dns" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_eip.eip.*.public_dns)
}

output "public-ip" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_eip.eip.*.public_ip)
}

output "private-dns" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_instance.ec2-public.*.private_dns)
}

output "private-ip" {
  value = zipmap(aws_instance.ec2-public.*.tags.Name, aws_instance.ec2-public.*.private_ip)
}