---
name: docker-automation
description: Auto-generate optimized Docker configuration from project analysis. Detects project type (Node.js, Python, React, Next.js) and creates Dockerfile with multi-stage builds, docker-compose.yml for multi-service apps, and .dockerignore with best practices. Use when containerizing applications or setting up development environments.
license: MIT
metadata:
  author: custom
  version: "1.0.0"
---

# Docker Automation

**Dockerize any project in 60 seconds** with auto-generated, production-ready configuration.

## When to Use

**ALWAYS use for:**
- Containerizing new applications
- Setting up development environments
- Preparing for cloud deployment
- Creating reproducible builds

**Use when requested:**
- "Dockerize my app"
- "Create Docker configuration"
- "Generate docker-compose"
- "Set up containers for this project"

## What It Does

Analyzes your project and automatically generates:

1. **Dockerfile** - Optimized multi-stage build
2. **docker-compose.yml** - Multi-service orchestration
3. **.dockerignore** - Exclude unnecessary files

**Time saved:** 30-60 minutes per project  
**Quality:** Production-ready best practices

## Supported Frameworks

| Framework | Detection | Features |
|-----------|-----------|----------|
| **Node.js** | package.json | Multi-stage, npm cache |
| **React** | CRA/Vite | Nginx serving, build optimization |
| **Next.js** | next.config | Standalone output, optimized layers |
| **Python** | requirements.txt | FastAPI, Django, Flask support |
| **Multi-service** | Multiple configs | docker-compose with networks |

## How It Works

```
1. ANALYZE
   ├─ Detect package.json, requirements.txt, etc.
   ├─ Identify framework (Next.js, FastAPI, etc.)
   └─ Determine dependencies

2. GENERATE
   ├─ Create optimized Dockerfile
   │  ├─ Multi-stage build
   │  ├─ Layer caching
   │  └─ Security best practices
   ├─ Create docker-compose.yml (if multi-service)
   └─ Create .dockerignore

3. OUTPUT
   └─ 3 files ready to use
```

## Generated Dockerfiles

### Node.js Multi-stage
```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
CMD ["node", "server.js"]
```

### Next.js Standalone
```dockerfile
FROM node:18-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN npm ci

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE 3000
CMD ["node", "server.js"]
```

### Python FastAPI
```dockerfile
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## docker-compose.yml Generation

For multi-service projects:

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "3000:3000"
    environment:
      - API_URL=http://backend:8000
    depends_on:
      - backend

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## .dockerignore Best Practices

```
# Dependencies
node_modules/
__pycache__/
*.pyc
venv/
.venv/

# Build outputs
dist/
build/
.next/
*.egg-info/

# Development
.git/
.github/
.vscode/
.idea/
*.log
.env.local
.DS_Store

# Documentation
README.md
docs/
*.md
```

## Usage Patterns

### Pattern 1: Single Service App
```markdown
User: "Dockerize my Next.js app"

1. Detect Next.js (next.config.js)
2. Generate Next.js Dockerfile (standalone)
3. Create .dockerignore
4. Output: Ready to docker build!
```

### Pattern 2: Full-stack App
```markdown
User: "Create Docker setup for my app"

1. Detect frontend/ and backend/ directories
2. Generate Dockerfile for each
3. Create docker-compose.yml linking services
4. Add database service if needed
5. Output: Run docker-compose up!
```

### Pattern 3: Add to Existing Project
```markdown
User: "Add Docker to this Python API"

1. Detect FastAPI/Django/Flask
2. Generate optimized Dockerfile
3. Create .dockerignore
4. Suggest docker-compose for dev
```

## Best Practices Built-in

### 1. Multi-stage Builds
```dockerfile
✅ GOOD: Separate build and production stages
❌ BAD: Single stage with dev dependencies
```

### 2. Layer Caching
```dockerfile
✅ GOOD: Copy package.json first, then npm install
❌ BAD: Copy all files, then install
```

### 3. Security
```dockerfile
✅ GOOD: Use alpine images, non-root user
❌ BAD: Full OS image as root
```

### 4. Size Optimization
```dockerfile
✅ GOOD: --only=production, .dockerignore
❌ BAD: Include all files, dev dependencies
```

## Project Detection

```javascript
// Auto-detect project type
if (exists('next.config.js')) return 'nextjs';
if (exists('package.json') && hasReactScripts()) return 'react';
if (exists('package.json')) return 'nodejs';
if (exists('requirements.txt')) return 'python';
if (exists('go.mod')) return 'go';
```

## Commands

### Test Generated Config
```bash
# Build image
docker build -t myapp .

# Run container
docker run -p 3000:3000 myapp

# Run with compose
docker-compose up
```

### Verify Optimization
```bash
# Check image size
docker images myapp

# Check layers
docker history myapp
```

## Integration with Other Skills

Works with:
- **aws-lambda** - Containerized Lambda functions
- **aws-ecs** - Deploy to ECS
- **developing-with-docker** - Docker best practices
- **backend-patterns** - API containerization

## Optimization Features

### Image Size Reduction
- Multi-stage builds (50-70% smaller)
- Alpine base images
- .dockerignore exclusions
- Production-only dependencies

### Build Speed
- Layer caching
- Dependency pre-installation
- Parallel builds in compose

### Security
- Non-root user
- Minimal base images
- No secrets in images
- Health checks

## Example Output

```bash
# After running docker-automation:

Created:
├── Dockerfile (optimized multi-stage)
├── docker-compose.yml (if multi-service)
└── .dockerignore (comprehensive)

Next steps:
1. docker build -t myapp .
2. docker run -p 3000:3000 myapp
   OR
   docker-compose up

Image size: ~150MB (vs 800MB unoptimized)
Build time: ~2min (with caching)
```

## Notes

- **Always multi-stage** - Reduces image size 50-70%
- **Cache dependencies** - Faster rebuilds
- **Use .dockerignore** - Excludes unnecessary files
- **Alpine preferred** - Smaller, more secure
- **Health checks** - Auto-added for production

## Quick Start

1. **Navigate to project** - `cd my-project`
2. **Ask Gemini** - "Dockerize this app"
3. **Review generated files** - Check Dockerfile, compose
4. **Build and run** - `docker-compose up`

---

**From zero to containerized in 60 seconds!** 🐳
