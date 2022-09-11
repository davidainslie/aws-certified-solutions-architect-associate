# Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "security-group-public" {
  name        = "security-group-public"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow traffic from TCP/80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create and bootstrap an EC2 instance for our public subnet
resource "aws_instance" "ec2-public" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security-group-public.id]
  subnet_id                   = aws_subnet.subnet-public.id

  // TODO - Probably need a Role i.e. copying key-pair onto public instance must be insecure - Course we should set up a bastion
  provisioner "file" {
    source      = "key-pair.pem"
    destination = "/home/ec2-user/${aws_key_pair.key-pair.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("./${aws_key_pair.key-pair.key_name}.pem")
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum -y install httpd && sudo systemctl start httpd",
      "echo '<html><body><h1><center>Simple server set up with Terraform Provisioner</center></h1></body></html>' > index.html",
      "sudo mv index.html /var/www/html/",
      "sudo chmod 600 ${aws_key_pair.key-pair.key_name}.pem"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = self.public_ip
      private_key = file("./${aws_key_pair.key-pair.key_name}.pem")
    }
  }

  tags = {
    Name = "publicly-accessible-ec2"
  }
}

module "shell-resource-public" {
  source  = "Invicton-Labs/shell-resource/external"
  command_unix = trimspace(
    <<-EOT
      echo PUBLIC SUBNET
      echo IP:  ${aws_instance.ec2-public.public_ip}
      echo SSH: ssh -o IdentitiesOnly=yes -i ${local_sensitive_file.pem-file.filename} ec2-user@${aws_instance.ec2-public.public_ip}
    EOT
  )
}

output "public" {
  value = module.shell-resource-public.stdout
}