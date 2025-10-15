# Use official Node.js 20 image as base
FROM node:20

# Set working directory inside container
WORKDIR /app

# Copy package.json and package-lock.json first to leverage Docker cache
COPY package.json package-lock.json ./

# Clean npm cache forcefully and install dependencies
RUN npm cache clean --force && npm ci --legacy-peer-deps

# Copy the rest of the application source code
COPY . .

# Expose the port your app runs on (3000 for React)
EXPOSE 3000

# Start the React app
CMD ["npm", "start"]
