# Get all available AZ's in VPC for master region
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr-block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
  count             = 3
  vpc_id            = aws_vpc.vpc.id
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  cidr_block        = element(cidrsubnets(var.vpc-cidr-block, 8, 4, 4), count.index)

  tags = {
    "Name" = "public-subnet-${count.index}"
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
  count          = length(aws_subnet.public-subnet.*.id)
  route_table_id = aws_route_table.rt.id
  subnet_id      = element(aws_subnet.public-subnet.*.id, count.index)
}