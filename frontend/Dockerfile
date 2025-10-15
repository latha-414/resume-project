# Stage 1: Build dependencies
FROM node:20-slim AS builder

WORKDIR /app

# Copy only dependency files first for caching
COPY package*.json ./

# Faster, reproducible install
RUN npm ci --legacy-peer-deps

# Copy remaining source code
COPY . .

# Stage 2: Run app
FROM node:20-slim

WORKDIR /app
COPY --from=builder /app .

EXPOSE 3000
CMD ["npm", "start"]
