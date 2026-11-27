# whoami

A tiny HTTP service that reports which host or container answered, packaged as a Docker image, tested in CI and deployed with Ansible.

## 1. The project and the problem it solves

When several containers or servers sit behind one address, it helps to know which one replied. `whoami` returns the hostname, version, client IP and uptime, and has a `/health` endpoint for checks. It is also a small end-to-end DevOps practice: containerize, test, deploy repeatably, run CI.

## 2. Technologies and versions

- Python 3.12 (`python:3.12-slim`), Flask 3.0.3, Gunicorn 22.0.0
- Docker (multi-stage build, non-root user, `HEALTHCHECK`) and Docker Compose
- Ansible (`ansible-core` 2.17.5)
- pytest 8.3.3, flake8 7.1.1
- GitHub Actions

## 3. Requirements and dependencies

- Python 3.12 and `pip`, or Docker with Compose
- Runtime packages: `requirements.txt`. Dev tools: `requirements-dev.txt`
- To deploy: a Debian/Ubuntu server with SSH and sudo, and `ansible-core` on your machine

## 4. Install and run

```bash
pip install -r requirements-dev.txt
make test
docker compose up --build
curl localhost:8080/
curl localhost:8080/health
```

Deploy with Ansible:

1. Edit `ansible/inventory/hosts.ini` with your server.
2. `cd ansible && ansible-galaxy collection install -r requirements.yml`
3. `ansible-playbook -i inventory/hosts.ini site.yml`

## 5. Environment variables and secrets

The app needs none and no secrets are stored in the repo. Ansible settings are role variables in `ansible/roles/whoami/defaults/main.yml`: `whoami_repo_version`, `whoami_host_port`, `whoami_container_name`.

## 6. How to use it

| Endpoint | Returns |
|---|---|
| `GET /` | Hostname, version, client IP, uptime (JSON) |
| `GET /health` | `{"status":"ok"}` |

| Path | Purpose |
|---|---|
| `app/main.py` | The Flask service |
| `Dockerfile`, `docker-compose.yml` | Image and local run on port 8080 |
| `ansible/` | Playbook and role: install Docker, pull the repo, build the image, run the container, wait for `/health` |
| `Makefile` | `test`, `lint`, `docker-build`, `run`, `ansible-check`, `deploy` |
| `.github/workflows/ci.yml` | flake8, pytest, Ansible syntax check, Docker build and smoke test |

## 7. Screenshots / demo

No screenshots or hosted demo. Run `docker compose up --build` and open http://localhost:8080/.

## 8. Tests

```bash
make test     # pytest, 2 tests
make lint     # flake8
```

CI runs these plus an Ansible syntax check and a container smoke test. Not yet verified: a full playbook run against a real server. The playbook has only passed `--syntax-check`.
