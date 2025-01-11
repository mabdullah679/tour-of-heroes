############################################################
# Stage 1: Build the Angular App
############################################################
FROM node:18.19.0 AS build

# Set working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the Angular app for production
RUN npm run build --output-path=dist --base-href=/

############################################################
# Stage 2: Use Nginx to serve the built app
############################################################
FROM nginx:stable-alpine

# Copy the custom nginx.conf for Angular/SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Angular files from Stage 1 into Nginx's html folder
COPY --from=build /app/dist/tour-of-heroes/* /usr/share/nginx/html/

# Expose port 80 to the outside world
EXPOSE 80

# Start the Nginx server in the foreground
CMD ["nginx", "-g", "daemon off;"]
