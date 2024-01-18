output "instance-public-ips" {
  value = { for k,v in aws_instance.dns-lab-west : k => v.public_ip }
}