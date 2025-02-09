# Use Node.js Alpine image which is much smaller and includes necessary build tools
FROM node:20-alpine

WORKDIR /app

# Install wget for health checks
RUN apk add --no-cache wget

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Environment variables for better Docker compatibility
ENV HOST=0.0.0.0
ENV NODE_ENV=development
ENV VITE_DEV_SERVER_HOST=0.0.0.0
ENV VITE_DEV_SERVER_PORT=3000
ENV VITE_HMR_HOST=frontend
ENV VITE_HMR_PORT=24678

# Expose both the main port and WebSocket port
EXPOSE 3000 24678

CMD ["npm", "run", "dev"]