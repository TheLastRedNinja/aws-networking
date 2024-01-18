data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_key_pair" "denis-web-server-default" {
  key_name   = "denis-web-server-default"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM5CGhrnMw7BqOyuEK8qn8Em6eZ2LG5dy9wkctoGlQop tng-default-key"
}


####################################################
### Config for EC2 Instances
####################################################
locals {
  instances = {
    private = {
      webapps = {
        web1 = {
          sg                          = [aws_security_group.denis-network-private["web-sg"].id]
          subnet                      = aws_subnet.denis-network-private["web-1a"].id
          associate_public_ip_address = true
        }
        web2 = {
          sg                          = [aws_security_group.denis-network-private["web-sg"].id]
          subnet                      = aws_subnet.denis-network-private["web-1b"].id
          associate_public_ip_address = true
        }
        web3 = {
          sg                          = [aws_security_group.denis-network-private["web-sg"].id]
          subnet                      = aws_subnet.denis-network-private["web-1b"].id
          associate_public_ip_address = true
        }
      }
      internal-apps = {
        app1 = {
          sg     = [aws_security_group.denis-network-private["app-sg"].id]
          subnet = aws_subnet.denis-network-private["app-1a"].id
        }
        app2 = {
          sg     = [aws_security_group.denis-network-private["app-sg"].id]
          subnet = aws_subnet.denis-network-private["app-1b"].id
        }
        app3 = {
          sg     = [aws_security_group.denis-network-private["app-sg"].id]
          subnet = aws_subnet.denis-network-private["app-1b"].id
        }
      }
      databases = {
        db1 = {
          sg     = [aws_security_group.denis-network-private["db-sg"].id]
          subnet = aws_subnet.denis-network-private["app-1a"].id
        }
      }
    }
  }
}

resource "aws_instance" "private" {
  for_each = merge(local.instances.private.webapps, local.instances.private.internal-apps, local.instances.private.databases)

  ami           = data.aws_ami.amazon-linux-2.id
  instance_type = "t2.micro"

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }

  associate_public_ip_address = try(each.value.associate_public_ip_address, false)

  vpc_security_group_ids = each.value.sg
  subnet_id              = each.value.subnet

  key_name = aws_key_pair.denis-web-server-default.key_name

  tags        = merge(local.default-tags, { Name = "denis-${each.key}" })
  volume_tags = merge(local.default-tags, { Name = "denis-${each.key}" })
}