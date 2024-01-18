output "vpc-id" {
  value = aws_vpc.this.id
}

output "public-subnets" {
  value = module.public-subnet.subnets
}