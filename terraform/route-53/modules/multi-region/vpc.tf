# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "vpc-public" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-public - ${var.name}"
  }
}

resource "aws_subnet" "subnet-public" {
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  vpc_id                  = aws_vpc.vpc-public.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public 10.0.1.0/24 - ${element(data.aws_availability_zones.azs.names, 1)}"
  }
}

# But how do we actually make the public subnet internet accessible? That is the role of "internet gateways".

# Create IGW - Note, you can have only one internet gateway per VPC.
resource "aws_internet_gateway" "igw-public" {
  vpc_id = aws_vpc.vpc-public.id

  tags = {
    Name = "igw-public - ${var.name}"
  }
}

# Now we need an actual route out to the internet - Come on down `route table`...

# Creating Route Table for Public Subnet
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc-public.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-public.id
  }

  tags = {
    Name = "Public Subnet Route Table = ${var.name}"
  }
}

resource "aws_route_table_association" "rt-public-associate" {
  subnet_id = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.rt-public.id
}