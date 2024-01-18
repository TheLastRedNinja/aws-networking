output "instance-public-ips" {
  value = { for k,v in aws_instance.dns-lab-central : k => v.public_ip }
}