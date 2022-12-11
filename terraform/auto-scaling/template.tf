data "template_file" "user_data_hw" {
  template = <<-EOT
    #!/bin/bash -xe
    apt-get update -y
    apt-get install -y awscli docker.io jq
  EOT
}

resource "aws_launch_configuration" "stats-reader" {
  image_id             = "ami-0ec6e2ee8ff732605"
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2-profile.id
  security_groups      = [aws_security_group.security-group-public.id]
  key_name             = aws_key_pair.key-pair.key_name
  user_data            = <<-EOT
    #!/bin/bash -xe
    apt-get update -y
    apt-get install -y awscli docker.io jq
  EOT
}

resource "aws_launch_template" "hello-world" {
  name = "hello-template"
  disable_api_termination = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2-profile.id
  }

  image_id = "ami-0ec6e2ee8ff732605"
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  key_name = aws_key_pair.key-pair.key_name
  vpc_security_group_ids = [aws_security_group.security-group-public.id]

  user_data = base64encode(data.template_file.user_data_hw.rendered)
}

resource "aws_autoscaling_group" "hello-world-blue" {
  launch_template {
    id      = aws_launch_template.hello-world.id
    version = "$Latest"
  }

  #vpc_zone_identifier = [aws_vpc.vpc.id]
  #availability_zones = data.aws_availability_zones.azs.names
  #availability_zones = aws_subnet.public-subnet
  min_size = 1
  desired_capacity = 2
  max_size = 3
}