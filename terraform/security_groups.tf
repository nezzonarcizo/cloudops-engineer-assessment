module "loadbalancer_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  name        = "loadbalancer-sg"
  description = "Security group for Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp","https-443-tcp"]    # Permite HTTP e HTTPS
  ingress_cidr_blocks = ["0.0.0.0/0"]       # Permitir de qualquer IP público
  egress_rules        = ["all-all"]         # Permitir todo tráfego de saída

  tags = {
    Name = "loadbalancer-sg"
  }
}

module "instance_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  name        = "instance-sg"
  description = "Security group for application instances"
  vpc_id      = module.vpc.vpc_id


  ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.loadbalancer_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]

  tags = {
    Name = "instance-sg"
  }
}

module "db_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.2.0"

  name        = "db-sg"
  description = "Security group for database instances"
  vpc_id      = module.vpc.vpc_id


  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = module.instance_sg.security_group_id
    }
  ]
  egress_rules = ["all-all"]

  tags = {
    Name = "db-sg"
  }
}