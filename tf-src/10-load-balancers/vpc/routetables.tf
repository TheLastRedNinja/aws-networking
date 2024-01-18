####################################################
### Resources for Route Tables
####################################################

//noinspection HILUnresolvedReference
resource "aws_route" "public-internet-gateway" {
  for_each = var.create-igw && local.public-subnets-exist ? module.public-subnet.subnets : {}

  route_table_id         = each.value.route-table-id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}
