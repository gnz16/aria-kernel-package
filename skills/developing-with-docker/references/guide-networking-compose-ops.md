# Networking, Compose, Volumes, and Operations

## Contents

- [6. Ports and Connectivity: The Number One Dev Pain Point](#6-ports-and-connectivity-the-number-one-dev-pain-point)
- [7. Volumes, Bind Mounts, and Permissions](#7-volumes-bind-mounts-and-permissions)
- [8. Docker Networking Deep Dive](#8-docker-networking-deep-dive)
- [9. Docker Compose: Building Reliable Local Stacks](#9-docker-compose-building-reliable-local-stacks)
- [10. Debugging Compose Stacks](#10-debugging-compose-stacks)
- [11. Image Management for Dev Velocity](#11-image-management-for-dev-velocity)
- [12. Troubleshooting Cookbook](#12-troubleshooting-cookbook)
- [13. Handy Reference](#13-handy-reference)
- [14. Appendix: Permissions Deep Dive](#14-appendix-permissions-deep-dive)

## 6. Ports and Connectivity: The Number One Dev Pain Point

Summary: Port binding, host access patterns, and LAN routing rules.

Networking issues are the most frequent source of developer friction.

### 6.1 The Binding Paradox: 127.0.0.1 vs 0.0.0.0

A misunderstanding of interfaces leads to "I can't access my app" or "I accidentally exposed my database to the internet."

- 0.0.0.0 (all interfaces): When you run docker run -p 8080:80, Docker binds port 8080 on all available interfaces on the host. This means the service is accessible via localhost, the LAN IP (e.g., 192.168.1.5), and potentially the public WAN IP.
- 127.0.0.1 (loopback only): Running docker run -p 127.0.0.1:8080:80 restricts access strictly to the host machine. This is a security best practice for local development databases that should not be visible to other devices on the WiFi network.

### 6.2 Host-to-Container and Container-to-Host

Scenario:
A containerized backend needs to connect to a non-containerized database running on the host machine.

- Linux: The container cannot reach localhost of the host because localhost inside the container refers to itself. The developer must use --add-host=host.docker.internal:host-gateway. This adds an entry to /etc/hosts inside the container, resolving host.docker.internal to the gateway IP of the Docker bridge (usually 172.17.0.1).
- Docker Desktop (Mac/Windows): The DNS name host.docker.internal is configured automatically and resolves correctly to the host's internal IP.
- Rancher Desktop: Support for host.docker.internal is available but relies on the host-gateway mechanism. On Windows, Windows Defender Firewall often blocks traffic arriving from the WSL 2 network adapter. Users may need to run a PowerShell command to create an "Allow" rule for the vEthernet (WSL) interface.

### 6.3 LAN Connectivity and Bridging

If a developer needs to access a container from a mobile device on the same LAN:

- Bind to 0.0.0.0: Ensure the port mapping is not restricted to localhost.
- Bridge limitations (Mac): On macOS, you cannot route traffic directly to the container's internal IP (e.g., 172.17.0.x). The VM isolation prevents this. You must access it via the host's IP and the mapped port.
- Macvlan: For advanced use cases where a container needs to appear as a physical device on the network with its own MAC address, the macvlan driver can be used. However, a kernel limitation prevents the host from communicating with its own macvlan containers directly. A secondary "shim" bridge is often required to bypass this restriction.

## 7. Volumes, Bind Mounts, and Permissions

Summary: File sharing performance and UID/GID mismatches.

Data persistence brings us to the most complex intersection of Docker and the OS: filesystem permissions.

### 7.1 Performance: Synchronization Mechanics

VirtioFS (macOS):
The introduction of VirtioFS has been a game-changer for Docker on macOS. Previously, osxfs had to translate every file system call between macOS (HFS+/APFS) and Linux (ext4), causing massive overhead for metadata operations (like git status or npm install). VirtioFS allows the Linux VM to access the macOS file descriptors more directly.

Troubleshooting:
If disk performance drops or "dubious ownership" errors appear in git, verify that VirtioFS is enabled in Docker Desktop settings. In some edge cases, switching back to gRPC FUSE resolves specific permission locking issues, though at a performance cost.

### 7.2 The UID/GID Mismatch (Linux)

On Linux, there is no VM to mask permission issues.

The problem:
A container running as root writes a file to a bind mount. On the host, that file is owned by root. The developer (UID 1000) cannot edit or delete it.

The inverse:
A container running as a non-root user (e.g., node, UID 1000) tries to write to a host directory. If the host directory is owned by root, the container gets Permission Denied.

Table 2: Strategies for Handling Permissions on Linux

- Runtime user mapping: docker run -u $(id -u):$(id -g) ...
  - Pros: Simplest fix. Matches container user to host user.
  - Cons: Requires the container image to support running as an arbitrary UID (some apps crash if they cannot write to /home).
- Entrypoint chown: Script runs as root, chowns data dir, then drops privileges (gosu).
  - Pros: Guarantees correct permissions inside container.
  - Cons: Can be very slow on large volumes (recursively changing permissions on startup).
- User namespaces: userns-remap in daemon config.
  - Pros: Secure. Maps container root to a non-privileged host user.
  - Cons: Complex to configure; makes sharing bind mounts with the host user difficult.
- Dockerfile user: RUN useradd -u 1000... USER 1000
  - Pros: Hardcodes the ID into the image.
  - Cons: Brittle; assumes every developer on the team uses UID 1000.

### 7.3 Windows Permissions

On Windows, the filesystem permission model (ACLs) is fundamentally different from Linux (chmod). Docker Desktop handles this translation automatically for mounts from the C: drive, generally making all files executable and owned by root inside the container.

Rancher Desktop caveat:
Rancher Desktop's handling of permissions on Windows can be stricter. If using the WSL 2 backend, it is highly recommended to store project code inside the WSL 2 filesystem rather than on the Windows C: drive. This bypasses the permission translation layer entirely and offers native Linux performance.

## 8. Docker Networking Deep Dive

Summary: Embedded DNS behavior and VPN-related DNS failures.

While basic port mapping covers 90 percent of use cases, debugging requires understanding the internal DNS and packet flow.

### 8.1 The Embedded DNS Server (127.0.0.11)

Every Docker container has a resolv.conf that points to 127.0.0.11. This is Docker's embedded DNS server.

Function:
It intercepts DNS queries. If the query matches a container name in the same network (e.g., db), it resolves it to the container's internal IP. If not, it forwards the query to the host's configured DNS resolvers.

Debugging:
When service discovery fails (container A cannot ping container B), the first step is to docker exec into container A and check /etc/resolv.conf.

VPN issues:
Corporate VPNs often push DNS settings that are only valid within the VPN tunnel. If Docker fails to inherit these, or if the VPN client blocks split tunneling, containers effectively lose internet access. Docker Desktop attempts to mitigate this with custom networking implementations, but manual DNS overrides (setting "dns": ["10.x.x.x"] in daemon.json) are a common workaround.

## 9. Docker Compose: Building Reliable Local Stacks

Summary: Readiness checks and environment precedence.

Docker Compose transforms individual container commands into a coherent infrastructure definition.

Project naming: Compose prefixes containers, networks, and volumes with the project name (directory name by default), and labels resources with `com.docker.compose.project`.

### 9.1 Service Dependency and Healthchecks

The depends_on directive in docker-compose.yml controls startup order, but by default, it only waits for the container to be "running," not "ready."

The problem:
The web server starts, tries to connect to the database, and crashes because the database is still initializing its files.

The solution:
Use the service_healthy condition.

```yaml
services:
  db:
    image: postgres:15
    healthcheck:
      test:
      interval: 5s
      timeout: 5s
      retries: 5
  api:
    build: .
    depends_on:
      db:
        condition: service_healthy
```

This configuration forces the api service to wait until the db service passes its healthcheck.

### 9.2 Environment Variable Precedence

Few things cause more confusion than environment variables in Compose. The precedence order determines which value "wins" when a variable is defined in multiple places.

Precedence hierarchy (highest to lowest):

1. Command line: docker compose run -e DEBUG=1
2. Shell environment: Variables exported in the terminal (export DEBUG=1) run before docker compose up.
3. .env file: Variables defined in the .env file in the project root. These are used to substitute ${VARIABLES} inside the YAML file itself.
4. environment attribute: Variables defined explicitly in docker-compose.yml.
5. env_file attribute: Variables loaded from a file referenced in the YAML.
6. Dockerfile ENV: Default values baked into the image.

Debugging tip:
Use docker compose config to print the final, resolved configuration. This reveals exactly which values are being injected into the containers.

## 10. Debugging Compose Stacks

Summary: Restart loops, orphan cleanup, and event streams.

When a stack behaves badly, docker compose logs is just the start.

### 10.1 Real-World Scenarios

- The "zombie" service: A service keeps restarting. docker compose ps shows status "Restarting". Use docker compose logs --tail 50 <service_name> to catch the immediate crash error.
- Orphaned containers: If you rename a service in the YAML, the old container might still be running. docker compose up --remove-orphans cleans up these ghostly remnants.
- Events stream: docker compose events --json provides a real-time stream of container events (start, stop, die, oom). This is invaluable for detecting if a container is being killed by the OOM (Out of Memory) killer silently.

### 10.2 Services Can't Talk to Each Other

Summary: Hostnames, ports, and network mismatches.

- Use service names on container ports (not host ports).
- Ensure both services are on the same network.

```yaml
services:
  web:
    networks: [frontend, backend]
  db:
    networks: [backend]
```

### 10.3 Hot Reload and File Watching Failures

Summary: macOS/Windows VM file events often require polling.

- Enable polling in dev servers (webpack/vite/nodemon).
- Keep source code inside the WSL filesystem on Windows for reliable file events.
- Use named volumes for heavy-write directories (node_modules, .venv).

### 10.4 "It Worked Yesterday" Failures

Summary: Stale images, volumes, or networks.

```bash
docker compose build --no-cache
docker compose down -v --remove-orphans
docker network prune
```

## 11. Image Management for Dev Velocity

Summary: Build context control and multi-arch strategies.

### 11.1 Build Context and .dockerignore

A slow build often starts with "Sending build context to Docker daemon." If this takes seconds (or minutes), you are likely sending the entire node_modules or .git folder to the daemon context.

Fix:
Create a .dockerignore file. Excluding node_modules, .git, and build artifacts significantly speeds up the build start time.

### 11.2 Multi-Architecture Builds

With the rise of Apple Silicon (ARM64), building images that run on both local MacBooks and x86_64 production servers is standard.

Buildx:
The docker buildx command enables multi-platform builds.

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t myimage .
```

Performance warning:
Building an AMD64 image on an ARM64 Mac uses QEMU emulation, which is extremely slow for CPU-intensive tasks (like compilation).

Optimization:
Use "native nodes." You can connect a remote AMD64 server to your local Docker instance via SSH and use it as a builder node in Buildx. This routes the AMD64 build steps to the native hardware while keeping the workflow local.

## 12. Troubleshooting Cookbook

Summary: Quick symptom-to-check mappings for common issues.

Symptom: Cannot connect to the Docker daemon
- Check: daemon running (systemd or Desktop)
- Check: socket exists and permissions
- Check: DOCKER_HOST/DOCKER_CONTEXT overrides

Symptom: Connection refused on localhost
- Check: Is the container running? (docker ps)
- Check: Is the port mapped to 127.0.0.1 or 0.0.0.0?
- Check: On Mac, are you using the mapped port? (Container IP is not reachable).

Symptom: Container exits immediately
- Check: docker logs, exit code, and entrypoint/CMD
- Check: missing binaries or wrong working directory

Symptom: Slow file operations
- Check: Are you using VirtioFS (Mac)?
- Check: Are you mounting from the Windows C: drive instead of the WSL 2 filesystem?

Symptom: DNS resolution fails in containers
- Check: /etc/resolv.conf in the container
- Check: container network membership

Symptom: Permission denied in volume
- Check: Are you on Linux?
- Fix: Use docker run -u $(id -u) or check the entrypoint script logic.

Symptom: Docker command hangs
- Check: Is the context set correctly? (docker context ls)
- Check: Is the daemon responsive? (Restart Docker Desktop).

Symptom: "No space left on device"
- Check: docker system df and prune unused images/volumes

Symptom: Compose service unhealthy or flapping
- Check: docker inspect health status/logs
- Fix: increase healthcheck start_period/timeout

## 13. Handy Reference

Summary: High-impact CLI commands for cleanup and inspection.

- Context and daemon checks:
  - docker context show
  - docker version
  - docker info | head -20

- docker system prune -a --volumes: Nuclear option: Deletes all stopped containers, unused images, and volumes.
- docker stats --no-stream: Snapshot of CPU/RAM usage for all running containers.
- docker compose up -d --build --force-recreate: Forces a complete rebuild and restart of the stack.
- docker run --rm -it --entrypoint /bin/sh <image>: Overrides the default command to get a shell in an image that crashes immediately.
- docker buildx prune: Cleans up the BuildKit build cache (distinct from image pruning).

Safe vs aggressive cleanup:

```bash
docker container prune
docker image prune
docker volume prune
docker network prune
```

## 14. Appendix: Permissions Deep Dive

Summary: UID mapping and virtualization edge cases.

### Linux Bind Mounts

The kernel maps the UID directly.

Scenario:
Host user 1000 runs docker run -v $(pwd):/app... Process inside runs as root (UID 0).

Result:
Files created in /app are owned by root. Host user cannot delete them.

Solution:
Configure the container process to run as UID 1000.

### macOS/Windows Bind Mounts

The file sharing system (VirtioFS/9P) acts as a proxy.

Scenario:
Same command.

Result:
Docker Desktop effectively "lies" to both sides. The container sees the files as owned by root. The host sees the files as owned by the user.

Edge case:
If you need to chmod a file inside the container, this metadata change might not propagate to the host file system correctly, or might be ignored. This is a known limitation of the virtualization layer.

This report synthesizes official documentation and community troubleshooting patterns to provide a robust guide for developer workflows in 2025.
