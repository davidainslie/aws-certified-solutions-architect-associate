# Create SG for allowing TCP/80 & TCP/22 - We only want ingress for our public subnet
resource "aws_security_group" "security-group-private" {
  name        = "security-group-private"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow traffic to TCP/3306 for MySQL/Aurora"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "Allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  ingress {
    description = "Allow ping on ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create and bootstrap an EC2 instance for our private subnet as we want to use this for a database
resource "aws_instance" "ec2-private" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.security-group-private.id]
  subnet_id                   = aws_subnet.subnet2.id

  /*
  TODO - Only one of "inline", "script", or "scripts" must be set
  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<h1><center>Simple server set up with Terraform Provisioner</center></h1>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./${aws_key_pair.key-pair.key_name}.pem")
      host        = self.public_ip
    }
  }*/

  tags = {
    Name = "privately-accessible-ec2"
  }
}

output "ec2-private-ip" {
  value = aws_instance.ec2-private.private_ip
}

resource "null_resource" "ssh-command-private" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = trimspace(
      <<-EOT
        echo SSH from public subnet = ssh -i ${local_sensitive_file.pem-file.filename} ec2-user@${aws_instance.ec2-private.private_ip}
      EOT
    )
  }
}
