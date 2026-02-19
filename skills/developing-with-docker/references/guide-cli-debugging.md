# Core Docker CLI Debugging

## Contents

- [4. Core Docker CLI Workflow (With a Debugger's Mindset)](#4-core-docker-cli-workflow-with-a-debuggers-mindset)
- [4.4 Exit Codes Quick Map](#44-exit-codes-quick-map)
- [4.5 Build Diagnostics Essentials](#45-build-diagnostics-essentials)

## 4. Core Docker CLI Workflow (With a Debugger's Mindset)

Summary: Container lifecycle, inspect templates, and log diagnostics.

To debug effectively, one must understand the state machine of a container and the signals that drive its lifecycle.

### 4.1 The Container Lifecycle: Signals and Exit Codes

A container is simply a process wrapper. When you stop a container, you are sending a UNIX signal to the process with PID 1 inside that namespace.

The shutdown sequence:

- docker stop: Sends SIGTERM. The application receives this and should begin a graceful shutdown (closing DB connections, flushing logs).
- Grace period: Docker waits (default 10 seconds).
- docker kill: If the process is still running, Docker sends SIGKILL, terminating it immediately without cleanup.

Debugging insight:
If a container always takes exactly 10 seconds to stop, the application is likely ignoring SIGTERM. This often happens when the application is not PID 1.

Scenario:
An entrypoint script like:

```sh
#!/bin/sh
./start-app.sh
```

runs the app as a subprocess. The shell receives the signal but does not forward it.

Fix:
Use exec in shell scripts:

```sh
exec ./start-app.sh
```

This replaces the shell process with the application process, ensuring it becomes PID 1 and receives signals correctly.

### 4.2 Inspecting State with Go Templates

docker inspect is the ultimate source of truth, returning a massive JSON object with the container's configuration and runtime state. Browsing this raw JSON is inefficient. The --format flag, utilizing Go templates, allows for surgical data extraction.

Table 1: Essential Docker Inspect Formats for Debugging

- Check exit code: docker inspect --format='{{.State.ExitCode}}' <id>
  - Use to confirm crash vs clean exit.
- Find IP address: docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' <id>
  - Use for inter-container connectivity checks.
- Verify log path: docker inspect --format='{{.LogPath}}' <id>
  - Use to locate JSON logs on the host and check rotation or corruption issues.
- Check mounts: docker inspect -f '{{json.Mounts}}' <id>
  - Use to confirm host-to-container mappings and spot typos.
- Get PID on host: docker inspect --format '{{.State.Pid}}' <id>
  - Use host tools like strace or jstack against the containerized process (Linux only).

### 4.3 Logging: Where Data Goes to Die

docker logs captures STDOUT and STDERR. A common issue is "The container crashed, but the logs are empty."

Root causes:

- Buffering: Languages like Python and Node.js buffer STDOUT by default. If the app crashes before the buffer flushes, the logs are lost.
  - Fix: Set PYTHONUNBUFFERED=1 in the Dockerfile or environment.
- Wrong output stream: The application writes to a file (e.g., /var/log/nginx/access.log) instead of STDOUT.
  - Fix: Symlink the internal log files to /dev/stdout and /dev/stderr. This is a standard pattern in official images like Nginx.

### 4.4 Exit Codes Quick Map

- 0: Clean exit
- 1: Application error
- 126: Command not executable
- 127: Command not found
- 137: OOMKilled (often SIGKILL)

### 4.5 Build Diagnostics Essentials

```bash
docker build --progress=plain --no-cache -t myapp:debug .
docker build --target builder -t myapp-builder .
docker buildx build --platform linux/amd64,linux/arm64 -t myapp:multi .
```
