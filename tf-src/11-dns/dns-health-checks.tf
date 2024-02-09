resource "aws_route53_health_check" "public-web1-health" {
  for_each = local.A-records

  type              = "HTTP"
  ip_address        = aws_instance.dns-lab-west[each.key].public_ip
  port              = 80
  resource_path     = "/"
  failure_threshold = "2"
  request_interval  = "30"

  regions = ["eu-west-1", "us-west-1", "us-west-2"]

  tags = merge(local.default-tags, {
    Name = each.value.name
  })
}