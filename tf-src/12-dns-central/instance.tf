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
    central = {
      web1 = {
        sg     = [aws_security_group.denis-dns-lab-central["dns-lab"].id]
        subnet = module.vpc-dns-lab-central.public-subnets["eu-central-1a"].subnet-id
      }
      web2 = {
        sg     = [aws_security_group.denis-dns-lab-central["dns-lab"].id]
        subnet = module.vpc-dns-lab-central.public-subnets["eu-central-1a"].subnet-id
      }
    }
  }
}

resource "aws_instance" "dns-lab-central" {
  for_each = local.instances.central

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