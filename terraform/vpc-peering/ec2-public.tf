# Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "security-group-public" {
  name        = "security-group-public"
  description = "Allow TCP/80 & TCP/22"
  vpc_id      = aws_vpc.vpc-web.id

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
    inline = [<<-EOT
      #!/bin/bash
      sudo apt update -y
      sudo chmod 600 ${aws_key_pair.key-pair.key_name}.pem
      sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip perl mysql-server apache2 libapache2-mod-php php-mysql -y
      wget https://github.com/ACloudGuru-Resources/course-aws-certified-solutions-architect-associate/raw/main/lab/5/wordpress.tar.gz
      tar zxvf wordpress.tar.gz
      cd wordpress
      wget https://raw.githubusercontent.com/ACloudGuru-Resources/course-aws-certified-solutions-architect-associate/main/lab/5/000-default.conf
      cp wp-config-sample.php wp-config.php
      perl -pi -e "s/database_name_here/wordpress/g" wp-config.php
      perl -pi -e "s/username_here/wordpress/g" wp-config.php
      perl -pi -e "s/password_here/wordpress/g" wp-config.php
      perl -i -pe'
        BEGIN {
          @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
          push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
          sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
        }
        s/put your unique phrase here/salt()/ge
      ' wp-config.php
      mkdir wp-content/uploads
      chmod 775 wp-content/uploads
      mv 000-default.conf /etc/apache2/sites-enabled/
      mv /wordpress /var/www/
      apache2ctl restart
      EOT
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