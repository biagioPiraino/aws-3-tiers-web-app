# Three-Tier Cloud Infrastructure
Deploy a secure three-tier cloud infrastructure on AWS using Terraform :cloud:

## What's in the script

- A VPC with public and private subnets that span across different Availability Zones in the eu-west-1 region
- A web-tier deployed on an Amazon-Linux EC2 operating in the VPC's public subnet
- An app-tier deployed on an Amazon-Linux EC2 operating in the VPC's private subnet
- A Postgre RDS-tier deployed in the VPC's private subnets 
- A private S3 bucket accessible directly from the VPC by using a Gateway Endpoint 
- Appropriate Security Groups to enforce a strict communication between different components

## Activities
 :heavy_check_mark::heavy_check_mark: Functionality tested
