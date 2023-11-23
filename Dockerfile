# Dockerfile
FROM nginx:alpine

# Copy everything over
COPY index.html /usr/share/nginx/html/index.html
COPY css /usr/share/nginx/html/css
COPY fonts /usr/share/nginx/html/fonts
COPY images /usr/share/nginx/html/images
COPY js /usr/share/nginx/html/js
COPY sass /usr/share/nginx/html/sass
