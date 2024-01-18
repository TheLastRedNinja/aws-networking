locals {
  azs                   = distinct(var.availability-zones-in-use)
  default-number-of-azs = length(local.azs)
  number-of-azs         = coalesce(var.subnet-specs.number-of-azs, local.default-number-of-azs)

  azs-names = slice(local.azs, 0, local.number-of-azs)

  cidr-blocks = cidrsubnets(var.subnet-specs.cidr-prefix, [for azs in local.azs-names : var.subnet-specs.cidr-newbits]...)

  azs-to-cidr-mapping = zipmap(local.azs-names, local.cidr-blocks)
}


##################################################
## Subnet
###################################################

# creates a subnet in each configured availability zone if a cidr_block is provided
resource "aws_subnet" "this" {
  for_each = local.azs-to-cidr-mapping

  vpc_id                          = var.vpc-id
  availability_zone               = each.key
  cidr_block                      = each.value
  map_public_ip_on_launch         = false
  assign_ipv6_address_on_creation = false

  tags = merge(var.default-tags, lookup(var.resource-specific-tags, "vpc", {}), var.subnet-specs.additional-tags, {
    Name       = "${var.subnet-specs.subnet-name}-${each.key}"
    SubnetType = var.subnet-specs.subnet-type
  })
}

###################################################
## Route Table Resources
###################################################

resource "aws_route_table" "this" {
  for_each = aws_subnet.this

  vpc_id = var.vpc-id
  tags = merge(var.default-tags, lookup(var.resource-specific-tags, "aws-route-table", {}), {
    Name = each.value["tags"]["Name"]
  })

  depends_on = [aws_subnet.this]
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.this
  subnet_id      = each.value.id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_route" "to-nat-gateway" {
  for_each = var.subnet-specs.subnet-type == "public" ? {} : aws_subnet.this

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.this[each.key].id
}

###################################################
## NACLs
###################################################