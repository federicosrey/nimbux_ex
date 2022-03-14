output "dns_load_balancer" {
  description = "DNS pública del load balancer"
  value       = "http://${aws_lb.alb.dns_name}"
}

/*output "ssh_private_key_pem" {
  value = tls_private_key.ssh.private_key_pem
  sensitive = false
}

output "ssh_public_key_pem" {
  value = tls_private_key.ssh.public_key_pem
}*/