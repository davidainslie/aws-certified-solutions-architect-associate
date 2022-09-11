resource "aws_network_acl" "acl-public" {
  depends_on = [aws_instance.ec2-public]

  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet-public.id]

  tags = {
    Name = "acl-public"
  }
}