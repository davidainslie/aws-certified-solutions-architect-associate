# Create VPC in us-east-1
resource "aws_vpc" "vpc-web" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-web"
  }
}

# Create public subnet #1 in us-east-1 - Public
resource "aws_subnet" "subnet-public" {
  availability_zone       = element(data.aws_availability_zones.azs.names, 1)
  vpc_id                  = aws_vpc.vpc-web.id
  cidr_block              = "192.168.0.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public 192.168.0.0/24 - ${element(data.aws_availability_zones.azs.names, 1)}"
  }
}

# But how do we actually make the public subnet internet accessible? That is the role of "internet gateways".

# Create IGW - Note, you can have only one internet gateway per VPC.
resource "aws_internet_gateway" "igw-web" {
  vpc_id = aws_vpc.vpc-web.id
}

# Now we need an actual route out to the internet - Come on down `route table`...

# Creating Route Table for Public Subnet
resource "aws_route_table" "rt-web" {
  vpc_id = aws_vpc.vpc-web.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-web.id
  }

  tags = {
    Name = "Public Subnet Route Table"
  }
}

resource "aws_route_table_association" "rt-web-associate-public" {
  subnet_id = aws_subnet.subnet-public.id
  route_table_id = aws_route_table.rt-web.id
}

resource "aws_route" "route-web-2-database" {
  route_table_id = aws_route_table.rt-web.id
  destination_cidr_block = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.database-2-web.id
}