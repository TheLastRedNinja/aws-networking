###################################################
## Config for Security Group
###################################################
locals {
  security_groups = {
    private = {
      web-sg = {
        name        = "denis-network-private-web-sg"
        description = "security group for web tier"
        ingress_rules = {
          http_world = {
            from        = 80
            to          = 80
            description = "http from World"
            cidr        = ["0.0.0.0/0"]
          }
          https_world = {
            from        = 443
            to          = 443
            description = "https from World"
            cidr        = ["0.0.0.0/0"]
          }
          ssh_private = {
            from        = 22
            to          = 22
            description = "private ssh"
            cidr        = [local.local-machine-ip]
          }
          local_microservice = {
            from        = 81
            to          = 81
            description = "local microservice"
            cidr        = [local.vpc-config.private.cidr_block]
          }
        }
        egress_rules = {
          http_world = {
            from        = 80
            to          = 80
            description = "http to World"
            cidr        = ["0.0.0.0/0"]
          }
          https_world = {
            from        = 443
            to          = 443
            description = "https to World"
            cidr        = ["0.0.0.0/0"]
          }
        }
      }
      app-sg = {
        name        = "denis-network-private-app-sg"
        description = "security group for app tier"
        ingress_rules = {
          ssh_private = {
            from        = 22
            to          = 22
            description = "private ssh"
            cidr        = [local.local-machine-ip]
          }
          web_access_8080 = {
            from        = 8080
            to          = 8080
            description = "Allow port 8080 access to and from web tier applications"
            cidr        = [local.vpc-config.private.private_subnets.web-1a.cidr, local.vpc-config.private.private_subnets.web-1b.cidr]
          }
          web_access_8443 = {
            from        = 8443
            to          = 8443
            description = "Allow port 8443 access to and from web tier applications"
            cidr        = [local.vpc-config.private.private_subnets.web-1a.cidr, local.vpc-config.private.private_subnets.web-1b.cidr]
          }
        }
        egress_rules = {}
      }
      db-sg = {
        name        = "denis-network-private-db-sg"
        description = "security group for database"
        ingress_rules = {
          app_mysql = {
            from        = 3306
            to          = 3306
            description = "Allow mysql access from app1a"
            cidr        = [local.vpc-config.private.private_subnets.app-1a.cidr, local.vpc-config.private.private_subnets.app-1b.cidr]
          }
          ssh_private = {
            from        = 22
            to          = 22
            description = "private ssh"
            cidr        = [local.local-machine-ip]
          }
        }
      }
    }
  }
}

resource "aws_security_group" "denis-network-private" {
  for_each = local.security_groups.private

  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.denis-network-private.id

  dynamic "ingress" {
    for_each = each.value.ingress_rules
    iterator = it
    content {
      description = try(it.value.description, "")
      protocol    = "tcp"
      from_port   = it.value.from
      to_port     = it.value.to
      cidr_blocks = it.value.cidr
    }
  }

  dynamic "egress" {
    for_each = try(each.value.egress_rules, {})
    iterator = it
    content {
      description = try(it.value.description, "")
      protocol    = "tcp"
      from_port   = it.value.from
      to_port     = it.value.to
      cidr_blocks = it.value.cidr
    }
  }

  tags = merge(local.default-tags, {
    Name = each.value.name
  })
}

