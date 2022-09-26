# Create VPC in us-east-1
resource "aws_vpc" "vpc-database" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-database"
  }
}

# Create private subnet #2 in us-west-1 - Private
resource "aws_subnet" "subnet-private" {
  availability_zone = element(data.aws_availability_zones.azs.names, 2)
  vpc_id            = aws_vpc.vpc-database.id
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "private 10.0.2.0/24 - ${element(data.aws_availability_zones.azs.names, 2)}"
  }
}

resource "aws_route_table" "rt-database" {
  vpc_id = aws_vpc.vpc-database.id

  tags = {
    Name = "Private Subnet Route Table"
  }
}

resource "aws_route_table_association" "rt-database-associate-public" {
  subnet_id = aws_subnet.subnet-private.id
  route_table_id = aws_route_table.rt-database.id
}

resource "aws_route" "route-database-2-web" {
  route_table_id = aws_route_table.rt-database.id
  destination_cidr_block = "192.168.0.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.database-2-web.id
}