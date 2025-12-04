provider "aws" {
  region = "ap-south-1"
}

# -----------------------------
# IMPORT EXISTING VPC (from Task-1)
# -----------------------------
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["Akanksha_Shukla_VPC"]
  }
}

# -----------------------------
# FIND PUBLIC SUBNET
# -----------------------------
data "aws_subnets" "public" {
  filter {
    name   = "tag:Name"
    values = ["Akanksha_Public_Subnet_1"]
  }
}

# -----------------------------
# SECURITY GROUP FOR EC2
# -----------------------------
resource "aws_security_group" "web_sg" {
  name        = "Akanksha_Web_SG"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "Akanksha_Web_SG"
  }
}

# -----------------------------
# USER DATA (NGINX INSTALL + Resume Website)
# -----------------------------
locals {
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install nginx -y
    echo "<h1>Akanksha Shukla - Resume Website</h1>" > /var/www/html/index.html
    systemctl enable nginx
    systemctl start nginx
  EOF
}

# -----------------------------
# EC2 INSTANCE
# -----------------------------
resource "aws_instance" "web" {
  ami                    = "ami-0a0f1259dd1c90938"  # Ubuntu 22.04 for ap-south-1
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.public.ids[0]
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  associate_public_ip_address = true
  user_data              = local.user_data

  tags = {
    Name = "Akanksha_Static_WebServer"
  }
}

# -----------------------------
# OUTPUT PUBLIC IP
# -----------------------------
output "website_url" {
  value = aws_instance.web.public_ip
}
