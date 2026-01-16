# Base image
FROM nginx:latest

# Author info
LABEL maintainer="student@docker.com"

# Set working directory inside container
WORKDIR /usr/share/nginx/html

# Remove default nginx website files
RUN rm -rf *

# Copy our static website file into working directory
COPY index.html .

# Expose nginx port
EXPOSE 80

# Start nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
