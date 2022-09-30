# Get Linux AMI ID using SSM Parameter endpoint in current region e.g. see variables
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}