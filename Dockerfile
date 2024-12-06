######### Multistage Docker build and distroless docker image ###########
######### Remember to update the port on which the app is running in the k8 manifest files and the security gates port in EC2 ###########
#####################################################################################

# Stage 1: Build the React application
FROM node:16-alpine AS build

# Set working directory
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the application code and build the app
COPY . .
RUN npm run build

# Stage 2: Serve the static files using nginx
FROM nginx:alpine

# Copy the build output to Nginx’s default html directory
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 80 for the web server
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]

