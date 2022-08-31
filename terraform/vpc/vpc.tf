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

# Create public subnet #1 in us-east-1 - Public
resource "aws_subnet" "subnet1" {
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "10.0.1.0/24 - ${element(data.aws_availability_zones.azs.names, 1)}"
  }
}

# Create private subnet #2 in us-east-1 - Private
resource "aws_subnet" "subnet2" {
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "10.0.2.0/24 - ${element(data.aws_availability_zones.azs.names, 2)}"
  }
}

# But how do we actually make the public subnet internet accessible? That is the role of "internet gateways".

# Create IGW - Note, you can have only one internet gateway per VPC.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
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
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "rt-associate-public" {
  subnet_id = aws_subnet.subnet1.id
  route_table_id = aws_route_table.rt.id
}