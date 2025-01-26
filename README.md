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

2. **Prepare and Run the Automation Script**
The `bad.sh` script is designed to trigger the CI/CD pipeline, automating the build and deployment process. Follow these steps to make the script executable and run it:
chmod +x bad.sh ./bad.sh
This script will execute necessary git commands to trigger the GitHub Actions workflow which automates the entire CI/CD pipeline.

3. **Build the Docker image** (if running locally)
docker build -t tour-of-heroes:latest .

4. **Run the Docker container** (if running locally)
docker run -p 80:80 tour-of-heroes:latest

5. **Deploy using Terraform** (automated by CI/CD if using `bad.sh`)
If running manually, navigate to the Terraform directory and run:
terraform init terraform apply

## Usage
Access the Angular frontend through your browser by navigating to the EC2 instance's IP address. The application is configured to serve on port 80.

## Contributing
Contributions are welcome! For major changes, please open an issue first to discuss what you would like to change. Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)

## Contact
For any queries, you can reach out to me via email at muhammad.abdullah.0913@gmail.com.

## Acknowledgments
- Thanks to all the open-source libraries and tools used in this project.
- Special thanks to everyone who supported and guided me through the development process.