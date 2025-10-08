output "alb_dns_name" {
  description = "El nombre DNS del Application Load Balancer."
  value       = aws_lb.main.dns_name
}

