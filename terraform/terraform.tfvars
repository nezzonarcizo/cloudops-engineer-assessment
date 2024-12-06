//General
name               = "deel-assessment-vpc"
region             = "us-east-1"
environment        = "lab-assessment"

//VPC
cidr               = "10.70.0.0/16"
azs                = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.70.0.0/26", "10.70.8.0/26"]
private_subnets    = ["10.70.16.0/26", "10.70.24.0/26"]
database_subnets   = ["10.70.32.0/28", "10.70.40.0/28"]

enable_nat_gateway = true
single_nat_gateway = false
enable_dns_support = true
enable_dns_hostnames = true

tags = {
  Project = "deel-assessment"
  Owner   = "4Nimbus"
}

//EC2
ami_id = "ami-0166fe664262f664c"
instance_type = "t3a.micro"
desired_capacity = 1
min_size = 1
max_size = 2


//RDS
identifier = "deelassessmentdb"

engine                   = "postgres"
engine_version           = "17"
family                   = "postgres17"
major_engine_version     = "17"
instance_class           = "db.t4g.micro"
allocated_storage     = 20
max_allocated_storage = 100

db_name  = "deelassessmentdb"
db_username = "nezzonarcizo"
db_port     = 5432
manage_master_user_password = false

skip_final_snapshot     = true