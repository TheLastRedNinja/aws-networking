locals {
  alb-tg-config = {
    webapps = {
      name = "denis-web-servers"
      port = 80
    }
    internal-apps = {
      name = "denis-app-servers"
      port = 8080
      health-check = {
        path = "/appserverinfo.py"
      }
    }
    image-server = {
      name = "image-servers"
      port = 81
      health-check = {
        path = "/image.php"
      }
    }
  }
}


####################################################
### Config for Target Groups
####################################################

resource "aws_lb_target_group" "denis-web-and-app-tg" {
  for_each = local.alb-tg-config

  name        = each.value.name
  target_type = "instance"
  port        = each.value.port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.denis-network-private.id

  stickiness {
    type            = "lb_cookie"
    cookie_duration = "300"
  }

  health_check {
    protocol            = "HTTP"
    path                = try(each.value.health-check.path, "/")
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 10
    matcher             = "200"
  }

  tags = merge(local.default-tags, {
    Name = each.value.name
  })
}

resource "aws_lb_target_group_attachment" "denis-web-server-to-web-instance" {
  for_each = local.instances.private.webapps

  target_group_arn = aws_lb_target_group.denis-web-and-app-tg["webapps"].arn
  target_id        = aws_instance.private[each.key].id
  port             = lookup(local.alb-tg-config.webapps, "port")
}

resource "aws_lb_target_group_attachment" "denis-app-server-to-web-server" {
  for_each = local.instances.private.internal-apps

  target_group_arn = aws_lb_target_group.denis-web-and-app-tg["internal-apps"].arn
  target_id        = aws_instance.private[each.key].id
  port             = lookup(local.alb-tg-config.internal-apps, "port")
}

resource "aws_lb_target_group_attachment" "denis-image-server-to-web-server" {
  for_each = local.instances.private.webapps

  target_group_arn = aws_lb_target_group.denis-web-and-app-tg["image-server"].arn
  target_id        = aws_instance.private[each.key].id
  port             = lookup(local.alb-tg-config.image-server, "port")
}

####################################################
### Config for Load Balancers
####################################################

locals {
  alb-config = {
    web-and-app = {
      webapps = {
        listener-port = 80
        lb-name       = "denis-web-server-lb"
        sg            = aws_security_group.denis-network-private["web-sg"]
        subnet-type   = "web"
        internal-lb   = false
      }
      internal-apps = {
        listener-port = 8080
        lb-name       = "denis-app-server-lb"
        sg            = aws_security_group.denis-network-private["app-sg"]
        subnet-type   = "app"
      }
    }
  }
}

resource "aws_lb" "denis-web-and-app-lb" {
  for_each = local.alb-config.web-and-app

  name               = each.value.lb-name
  load_balancer_type = "application"
  internal           = try(each.value.internal-lb, true)
  ip_address_type    = "ipv4"
  idle_timeout       = "60"

  security_groups = [
    each.value.sg.id
  ]

  subnet_mapping {
    subnet_id = aws_subnet.denis-network-private["${each.value.subnet-type}-1a"].id
  }

  subnet_mapping {
    subnet_id = aws_subnet.denis-network-private["${each.value.subnet-type}-1b"].id
  }

  tags = merge(local.default-tags, {
    Name = each.value.lb-name
  })
}

resource "aws_lb_listener" "denis-web-sever" {
  for_each = local.alb-config.web-and-app

  load_balancer_arn = aws_lb.denis-web-and-app-lb[each.key].arn
  port              = each.value.listener-port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.denis-web-and-app-tg[each.key].arn
  }
}

resource "aws_lb_listener_rule" "denis-image-server-forward" {
  listener_arn = aws_lb_listener.denis-web-sever["webapps"].arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.denis-web-and-app-tg["image-server"].arn
  }
  condition {
    path_pattern {
      values = ["/image.php"]
    }
  }
  tags = merge(local.default-tags, {
    Name = "forward to image-server"
  })
}





















