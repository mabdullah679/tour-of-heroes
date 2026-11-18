tour-of-heroes

A small Angular 19 web page that lists four Marvel heroes (Spider-Man, Iron Man, Thor, Hulk). Click one and it shows the hero's id and name and changes the page's color theme. The repo also contains the files used to host the page on one Amazon EC2 server using Docker, nginx and Terraform.

How to run it: install Node.js 20 or newer, run "npm ci", then "npm start" and open http://localhost:4200. To run it the way it is shipped, build the Docker image with "docker build -t tour-of-heroes:latest ." and start it with "docker run -p 80:80 tour-of-heroes:latest". If port 80 is busy, use "-p 8080:80". You do not need AWS, Terraform or Docker Hub just to run it.

What is not local: the automatic deploy. When a push to main has "ci-cd" in its commit message, GitHub builds the image, pushes it to Docker Hub and runs Terraform to start the server. That needs a Docker Hub account, an AWS account with a ready key pair, network settings and GitHub secrets. It was not run as part of the cleanup.

Tests: "npm run test:ci" runs one unit test (the heroes component can be created) in headless Chrome. "./e2e/run-staging.sh" builds the real Docker image, starts it on port 18480 and runs two Playwright browser tests: the list of heroes, and clicking a hero shows details and changes the theme. A third test, that unknown web addresses still show the app, is skipped on purpose because it fails. Nothing tests the Terraform or the deploy workflow. The GitHub checks run the build, the unit test, the browser tests and a secret scan.

Known problems: the shipped container answers 404 for any address other than the home page, because its nginx file pulls in nginx's default settings instead of its own fallback rule (the fallback exists only in the unused nginx.conf). It does no harm today because the app has no other pages. Also, the repo has no LICENSE file. Neither was fixed in the cleanup.

There is no backend, database or web API. HTTPS is not turned on in the shipped image. The files apply-certs.sh, nginx.conf and stop-instance.sh are not used by anything. bad.sh commits your changes with the message "ci-cd" and pushes to main, which starts the deploy, so do not run it casually.

Cleanup done: two Terraform state files were removed from the repo (they contained an AWS account number and a server address) and are now ignored.
