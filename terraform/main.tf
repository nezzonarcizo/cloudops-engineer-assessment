terraform {
  backend "s3" {
    bucket         = "deel-assessment-terraform-state"
    key            = "lab/environemt/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  common_tags = merge(var.tags, { Environment = var.environment })
}