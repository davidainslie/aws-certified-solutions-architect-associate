locals {
  userdata = templatefile("user-data.sh", {
    ssm-cloudwatch-config = aws_ssm_parameter.cw-agent.name
  })
}

resource "aws_instance" "ec2-public" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security-group-public.id]
  subnet_id                   = aws_subnet.public-subnet.id
  iam_instance_profile        = aws_iam_instance_profile.ec2-profile.name
  user_data                   = local.userdata

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