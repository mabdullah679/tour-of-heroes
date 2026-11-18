# CLAUDE.md

Standing rules: `~/.claude/CLAUDE.md` (branch + PR, no direct pushes to `main`, verify before claiming).

Angular 19 standalone-component demo ("tour of heroes") plus deploy tooling (Docker, nginx, Terraform to EC2). Commands verified 2026-11-18, Node 26 locally, Node 20 in CI:

- `npm ci`, `npm run build` (outputs `dist/browser`), `npm run test:ci` (Karma, headless Chrome via `karma.conf.js`, needs Chrome; `CHROME_BIN` on macOS).
- `./e2e/run-staging.sh`: builds the Dockerfile, serves it on `localhost:18480` (override with `STAGING_PORT`), runs Playwright (`e2e/`), removes the container. Needs Docker and Chrome.

Do not touch / care:
- `.github/workflows/ci-cd.yml` is the live deploy (Docker Hub push + `terraform apply` on a push to `main` whose message contains `ci-cd`). Not part of the sanitize pass; changes need owner review. `bad.sh` triggers it (commits and pushes to `main`); do not run it.
- `main.tf` targets a real AWS account; never run `terraform apply`. Never commit `*.tfstate`, `.pem`, key CSVs (gitignored).
- `apply-certs.sh`, `stop-instance.sh`, `nginx.conf` are not referenced by the Dockerfile or workflows (the image uses `cont-nginx.conf`).
- `src/app/app.modules.ts` is actually the bootstrap file; `app.component.spec.ts` contains component code, not a test.
- Known defect (not fixed): the container 404s on non-`/` paths (see README Known issues); the matching Playwright test is `test.fixme`.
- Keep `README.md` and `README.txt` in sync.
