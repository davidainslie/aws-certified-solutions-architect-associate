# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
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

# Create subnet #1 in us-east-1 - Public
resource "aws_subnet" "subnet1" {
  availability_zone = element(data.aws_availability_zones.azs.names, 0)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "10.0.1.0/24 - ${element(data.aws_availability_zones.azs.names, 0)}"
  }
}

# Create subnet #2 in us-east-1 - Private
resource "aws_subnet" "subnet2" {
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "10.0.2.0/24 - ${element(data.aws_availability_zones.azs.names, 1)}"
  }
}