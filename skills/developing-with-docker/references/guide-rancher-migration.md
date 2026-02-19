# Rancher Desktop Migration Guide

## Contents

- [1. Executive Summary](#1-executive-summary)
- [2. Runtime Choice: dockerd vs containerd](#2-runtime-choice-dockerd-vs-containerd)
- [3. Pre-Migration Checklist](#3-pre-migration-checklist)
- [4. Migration Workflow](#4-migration-workflow)
- [5. Context Management](#5-context-management)
- [6. Compose Migration Checks](#6-compose-migration-checks)
- [7. Post-Migration Verification](#7-post-migration-verification)
- [8. Common Migration Issues](#8-common-migration-issues)
- [9. Rollback Strategy](#9-rollback-strategy)
- [10. Best Practices](#10-best-practices)

## 1. Executive Summary

Summary: Rancher Desktop is a drop-in replacement if you choose dockerd (moby).

- Choose dockerd (moby) for zero workflow changes.
- containerd requires nerdctl and can change behavior.
- You can run Docker Desktop and Rancher Desktop side-by-side and switch contexts.

## 2. Runtime Choice: dockerd vs containerd

- dockerd (moby): use `docker` CLI, Compose works as-is.
- containerd: use `nerdctl` CLI, some flags differ.
- Switching runtimes does not share images/containers.

## 3. Pre-Migration Checklist

Inventory and backups:

```bash
docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
docker images --format "{{.Repository}}:{{.Tag}}" > images-inventory.txt
docker volume ls
docker network ls --filter type=custom
docker compose ls
```

Backup volumes (example):

```bash
docker volume ls --format "{{.Name}}" | while read volume; do
  docker run --rm -v "$volume":/data -v "$PWD":/backup \
    alpine tar czf "/backup/${volume}.tar.gz" -C /data .
done
```

## 4. Migration Workflow

Clean migration (recommended):

1. Stop Docker Desktop.
2. Install Rancher Desktop.
3. Select dockerd (moby).
4. Restore images/volumes if needed.
5. Validate Compose projects.

Side-by-side:

1. Keep Docker Desktop installed.
2. Install Rancher Desktop.
3. Switch contexts as needed.

## 5. Context Management

```bash
docker context ls
docker context use rancher-desktop
docker context use desktop-linux
```

Check overrides:

```bash
env | grep DOCKER
unset DOCKER_HOST
unset DOCKER_CONTEXT
```

## 6. Compose Migration Checks

```bash
docker compose up -d
docker compose ps
docker compose logs -f
docker compose down
```

Verify bind mounts under shared directories and adjust host ports if conflicts exist.

## 7. Post-Migration Verification

```bash
docker version
docker info
docker run --rm hello-world
```

Test volume mounts and port mappings:

```bash
echo "test" > test.txt
docker run --rm -v "$PWD":/data alpine cat /data/test.txt
docker run -d -p 8080:80 --name test-nginx nginx
curl -I http://localhost:8080
docker rm -f test-nginx
```

## 8. Common Migration Issues

- Images/containers missing: export from Docker Desktop and load into Rancher Desktop.
- Volume data missing: backup and restore volumes per runtime.
- host.docker.internal: use `host.rancher-desktop.internal` if needed.
- WSL integration (Windows): enable in Rancher Desktop settings.

## 9. Rollback Strategy

```bash
docker context use desktop-linux
docker version
```

Restore images/volumes from backups if needed.

## 10. Best Practices

- Start with dockerd (moby).
- Keep a backup of volumes and images before switching.
- Use contexts to switch safely.
- Test a non-critical Compose project first.
