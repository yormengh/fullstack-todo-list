# frontend/Dockerfile
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies
RUN npm ci

# Copy source code
COPY . .

# Debug: List contents before build
RUN echo "Contents before build:" && ls -la

# Build the application
RUN npm run build

# Debug: List contents after build to see what was created
RUN echo "Contents after build:" && ls -la
RUN echo "Checking for common build directories:" && \
    (ls -la dist/ 2>/dev/null || echo "No dist/ directory") && \
    (ls -la build/ 2>/dev/null || echo "No build/ directory") && \
    (ls -la public/ 2>/dev/null || echo "No public/ directory")

# Production stage
FROM nginx:alpine

# Copy built assets from the correct directory (Vite uses dist by default)
COPY --from=build /app/dist /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]