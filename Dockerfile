# Multi-stage build for Nx customer-backend
FROM node:18-alpine AS base

# Install pnpm and database client tools
RUN npm install -g pnpm@8
RUN apk add --no-cache postgresql-client mongodb-tools redis mysql-client

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Install dependencies
RUN pnpm install 
# Copy source code
COPY . .

# Build stage
FROM base AS builder

# Build the application
RUN pnpm run build

# Production stage
FROM node:18-alpine AS production

# Install pnpm and database client tools
RUN npm install -g pnpm@8
RUN apk add --no-cache postgresql-client mongodb-tools redis mysql-client

# Create app directory
WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Install all dependencies (including dev dependencies needed for build)
RUN pnpm install

# Copy built application from builder stage
COPY --from=builder /app/dist/backend-apps/customer-backend ./dist/backend-apps/customer-backend

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nestjs -u 1001

# Change ownership of the app directory
RUN chown -R nestjs:nodejs /app
USER nestjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Set production environment
ENV NODE_ENV=production
ENV NX_CLOUD_DISTRIBUTED_EXECUTION=false
ENV NX_CLOUD_NO_TIMEOUTS=true

# Start the application
CMD ["node", "dist/backend-apps/customer-backend/main.js"]
