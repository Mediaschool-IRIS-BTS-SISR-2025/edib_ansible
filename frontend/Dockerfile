FROM nginx:alpine
LABEL maintainer="edib"

# Copy static frontend into nginx html folder
COPY ./ /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
