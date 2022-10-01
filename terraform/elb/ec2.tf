resource "aws_instance" "ec2-public" {
  count                       = length(aws_subnet.public-subnet.*.id)
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security-group-public.id]
  subnet_id                   = element(aws_subnet.public-subnet.*.id, count.index)

  tags = {
    Name = "publicly-accessible-ec2-${count.index}"
  }
}

resource "aws_eip" "eip" {
  count            = length(aws_instance.ec2-public.*.id)
  instance         = element(aws_instance.ec2-public.*.id, count.index)
  public_ipv4_pool = "amazon"
  vpc              = true

  tags = {
    "Name" = "eip-${count.index}"
  }
}

resource "aws_eip_association" "eip-association" {
  count         = length(aws_eip.eip)
  instance_id   = element(aws_instance.ec2-public.*.id, count.index)
  allocation_id = element(aws_eip.eip.*.id, count.index)
}

resource "null_resource" "null" {
  count = length(aws_subnet.public-subnet.*.id)

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install httpd -y",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '<html><body><h1><center>Web Server: ${count.index} (${var.aws-region})</center></h1></body></html>' > index.html",
      "sudo mv index.html /var/www/html/"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      host        = element(aws_eip.eip.*.public_ip, count.index)
      private_key = file("./${aws_key_pair.key-pair.key_name}.pem")
    }
  }
}

module "shell-resource-public" {
  count = length(aws_eip.eip)

  source  = "Invicton-Labs/shell-resource/external"
  command_unix = trimspace(
    <<-EOT
      echo PUBLIC SUBNET ${count.index} - ${element(aws_eip.eip.*.public_ip, count.index)}
      echo ssh -o IdentitiesOnly=yes -i ${local_sensitive_file.pem-file.filename} ec2-user@${element(aws_eip.eip.*.public_ip, count.index)}
    EOT
  )
}

output "public" {
  value = module.shell-resource-public.*.stdout
}