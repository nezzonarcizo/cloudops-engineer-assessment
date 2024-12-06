variable "region" {
  description = "Region of the environment"
  type        = string
}

variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "environment" {
  description = "Name of the environment"
  type        = string
}

variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets" {
  description = "Public subnets CIDRs"
  type        = list(string)
}

variable "private_subnets" {
  description = "Private subnets CIDRs"
  type        = list(string)
}

variable "database_subnets" {
  description = "Database subnets CIDRs"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway?"
  type        = bool
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway?"
  type        = bool
}

variable "enable_dns_support" {
  description = "DNS Support?"
  type        = bool
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames?"
  type        = bool
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 and Auto Scaling"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling group"
  type        = number
  default     = 5
}

variable "identifier" {
  description = "The name of the RDS instance"
  type        = string
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = null
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "family" {
  description = "The family of the DB parameter group"
  type        = string
}

variable "major_engine_version" {
  description = "Specifies the major version of the engine that this option group should be associated with"
  type        = string
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
}

variable "max_allocated_storage" {
  description = "Specifies the value for Storage Autoscaling"
  type        = number
}

variable "db_name" {
  description = "The DB name to create. If omitted, no database is created initially"
  type        = string
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string 
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. The password provided will not be used if manage_master_user_password is set to true."
  type        = string
  default     = "null"
}

variable "manage_master_user_password" {
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager"
  type        = bool
  default     = false
}

variable "db_port" {
  description = "The port on which the DB accepts connections"
  type        = string 
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  type        = string
  default     = null 
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted"
  type        = bool
}