# Use official Node.js 20 image as base
FROM node:20

# Set working directory inside container
WORKDIR /app

# Copy only package.json (do not copy package-lock.json)
COPY package.json ./

# Install dependencies, ignoring peer dependency conflicts, without package-lock.json
RUN npm cache clean --force && npm install

# Copy the rest of the frontend source code
COPY . .

# Expose React app port
EXPOSE 3000

# Start the React app
CMD ["npm", "start"]
