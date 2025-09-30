#!/bin/bash

# Deployment script for /var/project
# This script will be executed on the target server

set -e

PROJECT_DIR="/var/project"
BACKUP_DIR="/var/project-backup"
TEMP_DIR="/tmp/project-deploy"

echo "Starting deployment process..."

# Create backup of current deployment
if [ -d "$PROJECT_DIR" ]; then
    echo "Creating backup of current deployment..."
    rm -rf "$BACKUP_DIR"
    cp -r "$PROJECT_DIR" "$BACKUP_DIR"
fi

# Create temporary directory for new deployment
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Copy new files to temporary directory
cp -r dist/apps/customer-app/* "$TEMP_DIR/"

# Stop application service if it exists
if systemctl is-active --quiet customer-app 2>/dev/null; then
    echo "Stopping customer-app service..."
    systemctl stop customer-app
fi

# Replace current deployment with new one
echo "Deploying new version..."
rm -rf "$PROJECT_DIR"
mkdir -p "$PROJECT_DIR"
cp -r "$TEMP_DIR"/* "$PROJECT_DIR/"

# Set proper permissions
chown -R www-data:www-data "$PROJECT_DIR" 2>/dev/null || chown -R root:root "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"

# Start application service if it exists
if systemctl is-active --quiet customer-app 2>/dev/null; then
    echo "Starting customer-app service..."
    systemctl start customer-app
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Deployment completed successfully!"
echo "New version is now live at $PROJECT_DIR"
