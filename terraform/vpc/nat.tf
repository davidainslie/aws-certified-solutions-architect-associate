# NAT Gateway to provide access to internet for private subnet

# Creating an Elastic IP for the NAT Gateway
resource "aws_eip" "nat-gateway-eip" {
  depends_on = [aws_route_table_association.rt-associate-public] # TODO - Do we need "depend_on" as this should be avoided?
  vpc = true
}

# Creating a NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  depends_on = [aws_eip.nat-gateway-eip] # TODO - Do we need "depend_on" as this should be avoided?

  # Allocating the Elastic IP to the NAT Gateway
  allocation_id = aws_eip.nat-gateway-eip.id

  # Associating it in the Public Subnet
  subnet_id = aws_subnet.subnet-public.id

  tags = {
    Name = "my-nat-gateway"
  }
}

# Creating a Route Table for the NAT Gateway
resource "aws_route_table" "nat-gateway-rt" {
  depends_on = [aws_nat_gateway.nat-gateway] # TODO - Do we need "depend_on" as this should be avoided?
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }

  tags = {
    Name = "Route Table for NAT Gateway"
  }
}

# Creating an Route Table Association of the NAT Gateway route table with the Private Subnet
resource "aws_route_table_association" "nat-gateway-rt-association" {
  depends_on = [aws_route_table.nat-gateway-rt] # TODO - Do we need "depend_on" as this should be avoided?

  # Private Subnet ID for adding this route table to the DHCP server of Private subnet
  subnet_id = aws_subnet.subnet-private.id

  # Route Table ID
  route_table_id = aws_route_table.nat-gateway-rt.id
}

output "nat_gateway_ip" {
  value = aws_eip.nat-gateway-eip.public_ip
}