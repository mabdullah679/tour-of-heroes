# Stage 1: Build the Angular App
FROM node:18 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the entire app source code
COPY . .

# Build the Angular app for production
RUN npm run build

# Stage 2: Use Nginx to serve the built Angular app
FROM nginx:stable-alpine

# Copy built Angular files to the correct directory in the container
COPY --from=build /app/dist/browser /usr/share/nginx/html

# Copy the Nginx configuration
COPY cont-nginx.conf /etc/nginx/nginx.conf
# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
