# Multi-stage build for Nx customer-backend
FROM node:18-alpine AS base

# Install pnpm and database client tools
RUN npm install -g pnpm@8
RUN apk add --no-cache postgresql-client mongodb-tools redis mysql-client

# Set working directory
WORKDIR /app

# Copy workspace configuration
COPY pnpm-workspace.yaml ./

# Copy backend workspace files
COPY backend-apps/package.json ./backend-apps/
COPY backend-apps/customer-backend/package.json ./backend-apps/customer-backend/
COPY pnpm-lock.yaml ./backend-apps/
COPY backend-apps/nx.json backend-apps/tsconfig.base.json ./backend-apps/

# Install dependencies in backend workspace
WORKDIR /app/backend-apps
RUN pnpm install

# Install dependencies in customer-backend
WORKDIR /app/backend-apps/customer-backend
RUN pnpm install

# Copy all source code
WORKDIR /app
COPY . .

# Build stage
FROM base AS builder

# Copy the pre-built application from local build
WORKDIR /app/backend-apps
COPY backend-apps/dist/customer-backend ./dist/customer-backend

# Production stage
FROM node:18-alpine AS production

# Install pnpm and database client tools
RUN npm install -g pnpm@8
RUN apk add --no-cache postgresql-client mongodb-tools redis mysql-client

# Create app directory
WORKDIR /app

# Copy workspace configuration
COPY pnpm-workspace.yaml ./

# Copy backend workspace files
COPY backend-apps/package.json ./backend-apps/
COPY backend-apps/customer-backend/package.json ./backend-apps/customer-backend/
COPY pnpm-lock.yaml ./backend-apps/
COPY backend-apps/nx.json backend-apps/tsconfig.base.json ./backend-apps/

# Install production dependencies in backend workspace
WORKDIR /app/backend-apps
RUN pnpm install --prod

# Install production dependencies in customer-backend
WORKDIR /app/backend-apps/customer-backend
RUN pnpm install --prod

# Copy built application from builder stage
COPY --from=builder /app/backend-apps/dist/customer-backend ./dist/customer-backend

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
WORKDIR /app/backend-apps/customer-backend
CMD ["node", "../dist/customer-backend/src/main.js"]
