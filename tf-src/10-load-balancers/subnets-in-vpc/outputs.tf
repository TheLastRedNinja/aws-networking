output "subnets" {
  value = { for azs, subnet in aws_subnet.this : azs => {
    subnet-id      = subnet.id
    subnet-name    = subnet.tags["Name"]
    subnet-type    = subnet.tags["SubnetType"]
    cidr-block     = subnet.cidr_block
    azs            = azs
    route-table-id = aws_route_table.this[azs].id
    nat-gateway-id = aws_nat_gateway.this[azs].id
    }
  }
}