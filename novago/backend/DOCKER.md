# Docker Setup Guide for NovaGo Backend

This guide explains how to build and run the NovaGo backend using Docker.

## Prerequisites

- Docker installed on your system
- Docker Compose (optional, but recommended)

## Quick Start

### Using Docker Compose (Recommended)

1. **Create a `.env` file** (copy from `.env.example`):
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env` file** and set your JWT_SECRET:
   ```
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   PORT=4000
   NODE_ENV=production
   ```

3. **Build and run**:
   ```bash
   docker-compose up -d
   ```

4. **View logs**:
   ```bash
   docker-compose logs -f
   ```

5. **Stop the container**:
   ```bash
   docker-compose down
   ```

### Using Docker directly

1. **Build the image**:
   ```bash
   docker build -t novago-backend .
   ```

2. **Run the container**:
   ```bash
   docker run -d \
     --name novago-backend \
     -p 4000:4000 \
     -e JWT_SECRET=your-super-secret-jwt-key \
     -e PORT=4000 \
     -e NODE_ENV=production \
     -v $(pwd)/uploads:/app/uploads \
     novago-backend
   ```

3. **View logs**:
   ```bash
   docker logs -f novago-backend
   ```

4. **Stop the container**:
   ```bash
   docker stop novago-backend
   docker rm novago-backend
   ```

## Environment Variables

- `PORT` - Server port (default: 4000)
- `JWT_SECRET` - Secret key for JWT tokens (REQUIRED in production)
- `NODE_ENV` - Environment (production, development)

## Persistent Storage

The `uploads` directory is mounted as a volume to persist uploaded files (restaurant images, menu items, etc.) even when the container is restarted.

## Health Check

The container includes a health check that monitors the `/health` endpoint. You can check the health status with:

```bash
docker ps
```

The health status will be shown in the STATUS column.

## Building for Production

For production deployment, ensure:

1. Set a strong `JWT_SECRET` in your `.env` file
2. Use `NODE_ENV=production`
3. Map the correct port (default 4000)
4. Set up proper volume mounts for uploads
5. Configure your reverse proxy (nginx, etc.) if needed

## Troubleshooting

### Container won't start
- Check logs: `docker-compose logs backend`
- Verify environment variables are set correctly
- Ensure port 4000 is not already in use

### Uploads not persisting
- Check that the `uploads` volume is properly mounted
- Verify directory permissions: `ls -la uploads`

### Health check failing
- Check if the server is responding: `curl http://localhost:4000/health`
- Review container logs for errors

## Production Deployment Tips

1. **Use Docker secrets** or environment variable injection for sensitive data
2. **Set up a reverse proxy** (nginx, Traefik) for SSL termination
3. **Use Docker networks** for service communication
4. **Set resource limits** in docker-compose.yml:
   ```yaml
   deploy:
     resources:
       limits:
         cpus: '1'
         memory: 512M
   ```
5. **Enable logging** to a centralized service
6. **Use Docker swarm** or Kubernetes for orchestration in production

