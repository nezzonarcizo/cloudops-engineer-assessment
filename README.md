# **Deploy of a Dockerized Application on AWS with Terraform**

![Project Status](https://img.shields.io/badge/status-developing-yellow)  
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
- [Troubleshooting/And what was changed](#troubleshooting)

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

The Security Groups consist of three: loadbalancer-sg, instance-sg, and db-sg. The LoadBalancer SG listens only on ports 80 and 443 and forwards traffic to two target groups: the target group for the simple-web application and the target group for reversed-ip.

The instance SG allows all traffic, but only if it originates from the LoadBalancer SG. Lastly, the RDS SG permits traffic only on port 5432 and exclusively from the instance SG.

Additional AWS services were used:
- **Identity and Access Management (IAM):** Created roles for the instance to access ECR, RDS, Secrets Manager, Parameter Store, and SSM for console access. Also created an admin user for setting up extra resources via awscli and running Terraform.

- **Certificate Manager:** Created an HTTPS certificate for my domain (`4nimbus.com`) to test the application securely. This domain is registered in Route53, delegated by GoDaddy.

- **Secrets Manager:** Used to securely store the RDS database password, created via awscli and retrieved during RDS provisioning in Terraform.
- **Parameter Store:** Managed all other RDS variables.
- **DynamoDB and S3:** Used to store the `.tfstate` file securely and provide synchronization.

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
- AWSCLI installed. *Note: Important that you use the version 2.*
- Git installed.
- Python3 installed.
- Terraform installed
- Docker CLI configured
- An SSH key or SSM role attached to the instances for EC2 access.

### **Required Configurations (Basic):**
1. **AWS CLI Configuration:**
   ```bash
   aws configure
   ```

   *Note: Input the values Acess Key, Secret Key, region and output format*

   *Note: If your region is not us-east-1, change it in the 'REGION' variable in user_data.sh on line 18 too*

2. **Create the bucket for .tfstate:**

   ```bash
   aws s3api create-bucket --bucket deel-assessment-terraform-state --region us-east-1
   ```

3. **Create the DynamoDB table terraform-locks for .tfstate control:**

   ```bash
   aws dynamodb create-table \
   --table-name terraform-locks \
   --attribute-definitions AttributeName=LockID,AttributeType=S \
   --key-schema AttributeName=LockID,KeyType=HASH \
   --billing-mode PAY_PER_REQUEST

*Note: Both, the Bucket name and the DynamoDB table name must match those in the main.tf file. Terraform will look for these resources created in AWS.*


## **Deployment Step-by-Step**

1. **Create db_password in Secrets Manager:**

   ```bash
   aws secretsmanager create-secret --name "db_password" --secret-string "******SUPER PASSWORD******"
   ```

2. **Create db_name and db_user variables in Parameter Store:**

   ```bash
   aws ssm put-parameter \
    --name "/config/db_user" \
    --value "nezzonarcizo" \
    --type "String" \
    --overwrite

   aws ssm put-parameter \
    --name "/config/db_name" \
    --value "deelassessmentdb" \
    --type "String" \
    --overwrite
   ```

3. **Create ECR repository:**

   ```bash
   aws ecr create-repository \
    --repository-name "deel-assessment-reversed-ip-app" \
    --region "us-east-1"
   ```

4. **Clone the github repository where the files are:**

   ```bash
   git clone https://github.com/nezzonarcizo/cloudops-engineer-assessment.git
   ```

5. **Build, tag and push the image to the AWS ECR:**

   Go inside the 'reversed-ip-app' folder and build, tag and push the image of the 'Bonus Point' activity. This is 

   *Note: You can view the commands for your repository under "View push commands" in the ECR panel of your AWS account."*

   *Note: Having the same user with AWS credentials added to your Docker permissions group locally makes testing easier, even if it's just temporarily.*

6. **Change the ARN on 'secret_id' for data 'db_password' in data.tf:**

   ```bash
   data "aws_secretsmanager_secret_version" "db_password" {
      secret_id = "arn:aws:secretsmanager:region:account_id:secret:your-secret"
   }
   ```

7. **Change the Certificate in data.tf:**

   ```bash
   data "aws_acm_certificate" "your-certificate-name" {
      domain = "*.your-domain.com"
      statuses = ["ISSUED"]
      most_recent = true
   }
   ```

   *Note: You only need to do this if you actually want to use HTTPS with a domain. Otherwise, just comment out the certificate usage on line 54 "certificate_arn" and the method in data.tf.*

8. **Replace the repository URI:**

   Replace the repository/image URIs with those created in your account on lines 81, 83, and 91 of user_data.sh.


## **Bonus Points Implemented**

   - My own application:
   > My application was created with a simple Dockerfile, using only the lightweight image python:3.9-slim, with updated packages and the PostgreSQL client installed for communication with the database.

   > The application directory is /reversed-ip-app (same name as the application). The requirements.txt file was added with only the Flask packages/libraries to create a small Python web application, and psycopg2-binary to connect to PostgreSQL.

   - Network configuration
   > The network was built and configured with Terraform to segment the environments, keeping only the load balancer in the public subnet. The application and the database were placed in private subnets, each in its own private network. 
   
   > Communication is handled via a NAT Gateway between the public and private subnets, with a NAT Gateway in each public subnet to ensure high availability. The VPC, of course, includes an Internet Gateway.

   - Database integration
   > For database integration, I used an RDS with PostgreSQL. It is only used to save the requester's IP and reversed IP in a table created with user_data.sh. There is also an id field, but it is incremental.

   > For database security, as mentioned in the architecture, it only allows connections on port 5432 coming from the security group of the application instances.

   > The DynamoDB was used solely to manage the .tfstate, as mentioned at the beginning of the documentation.


## **Testing the Application**

   To build the python application image and test it locally

   ```bash
   sudo docker build -t reversed-ip-app .

   sudo docker run --name reversed-ip-app -d -p 8080:5000 reversed-ip-app
   ```

   > Access through http://127.0.0.1/reversed-ip


   The application is deployed in my AWS account and can be tested using the following links:

   https://deel-assessment.4nimbus.com
   https://deel-assessment.4nimbus.com/reversed-ip
   
   > Viewer credentials have also been sent via email, allowing for a more detailed view of the architecture.

## **Troubleshooting/And what was changed**

   - Removed the redirect from port 80 to 443, which prevented testing the simple-web application when no certificate was available.

   - The method for retrieving and reversing the request IP was incorrect. It was capturing the internal network's IP (likely the LoadBalancer). I changed it to retrieve the 'X-Forwarded-For' attribute from the HTTP request header, which I believe aligns better with the task requirements.

   - Set the RDS variable manage_master_user_password to false because RDS was automatically managing the secret/password, which made it impossible to retrieve the correct value upon creation.

   - Added SSM permissions to test the user_data.sh script step by step due to issues like database connection, variable population, and binary versions such as awscli. With direct access to the instance, it was possible to review container logs, system logs, and test RDS connections. Below are some commands used:

      - To view initialization logs:
         ```bash
         /var/log/cloud-init-output.log
         /var/log/cloud-init.log
         ```

      - Test RDS connection:
         ```bash
         telnet endpoint.us-east-1.rds.amazonaws.com 5432
         psql -h endpoint.rds.amazonaws.com -U nezzonarcizo -d deelassessmentdb -p 5432
         password: *******
         SELECT * FROM ips;
         ```

   - While testing, I kept the test on the root '/' at port 8080, even though traffic was mapped via the path pattern to '/reversed-ip'. This was a mistake because, initially, my application was set to listen only on '/'. However, the LoadBalancer forwards this path along with the request, and without a reverse proxy to handle it, this caused an error. This was one of the issues that occurred during my initial tests and required a change: configuring the Flask app to expect the request to arrive at '/reversed-ip'.