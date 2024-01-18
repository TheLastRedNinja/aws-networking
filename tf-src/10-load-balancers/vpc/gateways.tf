####################################################
### Resources for IGW
####################################################

resource "aws_internet_gateway" "this" {
  count = var.create-igw && local.public-subnets-exist ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags = merge(var.default-tags, lookup(var.resource-specific-tags, "aws_internet_gateway", {}), {
    Name = local.vpc-name
  })
}