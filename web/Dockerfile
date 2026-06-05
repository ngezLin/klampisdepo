# Stage 1: Build the React application
FROM node:18-alpine AS builder

WORKDIR /app

# Copy dependency manifests
COPY package.json package-lock.json ./

# Install packages
RUN npm ci

# Copy source code
COPY . .

# Pass build arguments (e.g. backend API root URL)
# Since we proxy /api to the backend container, we set it to /api to use relative domain routing
ARG REACT_APP_API_URL=/api
ENV REACT_APP_API_URL=$REACT_APP_API_URL

# Build for production
RUN npm run build

# Stage 2: Serve using Nginx
FROM nginx:1.25-alpine

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build files from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
