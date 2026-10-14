# ============================================================
# 1. Terraform + AWS Provider
# ============================================================

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ============================================================
# 2. VPC
# ============================================================

resource "aws_vpc" "gift_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "gift-app-vpc"
    Environment = var.environment
  }
}

# ============================================================
# 3. Subnet
# ============================================================

resource "aws_subnet" "gift_subnet" {
  vpc_id     = aws_vpc.gift_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name        = "gift-app-subnet"
    Environment = var.environment
  }
}

# ============================================================
# 4. Internet Gateway
# ============================================================

resource "aws_internet_gateway" "gift_igw" {
  vpc_id = aws_vpc.gift_vpc.id

  tags = {
    Name        = "gift-app-igw"
    Environment = var.environment
  }
}

# ============================================================
# 5. Route Table
# ============================================================

resource "aws_route_table" "gift_route_table" {
  vpc_id = aws_vpc.gift_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gift_igw.id
  }

  tags = {
    Name        = "gift-app-rt"
    Environment = var.environment
  }
}

# ============================================================
# 6. Route Table Association
# ============================================================

resource "aws_route_table_association" "gift_subnet_association" {
  subnet_id      = aws_subnet.gift_subnet.id
  route_table_id = aws_route_table.gift_route_table.id
}

# ============================================================
# 7. Security Group
# ============================================================

resource "aws_security_group" "gift_sg" {
  name        = "gift-app-sg"
  description = "Security group for Gift App EC2"
  vpc_id      = aws_vpc.gift_vpc.id

  # Allow SSH connections
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP traffic
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "gift-app-sg"
    Environment = var.environment
  }
}

# ============================================================
# 8. Ubuntu AMI
# ============================================================

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "image-id"
    values = ["ami-06468be052a4195a6"]
  }
}

# ============================================================
# 9. EC2 Instance
# ============================================================

resource "aws_instance" "gift_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.gift_subnet.id
  vpc_security_group_ids = [
    aws_security_group.gift_sg.id
  ]
  associate_public_ip_address = true
  key_name = "gift-app-key"

  tags = {
    Name        = "gift-app-server"
    Environment = var.environment
  }
}