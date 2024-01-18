####################################################
### Resources for NAT Gateway
####################################################

resource "aws_eip" "nat-gateway" {
  for_each = (var.create-nat-gateway) ? aws_subnet.this : {}

  domain           = "vpc"
  public_ipv4_pool = "amazon"

  tags = merge(var.default-tags, lookup(var.resource-specific-tags, "aws_eip.nat-gateway", {}), {
    Name = each.key
  })
}

resource "aws_nat_gateway" "this" {
  for_each = (var.create-nat-gateway) ? aws_subnet.this : {}

  connectivity_type = "public"
  allocation_id     = aws_eip.nat-gateway[each.key].allocation_id
  subnet_id         = each.value.id

  tags = merge(var.default-tags, lookup(var.resource-specific-tags, "aws_nat_gateway", {}), {
    Name = each.key
  })
}