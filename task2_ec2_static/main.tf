provider "aws" {
  region = "ap-south-1"
}

# ----------------------------
# IMPORT VPC CREATED IN TASK-1
# ----------------------------
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Akanksha_Shukla_VPC"]
  }
}

# ----------------------------
# FIND PUBLIC SUBNET
# ----------------------------
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["Akanksha_Public_Subnet_1"]
  }
}

# ----------------------------
# CREATE SECURITY GROUP
# ----------------------------
resource "aws_security_group" "web_sg" {
  name        = "Akanksha_Web_SG"
  vpc_id      = data.aws_vpc.main.id
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----------------------------
# EC2 INSTANCE
# ----------------------------
resource "aws_instance" "web" {
  ami           = "ami-0522ab6e1ddcc7055" # Ubuntu 22.04 (Mumbai)
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
apt update -y
apt install nginx -y
echo "<h1>Akanksha Shukla Resume Website</h1>" > /var/www/html/index.html
EOF

  tags = {
    Name = "Akanksha_WebServer"
  }
}

