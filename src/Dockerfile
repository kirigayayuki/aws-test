FROM ubuntu
RUN apt update
RUN apt install -y nginx
ADD index.html /usr/share/nginx/html/
ADD nginx.conf /etc/nginx/
CMD ["nginx", "-g", "daemon off;"]
