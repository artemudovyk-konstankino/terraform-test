terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Create a VPC
resource "aws_vpc" "main" {
  cidr_block         = var.vpc_cidr_block
  enable_dns_support = var.enable_dns

  tags = {
    Name = "Production ${var.main_vpc_name}"
  }
}

# Create subnet
resource "aws_subnet" "web" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.web_subnet
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "Web Subnet"
  }
}

resource "aws_internet_gateway" "my_web_igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.main_vpc_name} IGW"
  }
}

resource "aws_default_route_table" "main_vpc_default_rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_web_igw.id
  }

  tags = {
    Name = "my-default-rt"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.web_port
    to_port     = var.web_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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
    Name = "Default Security Group"
  }
}

data "aws_ami" "latest_amazon_linux2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "test_ssh_key" {
  key_name   = "terraform_test_key"
  public_key = file(var.ssh_public_key_path)
}

resource "aws_instance" "my_vm" {
  ami                         = data.aws_ami.latest_amazon_linux2.id
  # ami                         = var.ami_list[var.aws_region]
  instance_type               = var.instance.type
  # cpu_core_count              = var.instance.cpu_core_count
  subnet_id                   = aws_subnet.web.id
  vpc_security_group_ids      = [aws_default_security_group.default.id]
  associate_public_ip_address = var.instance.associate_public_ip_address
  key_name                    = aws_key_pair.test_ssh_key.key_name
  user_data                   = file("entry-script.sh")

  # connection {
  #   type        = "ssh"
  #   host        = self.public_ip
  #   user        = "ec2-user"
  #   private_key = file("~/.ssh/terraform_test_key")
  # }

  # provisioner "file" {
  #   source      = "./entry-script.sh"
  #   destination = "/home/ec2-user/entry-script.sh"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "chmod +x /home/ec2-user/entry-script.sh",
  #     "sudo /home/ec2-user/entry-script.sh",
  #     "exit",
  #   ]
  #   on_failure = continue
  # }

  tags = {
    Name = "My EC2 Instance - Amazon Linux 2"
  }
}

