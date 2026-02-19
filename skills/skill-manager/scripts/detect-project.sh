#!/bin/bash
# Project Type Detector - Auto-detect project type for skill activation
# Returns project type(s) found

PROJECT_DIR="${1:-.}"

detected_types=()

echo "Detecting project type in: $PROJECT_DIR"
echo ""

# Frontend Detection
if [ -f "$PROJECT_DIR/next.config.js" ] || [ -f "$PROJECT_DIR/next.config.mjs" ]; then
    detected_types+=("nextjs")
    echo "✓ Detected: Next.js"
fi

if [ -f "$PROJECT_DIR/package.json" ]; then
    if grep -q "\"react\"" "$PROJECT_DIR/package.json" 2>/dev/null; then
        detected_types+=("react")
        echo "✓ Detected: React"
    fi
    
    if grep -q "\"@types/node\"" "$PROJECT_DIR/package.json" 2>/dev/null; then
        detected_types+=("nodejs")
        echo "✓ Detected: Node.js"
    fi
fi

# Backend Detection
if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    detected_types+=("python")
    echo "✓ Detected: Python"
    
    if grep -q "fastapi" "$PROJECT_DIR/requirements.txt" 2>/dev/null; then
        detected_types+=("fastapi")
        echo "✓ Detected: FastAPI"
    fi
fi

# Docker Detection
if [ -f "$PROJECT_DIR/Dockerfile" ] || [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
    detected_types+=("docker")
    echo "✓ Detected: Docker"
fi

# AWS Detection
if [ -d "$PROJECT_DIR/.aws" ] || [ -d "$PROJECT_DIR/aws" ]; then
    detected_types+=("aws")
    echo "✓ Detected: AWS"
fi

if [ -f "$PROJECT_DIR/template.yaml" ] || [ -f "$PROJECT_DIR/template.yml" ]; then
    detected_types+=("aws-sam")
    echo "✓ Detected: AWS SAM"
fi

# Testing Detection
if [ -f "$PROJECT_DIR/jest.config.js" ] || [ -f "$PROJECT_DIR/jest.config.ts" ]; then
    detected_types+=("jest")
    echo "✓ Detected: Jest Testing"
fi

if [ -f "$PROJECT_DIR/playwright.config.ts" ]; then
    detected_types+=("playwright")
    echo "✓ Detected: Playwright Testing"
fi

# TypeScript Detection
if [ -f "$PROJECT_DIR/tsconfig.json" ]; then
    detected_types+=("typescript")
    echo "✓ Detected: TypeScript"
fi

echo ""
echo "Project Types: ${detected_types[@]}"
echo ""

# Export for auto-activation
echo "${detected_types[@]}"
