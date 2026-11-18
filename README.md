# tour-of-heroes

Small Angular 19 app that lists four Marvel heroes; clicking one shows its details and switches the page theme. The repo also holds Docker, nginx and Terraform files used to host it on a single AWS EC2 instance.

## Flow

```
browser --> nginx (container, :80) --> static Angular build (dist/browser)

deploy path (ci-cd.yml, on a push to main whose message contains "ci-cd"):
git push --> GitHub Actions --> docker build/push (Docker Hub) --> terraform apply --> EC2 runs the container
```

Not local: the deploy path needs a Docker Hub account, an AWS account with an existing key pair, subnet and security group, and GitHub secrets. Running the app itself needs none of that.

## Prerequisites

- Node.js 20+ and npm (CI uses 20; checked locally on 26).
- Chrome (for unit tests and the Playwright suite).
- Docker (for the container and the staging suite).
- Not needed to run or test: AWS, Terraform, Docker Hub.

## Run it

1. `npm ci`
2. `npm start` and open `http://localhost:4200`.
3. Container instead: `docker build -t tour-of-heroes:latest . && docker run -p 80:80 tour-of-heroes:latest`, then open `http://localhost`.

If port 80 is taken, change the left side of `-p`, e.g. `-p 8080:80`. If `ng test` hangs while launching Chrome, use `npm run test:ci` (adds `--no-sandbox`).

## What it does

| Action | Result |
|---|---|
| Open `/` | "My Heroes" with Spider-Man, Iron Man, Thor, Hulk ([heroes.component.ts](src/app/heroes/heroes.component.ts)) |
| Click a hero | Details (id, name) appear and the page `<body>` gets the hero's theme class ([app.component.ts](src/app/app.component.ts)) |
| Open any other path in the container | nginx serves `index.html` ([cont-nginx.conf](cont-nginx.conf)) |

There is no backend, data store or HTTP API.

## Tests

| Command | Covers | Needs |
|---|---|---|
| `npm run test:ci` | 1 Karma spec: `HeroesComponent` creates | Chrome |
| `./e2e/run-staging.sh` | Builds the shipped Dockerfile, runs it on `localhost:18480`, 3 Playwright specs: hero list, click-to-details and theme class, nginx fallback | Docker, Chrome |

Nothing tests the Terraform, the deploy workflow or `AppComponent`. CI ([ci.yml](.github/workflows/ci.yml)) runs build, unit tests, the staging suite and a gitleaks scan.

## Layout

| Path | Role |
|---|---|
| [src/](src) | Angular app ([bootstrap](src/app/app.modules.ts), [app](src/app/app.component.ts), [heroes](src/app/heroes/heroes.component.ts)) |
| [Dockerfile](Dockerfile), [cont-nginx.conf](cont-nginx.conf) | Build with node:18, serve with nginx |
| [e2e/](e2e) | Playwright suite and staging runner |
| [karma.conf.js](karma.conf.js) | Headless Chrome launcher for CI |
| [main.tf](main.tf) | One EC2 instance (us-east-2, t2.micro) that pulls and runs the Docker Hub image |
| [.github/workflows/ci.yml](.github/workflows/ci.yml) | PR checks |
| [.github/workflows/ci-cd.yml](.github/workflows/ci-cd.yml) | Deploy pipeline |
| [bad.sh](bad.sh) | Commits modified files with message `ci-cd` and pushes to `main`, which triggers the deploy |
| [apply-certs.sh](apply-certs.sh), [nginx.conf](nginx.conf), [stop-instance.sh](stop-instance.sh) | Not referenced by the Dockerfile, Terraform or workflows; TLS is not enabled in the shipped image |
| [CLAUDE.md](CLAUDE.md) | Notes for AI sessions |

## Design notes

- The deploy job runs only when the head commit message contains `ci-cd` (the `if:` in [ci-cd.yml](.github/workflows/ci-cd.yml)), so ordinary pushes skip it.
- The container image is built in CI and pulled by the instance at first boot (`user_data`); the alternative of building on the instance would need Node there.
