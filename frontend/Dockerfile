# Use official Node.js 20 image as base
FROM node:20

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package.json package-lock.json ./

# Update npm to latest version to avoid known bugs and clean npm cache to avoid corrupted packages
RUN npm install -g npm@latest
RUN npm cache clean --force

# Install dependencies exactly as per package-lock.json while ignoring peer dependency conflicts
RUN npm ci --legacy-peer-deps

# Copy the rest of the frontend source code
COPY . .

# Expose the React app port
EXPOSE 3000

# Start the React app
CMD ["npm", "start"]
