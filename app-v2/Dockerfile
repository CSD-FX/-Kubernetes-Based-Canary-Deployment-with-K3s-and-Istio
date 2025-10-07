FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
RUN echo "Server: app-v1.1" > /usr/share/nginx/html/version.txt
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
