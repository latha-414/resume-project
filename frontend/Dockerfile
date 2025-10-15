# Stage 1: Build dependencies
FROM node:20-slim AS builder

WORKDIR /app

# Copy only package.json (and package-lock.json if you have it)
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy rest of the code
COPY . .

# Optional: build for production (creates /app/build folder)
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy built files from previous stage
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port 80 for Nginx
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
