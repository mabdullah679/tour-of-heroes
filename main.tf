############################################################
# 1. Terraform Variable(s)
############################################################

variable "EC2_PRIVATE_KEY" {
  type      = string
  sensitive = true
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
  ami           = "ami-0d7ae6a161c5c4239"  # Example Amazon Linux 2 AMI in us-east-2
  instance_type = "t2.micro"
  key_name      = "ec2_key"               # Must exist in AWS already

  # Replace with your real SG that allows inbound on port 80, etc.
  vpc_security_group_ids = ["sg-05c19d32506b81d7c"]

  tags = {
    Name = "heroes-angular-app"
  }

  ##########################################################
  # 4. SSH Connection Details - Using Private Key from var
  ##########################################################
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY
    host        = self.public_ip
  }

  ##########################################################
  # 5. Remote Exec Provisioner to install Docker + run app
  ##########################################################
  provisioner "remote-exec" {
    inline = [
      # Install Docker on Amazon Linux 2
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",

      # Pull the Docker image (tagged 'latest')
      "sudo docker pull halludbam/angular-heroes-app:latest",

      # Run container on port 80
      "sudo docker run -d -p 80:80 halludbam/angular-heroes-app:latest"
    ]
  }
}
