resource "aws_network_acl" "acl-public" {
  depends_on = [aws_instance.ec2-public]

  vpc_id = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.subnet-public.id]

  ingress {
    rule_no     = 100
    action      = "allow"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_block = "0.0.0.0/0"
  }

  ingress {
    rule_no     = 200
    action      = "allow"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no     = 100
    action      = "allow"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no     = 200
    action      = "allow"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_block = "0.0.0.0/0"
  }

  # Ephemeral ports
  egress {
    rule_no     = 300
    action      = "allow"
    protocol    = "tcp"
    from_port   = 1024
    to_port     = 65535
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "acl-public"
  }
}