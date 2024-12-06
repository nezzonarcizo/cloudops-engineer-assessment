resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.db_name}-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "${var.db_name}-db-subnet-group"
    Environment = var.environment
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = var.db_name

  engine                   = var.engine
  engine_version           = var.engine_version
  family                   = var.family
  major_engine_version     = var.major_engine_version
  instance_class           = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  manage_master_user_password = var.manage_master_user_password
  port     = var.db_port

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [module.db_sg.security_group_id]

  skip_final_snapshot     = var.skip_final_snapshot

  tags = var.tags
}