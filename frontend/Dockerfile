FROM node:20 AS builder

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
# Optional if you have a build step (React/Vue/Angular)
# RUN npm run build

# Runtime stage (if building a static site)
FROM node:20
WORKDIR /app
COPY --from=builder /app .
EXPOSE 3000
CMD ["npm", "start"]
