# Angular App Hosted on EC2

## Overview
This project showcases a fully functional Angular application deployed on an Amazon EC2 instance. It demonstrates best practices in DevOps, including CI/CD, cloud services, and containerization. The application is built using Angular and is designed to be robust, scalable, and secure.

## Technologies Used
- **Angular**: Frontend framework for building the user interface.
- **AWS EC2**: Hosting the application in a cloud environment.
- **Docker**: Containerizing the application for consistent deployment.
- **GitHub Actions**: Automating deployment and integration processes.
- **Terraform**: Automating the provisioning of the infrastructure.
- **Nginx**: Serving the application and handling reverse proxy configurations.

## Features
- Dynamic IP handling to reduce financial overhead.
- Full CI/CD pipeline integration with GitHub Actions.
- Automated Docker container management.
- Secure and scalable deployment on AWS EC2.

## Getting Started

### Prerequisites
- Docker installed on your machine.
- An AWS account.
- Terraform installed.
- GitHub account for CI/CD pipeline configuration.

### Installation
1. **Clone the repository**
git clone https://github.com/mabdullah679/tour-of-heroes.git cd tour-of-heroes
2. **Build the Docker image**
3. docker build -t tour-of-heroes:latest .
4. **Run the Docker container**
5. docker run -p 80:80 tour-of-heroes:latest
6. **Deploy using Terraform**
Navigate to the Terraform directory and run:
terraform init terraform apply

## Usage
Access the Angular frontend through your browser by navigating to the EC2 instance's IP address. The application is configured to serve on port 80.

## Contact
For any queries, you can reach out to me via email at muhammad.abdullah.0913@gmail.com.

## Acknowledgments
- Thanks to all the open-source libraries and tools used in this project.
- Special thanks to everyone who supported and guided me through the development process.

