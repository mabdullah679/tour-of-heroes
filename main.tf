############################################################
# 1. Variables
############################################################

variable "EC2_PRIVATE_KEY" {
  type      = string
  sensitive = true
}

variable "commit_sha" {
  type = string
}

############################################################
# 2. AWS Provider Configuration
############################################################

provider "aws" {
  region = "us-east-2"
}

############################################################
# 3. EC2 Instance
############################################################

resource "aws_instance" "app" {
  ami           = "ami-0d7ae6a161c5c4239" # Example Amazon Linux 2 AMI in us-east-2
  instance_type = "t2.micro"
  key_name      = "ec2_key"              # Must exist in AWS
  vpc_security_group_ids = ["sg-05c19d32506b81d7c"]

  tags = {
    Name = "heroes-angular-app"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY
    host        = self.public_ip
  }

  # One-time Docker install
  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker"
    ]
  }
}

############################################################
# 4. null_resource for Docker Refresh
############################################################

resource "null_resource" "docker_refresh" {
  depends_on = [aws_instance.app]

  triggers = {
    # Each time this 'commit_sha' changes, Terraform re-provisions
    build_sha = var.commit_sha
  }

  provisioner "remote-exec" {
    inline = [
      "sudo docker pull halludbam/angular-heroes-app:latest",
      # Optionally stop/remove existing containers
      "sudo docker stop $(sudo docker ps -q) || true",
      "sudo docker rm $(sudo docker ps -a -q) || true",
      # Run new container
      "sudo docker run -d -p 80:80 halludbam/angular-heroes-app:latest"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = var.EC2_PRIVATE_KEY
      host        = aws_instance.app.public_ip
    }
  }
}
