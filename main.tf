provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "app" {
    ami = "ami-07dae6a161c5c4239"
    instance_type = "t2.micro"
    tags = {
        Name = "angular-heroes-app"
    }
}

