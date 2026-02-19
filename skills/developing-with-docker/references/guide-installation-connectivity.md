# Installation, Permissions, and Connectivity

## Contents

- [3. Installation, Permissions, and Connectivity](#3-installation-permissions-and-connectivity)
- [Socket Locations (Desktop and Rancher)](#socket-locations-desktop-and-rancher)
- [Context and Environment Overrides](#context-and-environment-overrides)
- [Credential Helpers](#credential-helpers)
- [3.4 Rootless Docker Setup (Linux)](#34-rootless-docker-setup-linux)
- [3.5 Sanity Checks Before Debugging](#35-sanity-checks-before-debugging)

## 3. Installation, Permissions, and Connectivity

Summary: Socket permissions, contexts, and daemon config conflicts.

A broken environment is the first hurdle. Issues typically manifest as "permission denied" on the socket or startup failures due to configuration conflicts.

### Socket Locations (Desktop and Rancher)

- Linux: `/var/run/docker.sock`
- macOS (Docker Desktop): `~/.docker/run/docker.sock` (often symlinked to `/var/run/docker.sock`)
- macOS (Rancher Desktop, moby): `~/.rd/docker.sock`
- Windows (Docker Desktop): `npipe:////./pipe/docker_engine` or WSL socket
- Windows (Rancher Desktop): `npipe:////./pipe/rancher_desktop` or WSL socket

### Context and Environment Overrides

Priority order (highest to lowest):
1. `--host` flag
2. `DOCKER_HOST`
3. `DOCKER_CONTEXT`
4. Active context (`docker context use`)

### Credential Helpers

- macOS: `osxkeychain`
- Windows: `wincred`
- Linux: `secretservice` or `pass`

### 3.1 The Docker Socket and Security Groups

On Linux (and Linux-based CI/CD environments), the Docker socket (/var/run/docker.sock) is the gatekeeper. Access to this socket is functionally equivalent to root access on the host, as it allows a user to mount the host's root filesystem into a privileged container.

Symptom:
Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock

Diagnosis:
The socket file is owned by the root user and the docker group. The user attempting the command is not a member of this group.

Resolution:

- Group membership: Add the current user to the docker group: sudo usermod -aG docker $USER.
- Session refresh: This is the most missed step. The user must log out and back in, or run newgrp docker, for the group membership to apply to the current shell session.
- Security warning: Membership in the docker group is effectively root access because the daemon runs as root.
- Rootless Docker: For environments requiring strict security (e.g., shared dev servers), "Rootless Docker" runs the daemon inside a user namespace. This isolates the daemon entirely from the host's root user. While secure, it complicates bind mounts because the daemon cannot read files owned by other users on the host without intricate UID mapping.

Systemd checks:

```bash
sudo systemctl status docker
sudo journalctl -u docker.service -f
```

### 3.2 Managing Environments with Docker Contexts

Developers often juggle multiple environments: a local instance, a remote staging server, and perhaps a cloud-based build server. The DOCKER_HOST environment variable was the traditional way to switch targets, but Docker Contexts provide a superior, stateful mechanism.

The debugging advantage:
Contexts prevent the "phantom container" problem, where a developer mistakenly debugs the local environment while thinking they are working on remote staging.

Workflow:

```bash
# Define a context for a remote server via SSH
docker context create staging \
  --docker "host=ssh://deploy-user@192.168.1.50" \
  --description "Staging Server - Do not touch DB"

# Switch context
docker context use staging

# Verify active context
docker context ls
# OUTPUT:
# NAME      TYPE    DESCRIPTION                     DOCKER ENDPOINT
# default   moby    Current DOCKER_HOST based...    unix:///var/run/docker.sock
# staging * moby    Staging Server...               ssh://deploy-user@192.168.1.50
```

When a developer reports that "Docker is showing containers that shouldn't be there," the first debugging step is docker context ls to verify which daemon is actually receiving the commands.

### 3.3 Daemon Configuration Conflicts

Both Docker Desktop and Rancher Desktop manage the daemon's configuration dynamically. However, power users often modify /etc/docker/daemon.json (Linux) or ~/.docker/daemon.json (Mac/Windows) to add insecure registries or mirror settings.

Critical error:
"Unable to configure the Docker daemon... directives specified both as a flag and in the configuration file".

Cause:
This occurs when the desktop application launches dockerd with command-line flags (e.g., --hosts) that conflict with keys defined in daemon.json.

Fix:
On Desktop platforms, avoid editing daemon.json directly if the UI provides a setting for it (e.g., "Docker Engine" tab in settings). If manual editing is necessary, ensure the keys do not overlap with the arguments the desktop application passes to the daemon during its initialization sequence.

## 3.4 Rootless Docker Setup (Linux)

Summary: Safer daemon, with feature trade-offs.

```bash
dockerd-rootless-setuptool.sh install
export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock
```

Prereqs: subordinate UID/GID ranges and newuidmap/newgidmap.

Limitations: no privileged mode, reduced networking features on older kernels, and stricter bind-mount access.

## 3.5 Sanity Checks Before Debugging

```bash
docker context show
docker context inspect $(docker context show) | grep -i endpoint
docker version
docker info
env | grep DOCKER
```
