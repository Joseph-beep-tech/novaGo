# Quick Docker Start Guide

## 🚀 Quick Start

### 1. Create Environment File

Create a `.env` file in the `backend` directory:

```env
PORT=4000
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key-change-this
```

### 2. Build and Run

**Option A: Using Docker Compose (Recommended)**
```bash
docker-compose up -d
```

**Option B: Using Docker directly**
```bash
# Build
docker build -t novago-backend .

# Run
docker run -d \
  --name novago-backend \
  -p 4000:4000 \
  -e JWT_SECRET=your-secret-key \
  -v $(pwd)/uploads:/app/uploads \
  novago-backend
```

### 3. Verify It's Running

```bash
# Check status
docker ps

# Check health
curl http://localhost:4000/health

# View logs
docker-compose logs -f
```

## 📋 Common Commands

```bash
# Start
docker-compose up -d

# Stop
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs -f backend

# Rebuild after code changes
docker-compose up -d --build
```

## 🔧 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server port | 4000 |
| `JWT_SECRET` | JWT signing secret | (required) |
| `NODE_ENV` | Environment mode | production |

## 📁 Important Notes

- The `uploads` directory is mounted as a volume to persist files
- Health checks run every 30 seconds
- Container runs as non-root user for security
- Uses multi-stage build for optimized image size

For detailed documentation, see [DOCKER.md](./DOCKER.md)

