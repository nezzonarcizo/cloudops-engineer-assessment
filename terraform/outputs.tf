output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public Subnets IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets_ids" {
  description = "Private Subnets IDs"
  value       = module.vpc.private_subnets
}

output "loadbalancer_sg_id" {
  description = "LoadBalancer Security Group ID"
  value       = module.loadbalancer_sg.security_group_id
}

output "instance_sg_id" {
  description = "Instance Security Group ID"
  value       = module.instance_sg.security_group_id
}

output "db_sg_id" {
  description = "Database Security Group ID"
  value       = module.db_sg.security_group_id
}

output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.app.id
}

output "simple_web_app_tg_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.simple_web_app_tg.arn
}

output "reversed_ip_app_tg_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.reversed_ip_app_tg.arn
}

output "apps_lb_dns" {
  description = "ALB Public DNS"
  value       = aws_lb.apps_lb.dns_name
}

output "instance_profile_name" {
  description = "Instance Profile Name"
  value       = aws_iam_instance_profile.ec2_instance_profile.name
}

output "iam_role_name" {
  description = "IAM Role Name"
  value       = aws_iam_role.ec2_instance_role.name
}

output "rds_endpoint" {
  description = "RDS Endpoint"
  value       = module.db.db_instance_endpoint
}

output "database_subnet_group" {
  description = "Database subnet group name"
  value       = module.vpc.private_subnets
}