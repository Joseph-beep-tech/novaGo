@echo off
REM Build script for NovaGo Backend Docker image (Windows)

echo Building NovaGo Backend Docker image...

docker build -t novago-backend:latest .

if %ERRORLEVEL% EQU 0 (
    echo Build successful!
    echo Run with: docker-compose up -d
) else (
    echo Build failed!
    exit /b 1
)

