# ipconfig getifaddr en0
# 192.168.1.115
/*
resource "aws_network_acl" "acl-public" {
  depends_on = [aws_instance.ec2-public]

  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet-public.id]

  ingress {
    rule_no     = 100
    action      = "allow"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_block = "192.168.1.1/32"
  }

  egress {
    rule_no     = 100
    action      = "allow"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_block = "192.168.1.1/32"
  }

  tags = {
    Name = "acl-public"
  }
}
*/
