# EstateFlow

A portable full-stack, Docker Compose-based application with:
- Node.js backend
- Static frontend served by Nginx
- MySQL database
- Prometheus + Grafana monitoring

## Quick Start

```bash
./scripts/start.sh start
```

Then open:
- Frontend: http://localhost:8080
- Prometheus: http://localhost:9091
- Grafana: http://localhost:3002

## Alternate Start

```bash
docker compose up -d --build
```

## Stop

```bash
./scripts/start.sh stop
```

## Cleanup

```bash
./scripts/start.sh clean
```

## Environment

Copy `.env.example` to `.env` if needed.

```bash
cp .env.example .env
```

## Notes

- Frontend uses `/api/...` to proxy requests through Nginx
- Backend connects to MySQL via Docker service name `mysql`
- Only frontend and monitoring ports are exposed externally by default
- `.env` is auto-generated if missing when running `./scripts/start.sh`
