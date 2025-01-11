# Stage 1: Build the Angular App
FROM node:18.19.0 AS build

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Angular app for prod
RUN npm run build --output-path=dist --base-href=/

# Use Nginx as the base image for serving the Angular app
FROM nginx:stable-alpine

# Copy build Angular files to the Nginx html directory
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]
