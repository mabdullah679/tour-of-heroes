############################################################
# Stage 1: Build the Angular App
############################################################
FROM node:18.19.0 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the Angular app's source code
COPY . .

# Build the Angular app for production
RUN npm run build --output-path=dist/tour-of-heroes/browser --base-href=/

############################################################
# Stage 2: Use Nginx to serve the built Angular app
############################################################
FROM nginx:stable-alpine

# Copy the custom nginx.conf to handle SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Angular files from Stage 1 to Nginx's html directory
COPY --from=build /app/dist/tour-of-heroes/browser /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server in the foreground
CMD ["nginx", "-g", "daemon off;"]
