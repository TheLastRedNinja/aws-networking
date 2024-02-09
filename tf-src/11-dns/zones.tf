locals {
  A-records = {
    web1 = { name = "web1-west" }
    web2 = { name = "web2-west" }
  }
}

resource "aws_route53_delegation_set" "denis-dns-ds" {
  reference_name = "denis-dns-ds"
}

resource "aws_route53_zone" "denis-public" {
  name    = local.base-domain
  comment = "denis-public-zone"

  delegation_set_id = aws_route53_delegation_set.denis-dns-ds.id

  tags = merge(local.default-tags, {
    Name = local.base-domain
  })
}

resource "aws_route53_record" "public-A-record" {
  for_each = local.A-records

  name    = each.value.name
  type    = "A"
  zone_id = aws_route53_zone.denis-public.zone_id
  ttl     = "60"
  records = [aws_instance.dns-lab-west[each.key].public_ip]
}


#resource "aws_route53_record" "public-alias-record" {
#  name    = "www"
#  type    = "A"
#  zone_id = aws_route53_zone.denis-public.zone_id
#
#  alias {
#    evaluate_target_health = false
#    name                   = aws_route53_record.public-A-record["web2"].fqdn
#    zone_id                = aws_route53_zone.denis-public.zone_id
#  }
#}
#
#resource "aws_route53_record" "public-apex-record" {
#  name    = ""
#  type    = "A"
#  zone_id = aws_route53_zone.denis-public.zone_id
#
#  alias {
#    evaluate_target_health = false
#    name                   = aws_route53_record.public-alias-record.fqdn
#    zone_id                = aws_route53_zone.denis-public.zone_id
#  }
#}