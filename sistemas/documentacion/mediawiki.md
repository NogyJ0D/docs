# MediaWiki

---

## Contenido

- [MediaWiki](#mediawiki)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Extras](#extras)
    - [Si el editor rompe las categorías](#si-el-editor-rompe-las-categorías)

---

## Documentación

- YA NO EXISTE!!!! - [Configuración Nginx recomendada](https://www.nginx.com/resources/wiki/start/topics/recipes/mediawiki/)

---

## Instalación

---

## Extras

### Si el editor rompe las categorías

1. Tener la configuración de Nginx como la [recomendada](#documentación):

   ```nginx
   server {
     listen 443 ssl;
     server_name wiki;
     root /var/www/html/wiki;
     index index.html index.php;

     access_log /var/log/nginx/mediawiki_access.log;
     error_log /var/log/nginx/mediawiki_error.log;

     ssl_certificate /etc/ssl/certs/mediawiki.crt;
     ssl_certificate_key /etc/ssl/private/mediawiki.key;

     location / {
       try_files $uri $uri/ @rewrite;
     }

     location @rewrite {
       rewrite ^/(.*)$ /index.php?title=$1&$args;
     }

     location ^~ /maintenance/ {
       return 403;
     }

     location /rest.php {
       try_files $uri $uri/ /rest.php?$args;
     }

     location ~ \.php$ {
       include fastcgi_params;
       fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
       fastcgi_param SCRIPT_FILENAME $request_filename;
     }

     location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
       try_files $uri /index.php;
       expires max;
       log_not_found off;
     }

     location = /_.gif {
       expires max;
       empty_gif;
     }

     location ^~ /cache/ {
       deny all;
     }

     location /dumps {
       root /var/www/html/wiki/local;
       autoindex on;
     }
   }
   ```

2. Agregar en el LocalSettings.php el parámetro "$wgUsePathInfo = true;".
