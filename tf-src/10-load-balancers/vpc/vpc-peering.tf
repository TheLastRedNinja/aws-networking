####################################################
### Config for VPC Peering
####################################################
#
#//vpc-peering only works for instance to instance to instance communication
#resource "aws_vpc_peering_connection" "private2public" {
#  vpc_id = aws_vpc.denis-network-public.id # Requester public-vpc
#
#  peer_vpc_id = aws_vpc.denis-network-private.id # Accepter: private-vpc
#  auto_accept = true
#
#  tags = merge(local.default_tags, {
#    Name = "private2public"
#    Side = "requester"
#  })
#}

#resource "aws_route" "vpc-peering-to-public" {
#  route_table_id            = aws_route_table.denis-network-private["private_subnet_db"].id
#  destination_cidr_block    = local.default_vpc_public_config.cidr_block
#  vpc_peering_connection_id = aws_vpc_peering_connection.private2public.id
#}