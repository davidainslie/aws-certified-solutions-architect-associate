# Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create and bootstrap an EC2 instance for our public subnet
resource "aws_instance" "ec2" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet1.id

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
  }

  tags = {
    Name = "publically-accessible-ec2"
  }
}

output "ec2-public-ip" {
  value = aws_instance.ec2.public_ip
}

resource "null_resource" "ssh-command" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo SSH = ssh -i ${local_sensitive_file.pem-file.filename} ec2-user@${aws_instance.ec2.public_ip}
    EOT
  }
}