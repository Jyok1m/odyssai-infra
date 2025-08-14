terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

# Security Group pour Odyssai
resource "aws_security_group" "odyssai_sg" {
  name_prefix = "odyssai-sg-"
  description = "Security group for Odyssai application"

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["88.162.212.198/32"] # IP Home
  }

  # Traefik Dashboard
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["88.162.212.198/32"] #  IP Home
  }

  # Outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "odyssai-sg"
  }
}

# Utilisation de la clé existante dans AWS en DATA
data "aws_key_pair" "odyssai_key" {
  key_name = "odyssai-key"
}

resource "aws_instance" "odyssai_core" {
  ami                    = "ami-0639bd0dd196bc480" # Debian ARM64
  instance_type          = "t4g.micro"
  key_name              = data.aws_key_pair.odyssai_key.key_name
  vpc_security_group_ids = [aws_security_group.odyssai_sg.id]
  
  tags = {
    Name = "odyssai-core"
  }
}

# Outputs pour récupérer les public IP
output "odyssai_core_public_ip" {
  value = aws_instance.odyssai_core.public_ip
}

output "odyssai_core_ssh" {
  value = "ssh -i ~/.ssh/odyssai-key admin@${aws_instance.odyssai_core.public_ip}"
}