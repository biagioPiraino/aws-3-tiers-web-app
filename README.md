# Three-Tier Cloud Infrastructure
Deploy a secure and auto-scaled three-tier cloud infrastructure on AWS using Terraform :cloud:

The script includes the creation of the following resources:

- A VPC with public subnets that span across different Availability Zones in the eu-west-1 region
- An Application Load Balancer that operates in the VPC's public subnets
- An Auto Scaling Group with Amazon-Linux t2.micro instances running in the VPC
- An S3 bucket and a VPC endpoint to allow interaction between the private instances and the bucket
- A Postgre RDS instance deployed in private subnets 
- Appropriate Security Groups to enforce a strict communication between different components
