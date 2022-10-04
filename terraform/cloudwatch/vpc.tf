# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(data.aws_availability_zones.azs.names, 1)
  cidr_block        = "10.0.1.0/24"

  tags = {
    "Name" = "public-subnet-10.0.1.0/24 - ${element(data.aws_availability_zones.azs.names, 1)}"
  }
}

# But how do we actually make the public subnets internet accessible? That is the role of "internet gateways".

# Create IGW - Note, you can have only one internet gateway per VPC.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    "Name" = "public-subnet-internet-gateway"
  }
}

# Now we need an actual route out to the internet - Come on down `route table`...

# Creating Route Table for Public Subnet
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-subnet-route-table"
  }
}

resource "aws_route_table_association" "rt-association" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.public-subnet.id
}