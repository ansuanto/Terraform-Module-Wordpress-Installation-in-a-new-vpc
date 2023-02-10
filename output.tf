output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}
output "frontend_eip" {
  value = aws_eip.frontend.public_ip
}

