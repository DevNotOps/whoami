# whoami

$ whoami: a tiny HTTP service that reports which host/container answered, packaged as a Docker image and deployed with Ansible.

It is a small practice project for the DevOps basics: containerise an app, test it, deploy it repeatably, run CI.

## What is in here

| Path | Purpose |
|---|---|
| `app/main.py` | Flask service. `GET /` returns hostname, version, client IP, uptime. `GET /health` returns `{"status":"ok"}`. |
| `tests/` | pytest tests for both endpoints. |
| `Dockerfile` | Multi-stage build, slim Python base, non-root user, `HEALTHCHECK`, gunicorn. |
| `docker-compose.yml` | Local run on port 8080. |
| `ansible/` | Playbook and `whoami` role: installs Docker, pulls this repo, builds the image, runs the container, waits for `/health`. |
| `.github/workflows/ci.yml` | CI: flake8, pytest, Ansible syntax check, Docker build and smoke test. |

## Run locally

```bash
pip install -r requirements-dev.txt
make test
docker compose up --build
curl localhost:8080/
curl localhost:8080/health
```

## Deploy with Ansible

Target: a Debian/Ubuntu host you can SSH into with sudo.

1. Edit `ansible/inventory/hosts.ini` with your server.
2. `cd ansible && ansible-galaxy collection install -r requirements.yml`
3. `ansible-playbook -i inventory/hosts.ini site.yml`

Variables (see `ansible/roles/whoami/defaults/main.yml`): `whoami_repo_version`, `whoami_host_port`, `whoami_container_name`.

## What has been tested

- `pytest` passes (2 tests) and `flake8` is clean.
- The app was run under gunicorn and both endpoints returned the expected JSON.
- `ansible-playbook --syntax-check` passes.
- CI (GitHub Actions) is green: it builds the Docker image and smoke tests the running container (`/health` and `/`).
- Not yet verified: a full playbook run against a real server (no target host was available when this was written). The playbook passes `--syntax-check` only.
