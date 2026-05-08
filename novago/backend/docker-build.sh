#!/bin/bash

# Build script for NovaGo Backend Docker image

echo "Building NovaGo Backend Docker image..."

docker build -t novago-backend:latest .

if [ $? -eq 0 ]; then
    echo "✓ Build successful!"
    echo "Run with: docker-compose up -d"
else
    echo "✗ Build failed!"
    exit 1
fi

