# 🐳 Quick Docker Start (PowerShell)

## Prerequisites
Make sure Docker Desktop is running on Windows.

## Step 1: Navigate to Backend Directory

```powershell
cd backend
```

## Step 2: Create .env File (Optional but Recommended)

Create a `.env` file in the `backend` directory with:

```env
PORT=4000
NODE_ENV=production
JWT_SECRET=your-super-secret-jwt-key-change-this
```

## Step 3: Build and Run with Docker Compose

```powershell
# Build and start the container
docker-compose up -d --build

# View logs
docker-compose logs -f

# Check status
docker ps
```

## Alternative: Build Docker Image Manually

```powershell
# Build the image
docker build -t novago-backend .

# Run the container
docker run -d `
  --name novago-backend `
  -p 4000:4000 `
  -e JWT_SECRET=your-secret-key `
  -e PORT=4000 `
  -e NODE_ENV=production `
  -v ${PWD}/uploads:/app/uploads `
  novago-backend
```

## Verify It's Running

```powershell
# Test health endpoint
Invoke-WebRequest -Uri http://localhost:4000/health

# Check container status
docker ps

# View logs
docker logs novago-backend
```

## Common Commands

```powershell
# Stop the container
docker-compose down

# Restart
docker-compose restart

# Rebuild after code changes
docker-compose up -d --build

# Remove everything (containers, images, volumes)
docker-compose down --rmi all
```

## Troubleshooting

### Port 4000 already in use
```powershell
# Find what's using port 4000
netstat -ano | findstr :4000

# Or change port in docker-compose.yml to 4001:4000
```

### View container logs
```powershell
docker-compose logs backend
# or
docker logs novago-backend
```

### Container won't start
```powershell
# Check logs for errors
docker logs novago-backend

# Try running in foreground to see errors
docker-compose up
```

### Rebuild after code changes
```powershell
docker-compose up -d --build
```
