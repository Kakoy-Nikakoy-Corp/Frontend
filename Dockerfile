# Stage 1: Build the application
FROM node:22-alpine AS builder

WORKDIR /app

# Copy package files
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the app (this creates the .svelte-kit/output directory)
RUN npm run build

# Stage 2: Production runtime
FROM node:22-alpine AS production

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/.svelte-kit/output ./output

# COPY --from=builder /app/package.json ./package.json
# COPY --from=builder /app/node_modules ./node_modules

EXPOSE 3000
CMD ["node", "output/server/index.js"]