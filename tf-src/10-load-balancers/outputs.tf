output "private-ips" {
  value = { for k, v in aws_instance.private : k => v.private_ip }
}

output "public-ips" {
  value = { for k, v in aws_instance.private : k => v.public_ip }
}