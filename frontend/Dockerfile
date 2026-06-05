FROM nginx:alpine

# Copiar archivos estáticos al directorio de Nginx
COPY static/ /usr/share/nginx/html/static/

# Copiar configuración personalizada de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
