# Nextcloud

---

## Contenido

- [Nextcloud](#nextcloud)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Nextcloud en Debian 12](#instalar-nextcloud-en-debian-12)
      - [Instalar con Apache](#instalar-con-apache)
      - [Instalar con Nginx](#instalar-con-nginx)
    - [Instalar Nextcloud con docker](#instalar-nextcloud-con-docker)
    - [Instalar Nextcloud en Mageia](#instalar-nextcloud-en-mageia)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### Instalar Nextcloud en Debian 12

#### [Instalar con Apache](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)

1. Instalar requisitos:

   1. Instalar php:

      ```sh
      apt update && apt upgrade -y

      apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip php-bz2 php-apcu php-redis libmagickcore-6.q16-6-extra unzip wget sudo -y
      ```

      - Para agregar LDAP instalar "php-ldap".

   2. Editar en ***/etc/php/x.x/apache2/php.ini***:

      ```ini
      max_execution_time = 300
      memory_limit = 512M
      post_max_size = 128M
      upload_max_filesize = 128M
      ```

   3. Reiniciar servicio:

      ```sh
      systemctl restart apache2
      ```

2. Crear DB:

    ```sh
    mysql
    ```

    ```sql
    CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'password';
    CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
    GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
    FLUSH PRIVILEGES;
    QUIT;
    ```

3. Descargar Nextcloud:

    ```sh
    wget https://download.nextcloud.com/server/releases/latest.zip && unzip latest.zip

    cp -r nextcloud /var/www

    sudo chown -R www-data:www-data /var/www/nextcloud
    ```

4. [Configurar Apache](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#apache-configuration-label):

    1. Crear espacio:

        ```sh
        nano /etc/apache2/sites-available/nextcloud.conf
        ```

        ```apache
        Alias /nextcloud "/var/www/nextcloud/"

        <Directory /var/www/nextcloud/>
            Require all granted
            AllowOverride All
            Options FollowSymLinks MultiViews

            <IfModule mod_dav.c>
                Dav off
            </IfModule>
        </Directory>
        ```

        ```sh
        a2ensite nextcloud.conf
        ```

    2. Habilitar módulos:

        ```sh
        a2enmod rewrite && \
        a2enmod headers && \
        a2enmod env && \
        a2enmod dir && \
        a2enmod mime
        ```

    3. Reiniciar servicio:

        ```sh
        service apache2 restart
        ```

5. Entrar a Nextcloud y realizar instalación web.

6. [Configurar Pretty URL](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#pretty-urls):

    ```sh
    nano /var/www/nextcloud/config/config.php
    ```

    ```php
    'overwrite.cli.url' => 'https://example.org/nextcloud',
    'htaccess.RewriteBase' => '/nextcloud',
    ```

    ```sh
    sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess
    ```

7. [Instalar Redis](../../database/nosql/redis.md#instalar-redis-en-debian-12) para mejorar el rendimiento.

    - Agregar en ***/var/www/nextcloud/config/config.php***:

      ```php
      'filelocking.enabled' => true,
      'memcache.locking' => '\OC\Memcache\Redis',
      'redis' => array(
        'host' => '/var/run/redis/redis.sock',
        'port' => 0,
        'timeout' => 0.0,
      ),
      ```

8. [Habilitar SSL](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#enabling-ssl).

9. [Habilitar cron](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html#cron-jobs):

    ```sh
    crontab -u www-data -e
    ```

    ```text
    */5 * * * * php -f /var/www/nextcloud/cron.php
    ```

10. Ir al panel de administración y corregir las advertencias.

#### [Instalar con Nginx](https://www.linuxtuto.com/how-to-install-nextcloud-on-debian-12/)

1. [Instalar Nginx](../../web/servidores/nginx.md#instalar-nginx-en-debian).

2. Instalar php y extensiones:

   1. Instalar php

      ```sh
      apt install -y php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-intl php-curl php-xml php-mbstring php-bcmath php-gmp php-bz2 php-imagick php-apcu php-redis libmagickcore-6.q16-6-extra wget unzip sudo
      ```

      - Para agregar LDAP instalar "php-ldap".

   2. Editar en ***/etc/php/x.x/fpm/php.ini***:

      ```ini
      max_execution_time = 300
      memory_limit = 512M
      post_max_size = 128M
      upload_max_filesize = 128M
      ```

   3. Descomentar en ***/etc/php/x.x/fpm/pool.d/www.conf***:

      ```conf
      env[HOSTNAME] = $HOSTNAME
      env[PATH] = /usr/local/bin:/usr/bin:/bin
      env[TMP] = /tmp
      env[TMPDIR] = /tmp
      env[TEMP] = /tmp
      ```

   4. Reiniciar servicio:

      ```sh
      systemctl restart php8.2-fpm
      ```

3. [Instalar MariaDB](../../database/sql/mariadb.md#instalar-mariadb-en-debian-12).

   1. Crear DB:

      ```sql
      CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'password';
      CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
      GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
      FLUSH PRIVILEGES;
      QUIT;
      ```

4. Descargar Nextcloud:

    ```sh
    wget  https://download.nextcloud.com/server/releases/latest.zip && \
      unzip latest.zip -d /var/www/
    chown -R www-data:www-data /var/www/nextcloud
    rm /etc/nginx/sites-enabled/default
    ```

5. Configurar nginx:

   - Crear y agregar en ***/etc/nginx/conf.d/nextcloud.conf***:

      <!-- ```nginx
      server {
        listen 80;
        server_name your-domain.com www.your-domain.com;
        root /var/www/nextcloud;
        index index.php index.html;
        charset utf-8;
        location / {
          try_files $uri $uri/ /index.php?$args;
        }
        location ~ .php$ {
          fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          include fastcgi_params;
        }
      }
      ``` -->

      ```nginx
      upstream php-handler {
          server unix:/run/php/php8.2-fpm.sock;
      }

      map $arg_v $asset_immutable {
          "" "";
          default "immutable";
      }


      server {
          listen 80;
          listen [::]:80;
          server_name cloud.example.com;

          server_tokens off;

          return 301 https://$server_name$request_uri;
      }

      server {
          listen 443      ssl http2;
          listen [::]:443 ssl http2;
          server_name cloud.example.com;

          # Path to the root of your installation
          root /var/www/nextcloud;

          ssl_certificate     /etc/ssl/nginx/cloud.example.com.crt;
          ssl_certificate_key /etc/ssl/nginx/cloud.example.com.key;

          server_tokens off;

          # set max upload size and increase upload timeout:
          client_max_body_size 512M;
          client_body_timeout 300s;
          fastcgi_buffers 64 4K;

          # Enable gzip but do not remove ETag headers
          gzip on;
          gzip_vary on;
          gzip_comp_level 4;
          gzip_min_length 256;
          gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
          gzip_types application/atom+xml text/javascript application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

          client_body_buffer_size 512k;

          # HTTP response headers borrowed from Nextcloud `.htaccess`
          add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
          add_header Referrer-Policy                   "no-referrer"       always;
          add_header X-Content-Type-Options            "nosniff"           always;
          add_header X-Frame-Options                   "SAMEORIGIN"        always;
          add_header X-Permitted-Cross-Domain-Policies "none"              always;
          add_header X-Robots-Tag                      "noindex, nofollow" always;
          add_header X-XSS-Protection                  "1; mode=block"     always;

          fastcgi_hide_header X-Powered-By;

          # Add .mjs as a file extension for javascript
          # Either include it in the default mime.types list
          # or include you can include that list explicitly and add the file extension
          # only for Nextcloud like below:
          include mime.types;
          types {
              text/javascript js mjs;
          }

          index index.php index.html /index.php$request_uri;

          # Rule borrowed from `.htaccess` to handle Microsoft DAV clients
          location = / {
              if ( $http_user_agent ~ ^DavClnt ) {
                  return 302 /remote.php/webdav/$is_args$args;
              }
          }

          location = /robots.txt {
              allow all;
              log_not_found off;
              access_log off;
          }

          location ^~ /.well-known {
              # The rules in this block are an adaptation of the rules
              # in `.htaccess` that concern `/.well-known`.

              location = /.well-known/carddav { return 301 /remote.php/dav/; }
              location = /.well-known/caldav  { return 301 /remote.php/dav/; }

              location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
              location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

              return 301 /index.php$request_uri;
          }

          # Rules borrowed from `.htaccess` to hide certain paths from clients
          location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
          location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

          location ~ \.php(?:$|/) {
              # Required for legacy support
              rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode\/proxy) /index.php$request_uri;

              fastcgi_split_path_info ^(.+?\.php)(/.*)$;
              set $path_info $fastcgi_path_info;

              try_files $fastcgi_script_name =404;

              include fastcgi_params;
              fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
              fastcgi_param PATH_INFO $path_info;
              fastcgi_param HTTPS on;

              fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
              fastcgi_param front_controller_active true;     # Enable pretty urls
              fastcgi_pass php-handler;

              fastcgi_intercept_errors on;
              fastcgi_request_buffering off;

              fastcgi_max_temp_file_size 0;
          }

          # Serve static files
          location ~ \.(?:css|js|mjs|svg|gif|png|jpg|ico|wasm|tflite|map|ogg|flac)$ {
              try_files $uri /index.php$request_uri;
              add_header Cache-Control "public, max-age=15778463, $asset_immutable";
              access_log off;     # Optional: Don't log access to assets

              location ~ \.wasm$ {
                  default_type application/wasm;
              }
          }

          location ~ \.woff2?$ {
              try_files $uri /index.php$request_uri;
              expires 7d;         # Cache-Control policy borrowed from `.htaccess`
              access_log off;     # Optional: Don't log access to assets
          }

          location /remote {
              return 301 /remote.php$request_uri;
          }

          location / {
              try_files $uri $uri/ /index.php$request_uri;
          }
      }
      ```

   - Ejecutar:

      ```sh
      systemctl restart nginx
      ```

6. [Crear certificado](../../web/general/certbot.md#generar-certificados).

7. Entrar a la url de nextcloud e instalar.

8. [Instalar Redis](../../database/nosql/redis.md#instalar-redis-en-debian-12) para mejorar el rendimiento.

    - Agregar en ***/var/www/nextcloud/config/config.php***:

      ```php
      'memcache.local' => '\OC\Memcache\APCu',
      'filelocking.enabled' => true,
      'memcache.locking' => '\OC\Memcache\Redis',
      'redis' => array(
        'host' => '/var/run/redis/redis.sock',
        'port' => 0,
        'timeout' => 0.0,
      ),
      ```

9. [Habilitar cron](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html#cron-jobs):

    ```sh
    crontab -u www-data -e
    ```

    ```text
    */5 * * * * php -f /var/www/nextcloud/cron.php
    ```

10. Ir al panel de administración y corregir las advertencias.

### [Instalar Nextcloud con docker](https://github.com/nextcloud/docker)

- Docker Compose

    ```yml
    version: '2'

    volumes:
      nextcloud:
      db:

    services:
      db:
        image: mariadb:10.6
        restart: always
        command: --transaction-isolation=READ-COMMITTED --log-bin=binlog --binlog-format=ROW
        volumes:
          - db:/var/lib/mysql
        environment:
          - MYSQL_ROOT_PASSWORD=<SETEAR>
          - MYSQL_PASSWORD=<SETEAR>
          - MYSQL_DATABASE=nextcloud
          - MYSQL_USER=nextcloud

      app:
        image: nextcloud:fpm
        restart: always
        links:
          - db
        volumes:
          - nextcloud:/var/www/html
        environment:
          - MYSQL_PASSWORD=<SETEAR>
          - MYSQL_DATABASE=nextcloud
          - MYSQL_USER=nextcloud
          - MYSQL_HOST=db

      web:
        image: nginx
        restart: always
        ports:
          - 8080:80
        links:
          - app
        volumes:
          - ./nginx.conf:/etc/nginx/nginx.conf:ro
        volumes_from:
          - app
    ```

### [Instalar Nextcloud en Mageia](https://wiki.mageia.org/en/Nextcloud_server_installation_with_NGINX)

---

## Extras
