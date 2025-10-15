# Stage 1: Build
FROM node:20 AS builder

WORKDIR /app

# Copy package.json and package-lock.json first (cache npm install)
COPY package.json package-lock.json ./

# Install dependencies exactly as per package-lock.json
RUN npm ci --legacy-peer-deps

# Copy the rest of the source code
COPY . .

# Optional: build the app if you want static files
# RUN npm run build

# Stage 2: Runtime
FROM node:20

WORKDIR /app

# Copy everything from builder
COPY --from=builder /app .

EXPOSE 3000

# Start the app
CMD ["npm", "start"]
