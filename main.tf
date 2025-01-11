variable "EC2_PRIVATE_KEY" {
  type      = string
  sensitive = true
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "app" {
  ami           = "ami-0d7ae6a161c5c4239"
  instance_type = "t2.micro"
  key_name      = "ec2_key" # AWS-managed key pair name
  
  vpc_security_group_ids = ["sg-05c19d32506b81d7c"]

  tags = {
    Name = "heroes-angular-app"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = var.EC2_PRIVATE_KEY  # Use the Terraform variable here
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo docker pull halludbam/angular-heroes-app:latest",
      "sudo docker run -d -p 80:80 halludbam/angular-heroes-app:latest"
    ]
  }
}
