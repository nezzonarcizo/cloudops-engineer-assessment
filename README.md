# **Deploy of a Dockerized Application on AWS with Terraform**

![Project Status](https://img.shields.io/badge/status-finalizado-yellow)  
![AWS](https://img.shields.io/badge/AWS-Cloud-orange)  
![Terraform](https://img.shields.io/badge/Terraform-IaC-blueviolet)  
![Python](https://img.shields.io/badge/Python-3.9-blue)

## **Table of Contents**
- [Description](#description)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Deployment Step-by-Step](#deployment-step-by-step)
- [Bonus Points Implemented](#bonus-points-implemented)
- [Testing the Application](#testing-the-application)
- [Troubleshooting](#troubleshooting)
- [Future Improvements](#future-improvements)
- [License](#license)

---

## **Description**
This project demonstrates basic skills in handling technologies/tools such as Docker, Terraform, GitHub, and AWS services/resources, including awscli, VPC, EC2, Security Groups, AMI, Auto Scaling Group, Load Balancer, RDS, IAM, Certificate Manager, Route53, Secrets Manager, Parameter Store, DynamoDB, and S3.

The task is divided into two parts:

The first part involves building the infrastructure with Terraform. In short, it requires launching an EC2 instance with Terraform using an appropriate image. The EC2 instance must have the roles and permissions necessary to access other resources in the AWS environment that are part of the task. The instance must have Docker installed to pull and run the provided image containing the application. The security group must allow only HTTP and HTTPS traffic and follow best security practices. This part ensures auto scalability and high availability of the application, which are indispensable requirements.

The second part (Bonus Points) involves writing your own application in any language that retrieves the IP address of the request's origin and prints it reversed. This part also includes building a custom Dockerfile, configuring the network according to best practices (e.g., VPC, public and private subnets, NAT Gateway, and Internet Gateway), and integrating a database. You may choose either a relational or non-relational database. Since it was not specified what should be stored in the database, I decided to save data relevant to the application’s functionality.

---

## **Architecture**
The infrastructure for both applications consists of a VPC in `us-east-1` (North Virginia) with 6 subnets: two public for the load balancer, two private for applications, and two private for the database. Three subnets are in `us-east-1a` and three in `us-east-1b`, ensuring high availability. An Application Load Balancer was added to distribute traffic.

The EC2 instances are launched using a Launch Template configured in an Auto Scaling Group. This Launch Template leverages a `user_data.sh` script to handle most of the application configurations.

The chosen image is Amazon Linux 2.

A small, cost-efficient RDS instance (t4g.micro) was implemented. It uses a Graviton processor and has a simple database with one table consisting of three fields: ID, IP, and reversed IP.

Additional AWS services were used:
- **Identity and Access Management (IAM):** Created roles for the instance to access ECR, RDS, Secrets Manager, Parameter Store, and SSM for console access. Also created an admin user for setting up extra resources via awscli and running Terraform.

- **Certificate Manager:** Created an HTTPS certificate for my domain (`4nimbus.com`) to test the application securely. This domain is registered in Route53, delegated by GoDaddy.

- **Secrets Manager:** Used to securely store the RDS database password, created via awscli and retrieved during RDS provisioning in Terraform.
- **Parameter Store:** Managed all other RDS variables.
- **DynamoDB and S3:** Used to store the `.tfstate` file securely and provide synchronization.

### **Architecture Diagram**
![Architecture](https://user-images.githubusercontent.com/xxxxxxx/diagrama.png)

**Key Components:**
1. **VPC:** Isolates the infrastructure with public and private subnets.
2. **Elastic Load Balancer (ELB):** Distributes HTTP/HTTPS traffic.
3. **Auto Scaling Group (ASG):** Ensures scalability based on demand.
4. **EC2 with Docker:** Runs containers for the provided application.
5. **RDS Database:** Stores information about IPs.

---

## **Prerequisites**
Before starting, ensure you have:
- An AWS account with permissions for EC2, RDS, Load Balancer, etc., or administrative access.
- AWSCLI installed.
- Python3 installed.
- Terraform installed ([installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)).
- Docker CLI configured ([Docker installation guide](https://docs.docker.com/get-docker/)).
- An SSH key or SSM role attached to the instances for EC2 access.

**Required Configurations:**
1. **AWS CLI Configuration:**  
   ```bash
   aws configure
