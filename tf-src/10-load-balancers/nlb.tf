####################################################
### Config for Target Groups
####################################################
locals {
  nlb-tg-config = {
    webapps = {
      name        = "denis-web-server-tcp"
      target-type = "instance"
      port        = 80
    }
    webapps-ip = {
      name            = "denis-web-server-ip-tcp"
      port            = 80
      target-type     = "ip"
      ips-to-register = toset(["172.31.1.21", "172.31.1.22", "172.31.1.23"])
    }
  }
}

resource "aws_lb_target_group" "denis-web-nlb-tg" {
  for_each = local.nlb-tg-config

  name        = each.value.name
  target_type = try(each.value.target-type, "instance")
  port        = each.value.port
  protocol    = "TCP"
  vpc_id      = aws_vpc.denis-network-private.id

  stickiness {
    type            = "source_ip"
    cookie_duration = "300"
    enabled         = true
  }

  health_check {
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 10
  }

  tags = merge(local.default-tags, {
    Name = each.value.name
  })
}

resource "aws_lb_target_group_attachment" "denis-web-servers-to-nlb-tg" {
  for_each = local.instances.private.webapps

  target_group_arn = aws_lb_target_group.denis-web-nlb-tg["webapps"].arn
  target_id        = aws_instance.private[each.key].id
  port             = lookup(local.nlb-tg-config.webapps, "port")
}

resource "aws_lb_target_group_attachment" "denis-web-servers-to-nlb-tg-ip" {
  for_each = local.nlb-tg-config.webapps-ip.ips-to-register

  target_group_arn = aws_lb_target_group.denis-web-nlb-tg["webapps-ip"].arn
  target_id        = each.value
  port             = lookup(local.nlb-tg-config.webapps-ip, "port")
}

####################################################
### Config for Load Balancers
####################################################

locals {
  nlb-config = {
    webapps = {
      nlb-name      = "denis-web-sever-nlb"
      internal-lb   = false
      subnet-type   = "web"
      listener-port = 80
    }
  }
  elastic-ip-config = {
    nlb-1 = {}
    nlb-2 = {}
  }
}

resource "aws_eip" "nlb-eips" {
  for_each = local.elastic-ip-config

  tags = merge(local.default-tags, {
    Name = each.key
  })
}


resource "aws_lb" "denis-web-nlb" {
  for_each = local.nlb-config

  name               = each.value.nlb-name
  load_balancer_type = "network"
  internal           = try(each.value.internal-lb, true)
  ip_address_type    = "ipv4"
  idle_timeout       = "60"

  subnet_mapping {
    subnet_id     = aws_subnet.denis-network-private["${each.value.subnet-type}-1a"].id
    allocation_id = aws_eip.nlb-eips["nlb-1"].id
  }

  subnet_mapping {
    subnet_id     = aws_subnet.denis-network-private["${each.value.subnet-type}-1b"].id
    allocation_id = aws_eip.nlb-eips["nlb-2"].id
  }

  tags = merge(local.default-tags, {
    Name = each.value.nlb-name
  })
}

resource "aws_lb_listener" "denis-web-nlb" {
  for_each = local.nlb-config

  load_balancer_arn = aws_lb.denis-web-nlb[each.key].arn
  port              = each.value.listener-port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.denis-web-nlb-tg["webapps-ip"].arn
  }
}