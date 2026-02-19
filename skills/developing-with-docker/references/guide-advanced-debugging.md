# Advanced Container Debugging

## Contents

- [5. Debugging Containers Like a Pro](#5-debugging-containers-like-a-pro)
- [5.5 Debug Image Pattern](#55-debug-image-pattern)

## 5. Debugging Containers Like a Pro

Summary: Distroless debugging, docker debug, sidecar pattern, and kubectl debug.

When standard logs fail, developers need to get inside the container.

### 5.1 Interactive Shells and the "Distroless" Challenge

The standard debugging approach is docker exec -it <container> /bin/sh. This spawns a secondary process inside the running container, allowing exploration of the filesystem.

However, modern security best practices advocate for "distroless" images - minimal images that contain the application binary but no shell, no package manager, and no debug tools. docker exec fails on these images because there is no /bin/sh to execute.

### 5.2 Docker Debug (Desktop Feature)

Introduced in Docker Desktop 4.27+, the docker debug command solves the distroless problem. It functions by attaching a "toolbox" container to the target container's namespaces.

Mechanism:
It mounts a set of statically linked tools (curl, vim, htop, netstat) into the target container.

Usage:

```bash
docker debug <container_name>
```

This drops the user into a shell with these tools available, even if the underlying image is effectively empty.

### 5.3 The Sidecar Pattern (Universal/Linux)

For users without Docker Desktop (e.g., on Linux CI servers or using Rancher Desktop's nerdctl), the "Sidecar Pattern" replicates the functionality of docker debug using native primitives.

The concept:
Launch a temporary container equipped with tools (like nicolaka/netshoot or alpine) and instruct it to share the PID and Network namespaces of the distressed container.

The command:

```bash
docker run -it --rm \
  --pid=container:<target_container_id> \
  --net=container:<target_container_id> \
  --cap-add=SYS_ADMIN \
  nicolaka/netshoot
```

What this enables:

- Process debugging: Running ps aux in the sidecar shows the processes of the target container. You can run strace -p <pid> to trace system calls of a process in the target.
- Network debugging: Since they share the network stack, localhost in the sidecar is localhost in the target. You can use tcpdump or curl localhost:8080 to diagnose if the app is listening, bypassing any external bridge issues.

### 5.4 Ephemeral Containers in Kubernetes

For developers using Rancher Desktop's Kubernetes features, kubectl debug is the equivalent of the sidecar pattern. It injects an ephemeral container into a running Pod.

Command:

```bash
kubectl debug -it <pod_name> --image=busybox --target=<container_name>
```

Shared namespaces:
By default, it might not share the PID namespace unless shareProcessNamespace: true is set in the Pod spec, which is a key difference from the docker run --pid approach.

### 5.5 Debug Image Pattern

Summary: Add tooling without changing the production image.

```dockerfile
# Dockerfile.debug
FROM myapp:latest
RUN apk add --no-cache curl bind-tools netcat-openbsd tcpdump strace
ENTRYPOINT ["/bin/sh"]
```

```bash
docker build -f Dockerfile.debug -t myapp:debug .
docker run -it --rm myapp:debug
```
