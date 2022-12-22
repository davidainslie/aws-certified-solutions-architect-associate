# Get Linux AMI ID using SSM Parameter endpoint in us-east-1
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create key-pair for logging into EC2 in us-east-1
resource "tls_private_key" "private-key" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "key-pair" {
  key_name = "key-pair"
  public_key = tls_private_key.private-key.public_key_openssh
}

resource "local_sensitive_file" "pem-file" {
  filename = pathexpand("./${aws_key_pair.key-pair.key_name}.pem")
  file_permission = "600"
  content = tls_private_key.private-key.private_key_pem
}

# Create VPC in us-east-1
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# Create subnet # 1 in us-east-1
resource "aws_subnet" "subnet" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
}

# Create IGW in us-east-1
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

# Get main route table to modify
data "aws_route_table" "main-route-table" {
  filter {
    name   = "association.main"
    values = ["true"]
  }

  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }
}

# Create route table in us-east-1
resource "aws_default_route_table" "internet-route" {
  default_route_table_id = data.aws_route_table.main-route-table.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

# Create SG for allowing TCP/80 & TCP/22
resource "aws_security_group" "sg" {
  name        = "sg"
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

# Create and bootstrap the EC2 instance
resource "aws_instance" "ec2" {
  ami                         = data.aws_ssm_parameter.ami.value
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.key-pair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id

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
    Name = "my-ec2"
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