output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.springboot.public_ip
}

output "cert_validation_dns" {
  value = tolist(aws_acm_certificate.cert.domain_validation_options)[0]
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.spring_lb.dns_name
}
