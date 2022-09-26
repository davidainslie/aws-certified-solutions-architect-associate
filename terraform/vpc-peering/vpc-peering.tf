resource "aws_vpc_peering_connection" "database-2-web" {
  peer_vpc_id = aws_vpc.vpc-web.id
  vpc_id      = aws_vpc.vpc-database.id
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  # provider = aws.accepter
  vpc_peering_connection_id = aws_vpc_peering_connection.database-2-web.id
  auto_accept = true

  tags = {
    Name = "database-2-web-connection-accepter"
  }
}