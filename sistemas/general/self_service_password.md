# Self Service Password

---

## Contenido

- [Self Service Password](#self-service-password)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Self Service Password en Debian 12](#instalar-self-service-password-en-debian-12)
  - [Extras](#extras)

---

## Documentación

- [Página oficial](https://www.ltb-project.org/index.html)

- [Parámetros de configuración](https://self-service-password.readthedocs.io/en/latest/config_general.html)

---

## Instalación

### [Instalar Self Service Password en Debian 12](https://self-service-password.readthedocs.io/en/latest/installation.html#debian-ubuntu)

1. Instalar requerimientos:

    ```sh
    apt install smarty3 gnupg nginx php-fpm
    ```

2. Agregar repositorio:

    ```sh
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/ltb-project.gpg] https://ltb-project.org/debian/stable stable main" >> /etc/apt/sources.list.d/ltb-project.list && \
      wget -O - https://ltb-project.org/documentation/_static/RPM-GPG-KEY-LTB-project | gpg --dearmor | tee /usr/share/keyrings/ltb-project.gpg >/dev/null && \
      apt update
    ```

3. Instalar SSP:

    ```sh
    apt install self-service-password
    ```

4. Configurar nginx:

   1. Borrar apache si existe:

      ```sh
      apt remove apache2 --purge
      ```

   2. Crear conf:

      ```sh
      mkdir /var/log/ssp
      touch /var/log/ssp/error.log /var/log/ssp/access.log
      nano /etc/nginx/conf.d/ssp.conf
      ```

      ```nginx
       server {
          listen 80;

          root /usr/share/self-service-password/htdocs;
          index index.php index.html index.htm;

          server_name _;

          sendfile off;

          gzip on;
          gzip_comp_level 6;
          gzip_min_length 1000;
          gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript text/x-js;
          gzip_vary on;
          gzip_proxied any;
          gzip_disable "MSIE [1-6]\.(?!.*SV1)";

          error_log /var/log/ssp/error.log;
          access_log /var/log/ssp/access.log;

          location ~ \.php {
                  fastcgi_pass unix:/var/run/php/php-fpm.sock;
                  fastcgi_split_path_info       ^(.+\.php)(/.+)$;
                  fastcgi_param PATH_INFO       $fastcgi_path_info;
                  fastcgi_param PATH_TRANSLATED $document_root$fastcgi_path_info;
                  fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
                  fastcgi_index index.php;
                  try_files $fastcgi_script_name =404;
                  fastcgi_read_timeout 600;
                  include fastcgi_params;
          }

          location ~ /\. {
                  log_not_found off;
                  deny all;
          }

          location ~ /scripts {
                  log_not_found off;
                  deny all;
          }

      }
      ```

      ```sh
      rm /etc/nginx/sites-enabled/default
      nginx -s reload
      ```

   3. Agregar en ***/etc/php/8.2/fpm/php.ini***:

      ```ini
      session.save_path = /tmp
      upload_max_filesize = 10M
      post_max_size = 16M
      max_execution_time = 600
      expose_php = Off
      output_buffering = 4096
      ```

5. Crear el archivo ***/usr/share/self-service-password/conf/config.inc.local.php*** y usarlo para sobreescribir los parámetros del otro archivo revisando la [documentación](#documentación).

---

## Extras