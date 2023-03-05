# Create a postgresql instance
resource "aws_db_instance" "postgresql-instance" {
  db_name                = "ApplicationDatabase"
  allocated_storage      = 10
  max_allocated_storage  = 30
  engine                 = "postgres"
  engine_version         = "14"
  instance_class         = "db.t3.micro"
  username               = "master"   # Insert a username for master DB user
  password               = "password" # Insert a password for master DB user
  parameter_group_name   = "default.postgres14"
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
  vpc_security_group_ids = [aws_security_group.ec2-only-inbound-sg.id]
  # Skip final snapshot before deleting the instance
  skip_final_snapshot = true
}

# Create a DB subnet group to place the RDS instance
# within private subnet inside the VPC
resource "aws_db_subnet_group" "db-subnet-group" {
  name        = "db-subnet-group"
  description = "DB private subnet group"
  subnet_ids  = module.vpc.database_subnets
}

# Define the security group for the RDS instance
resource "aws_security_group" "ec2-only-inbound-sg" {
  name = "rds-only-ec2-inbound-security-group"

  ingress = [{
    cidr_blocks      = []
    description      = "Allow incoming traffic only from an EC2"
    from_port        = 5432
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    protocol         = "tcp"
    security_groups  = [aws_security_group.allow-http-traffic-from-public-instance.id]
    self             = false
    to_port          = 5432
  }]

    egress = [{
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }]

  vpc_id = module.vpc.vpc_id
}