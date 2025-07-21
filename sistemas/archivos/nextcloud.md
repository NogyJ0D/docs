# Nextcloud

---

## Contenido

- [Nextcloud](#nextcloud)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Nextcloud en Debian 12](#instalar-nextcloud-en-debian-12)
    - [Instalar Nextcloud con docker](#instalar-nextcloud-con-docker)
  - [Extras](#extras)
    - [Activar directorios virtuales en el cliente](#activar-directorios-virtuales-en-el-cliente)
    - [Activar LDAP](#activar-ldap)

---

## Documentación

---

## Instalación

### [Instalar Nextcloud en Debian 12](https://www.linuxtuto.com/how-to-install-nextcloud-on-debian-12/)

1. Instalar Nginx:

   ```sh
   apt install nginx -y
   ```

2. Instalar php y extensiones:

   1. Instalar php

      ```sh
      apt install -y php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-intl php-curl php-xml php-mbstring php-bcmath php-gmp php-bz2 php-imagick php-apcu php-redis php-ldap libmagickcore-6.q16-6-extra php-memcached
      ```

      - Para agregar LDAP instalar "php-ldap".

   2. Editar en **_/etc/php/x.x/fpm/php.ini_** y habilitar opcache:

      ```ini
      memory_limit = 4G # O más según la RAM
      upload_max_filesize = 8G
      post_max_size = 8G
      max_execution_time = 360
      date.timezone = America/Argentina/Buenos_aires

      [opcache]
      opcache.enable=1
      opcache.memory_consumption=512
      opcache.interned_strings_buffer=64
      opcache.max_accelerated_files=50000
      opcache.max_wasted_percentage=15
      opcache.validate_timestamps=0
      opcache.revalidate_freq=0
      opcache.save_comments=1
      ```

   3. Tener en **_/etc/php/x.x/fpm/pool.d/www.conf_**:

      ```conf
      env[HOSTNAME] = $HOSTNAME
      env[PATH] = /usr/local/bin:/usr/bin:/bin
      env[TMP] = /tmp
      env[TMPDIR] = /tmp
      env[TEMP] = /tmp

      pm = dynamic
      pm.max_children = 50
      pm.start_servers = 10
      pm.min_spare_servers = 10
      pm.max_spare_servers = 20
      ```

   4. Reiniciar servicio:

      ```sh
      systemctl restart php8.2-fpm
      ```

3. Instalar MariaDB:

   1. Instalar:

      ```sh
      apt install mariadb-server mariadb-client -y
      mysql_secure_installation
      # Contraseña root
      # N
      # N
      # Y
      # Y
      # Y
      # Y
      ```

   2. Configurar MariaDB:

      - Tener **_/etc/mysql/mariadb.conf.d/50-server.cnf_** como:

        ```conf
        [server]
        skip_name_resolve = 1
        innodb_buffer_pool_size = 8G # Mitad de la ram
        innodb_buffer_pool_instances = 1
        innodb_flush_log_at_trx_commit = 2
        innodb_log_buffer_size = 32M
        innodb_log_file_size = 512M
        innodb_max_dirty_pages_pct = 90
        query_cache_type = 1
        query_cache_limit = 2M
        query_cache_min_res_unit = 2k
        query_cache_size = 64M
        tmp_table_size= 64M
        max_heap_table_size= 64M
        slow_query_log = 1
        slow_query_log_file = /var/log/mysql/slow.log
        long_query_time = 1

        [client-server]
        !includedir /etc/mysql/conf.d/
        !includedir /etc/mysql/mariadb.conf.d/

        [client]
        default-character-set = utf8mb4

        [mysqld]
        character_set_server = utf8mb4
        collation_server = utf8mb4_general_ci
        transaction_isolation = READ-COMMITTED
        binlog_format = ROW
        innodb_large_prefix=on
        innodb_file_format=barracuda
        innodb_file_per_table=1
        read_rnd_buffer_size = 4M
        sort_buffer_size = 4M
        ```

      - Tener **_/etc/php/x.x/fpm/conf.d/20-pdo_mysql.ini_** como:

        ```ini
        extension=pdo_mysql.so

        [mysql]
        mysql.allow_local_infile=On
        mysql.allow_persistent=On
        mysql.cache_size=2000
        mysql.max_persistent=-1
        mysql.max_links=-1
        mysql.default_port=
        mysql.default_socket=/var/run/mysqld/mysqld.sock
        mysql.default_host=
        mysql.default_user=
        mysql.default_password=
        mysql.connect_timeout=60
        mysql.trace_mode=Off
        ```

   3. Crear DB:

      ```sh
      mysql -u root -p
      ```

      ```sql
      CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
      CREATE USER 'nextcloud'@'localhost' IDENTIFIED BY 'Contraseña';
      GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost';
      FLUSH PRIVILEGES;
      EXIT;
      ```

4. Descargar Nextcloud:

   ```sh
   curl -O https://download.nextcloud.com/server/releases/latest.zip && \
     unzip latest.zip -d /var/www/nextcloud-version
   ln -s /var/www/nextcloud-version /var/www/nextcloud
   chown -R www-data:www-data /var/www/nextcloud/
   chmod -R 755 /var/www/nextcloud/
   rm /etc/nginx/sites-enabled/default
   ```

5. Configurar nginx:

   - Si hay un nginx público aparte, agregar en ese lo siguiente:

     ```nginx
     server {
         listen 80;
         server_name cloud.ejemplo.com;

         # Para el proxy inverso
         location / {
             proxy_set_header Host $host;
             proxy_set_header X-Real-IP $remote_addr;
             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
             proxy_set_header X-Forwarded-Proto $scheme;

             # Ajusta la IP interna y el puerto a donde apunta el proxy.
             proxy_pass http://192.168.100.10:80/;
         }
     }

     ```

     ```nginx
     upstream php-handler {
         #server 127.0.0.1:9000;
         server unix:/run/php/php8.2-fpm.sock;
     }

     map $arg_v $asset_immutable {
         "" "";
         default ", immutable";
     }

     #server {
     #    listen 80;
     #    listen [::]:80;
     #    server_name cloud.example.com;
         # Prevent nginx HTTP Server Detection
     #    server_tokens off;

         # Enforce HTTPS
     #    return 301 https://$server_name$request_uri;
     #}

     server {
         # listen 443      ssl;
         # listen [::]:443 ssl;
         # http2 on;
         listen 80;
         server_name cloud.example.com;

         # Path to the root of your installation
         root /var/www/nextcloud;

         #ssl_certificate     /etc/ssl/nginx/cloud.example.com.crt;
         #ssl_certificate_key /etc/ssl/nginx/cloud.example.com.key;

         # Prevent nginx HTTP Server Detection
         server_tokens off;

         # HSTS settings
         # WARNING: Only add the preload option once you read about
         # the consequences in https://hstspreload.org/. This option
         # will add the domain to a hardcoded list that is shipped
         # in all major browsers and getting removed from this list
         # could take several months.
         #add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload" always;

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

         # Pagespeed is not supported by Nextcloud, so if your server is built
         # with the `ngx_pagespeed` module, uncomment this line to disable it.
         #pagespeed off;

         # The settings allows you to optimize the HTTP2 bandwidth.
         # See https://blog.cloudflare.com/delivering-http-2-upload-speed-improvements/
         # for tuning hints
         client_body_buffer_size 512k;

         # HTTP response headers borrowed from Nextcloud `.htaccess`
         add_header Referrer-Policy                   "no-referrer"       always;
         add_header X-Content-Type-Options            "nosniff"           always;
         add_header X-Frame-Options                   "SAMEORIGIN"        always;
         add_header X-Permitted-Cross-Domain-Policies "none"              always;
         add_header X-Robots-Tag                      "noindex, nofollow" always;
         add_header X-XSS-Protection                  "1; mode=block"     always;

         # Remove X-Powered-By, which is an information leak
         fastcgi_hide_header X-Powered-By;

         # Set .mjs and .wasm MIME types
         # Either include it in the default mime.types list
         # and include that list explicitly or add the file extension
         # only for Nextcloud like below:
         include mime.types;
         #types {
             #text/javascript mjs;
             #application/wasm wasm;
         #}

         # Specify how to handle directories -- specifying `/index.php$request_uri`
         # here as the fallback means that Nginx always exhibits the desired behaviour
         # when a client requests a path that corresponds to a directory that exists
         # on the server. In particular, if that directory contains an index.php file,
         # that file is correctly served; if it doesn't, then the request is passed to
         # the front-end controller. This consistent behaviour means that we don't need
         # to specify custom rules for certain paths (e.g. images and other assets,
         # `/updater`, `/ocs-provider`), and thus
         # `try_files $uri $uri/ /index.php$request_uri`
         # always provides the desired behaviour.
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

         # Make a regex exception for `/.well-known` so that clients can still
         # access it despite the existence of the regex rule
         # `location ~ /(\.|autotest|...)` which would otherwise handle requests
         # for `/.well-known`.
         location ^~ /.well-known {
             # The rules in this block are an adaptation of the rules
             # in `.htaccess` that concern `/.well-known`.

             location = /.well-known/carddav { return 301 /remote.php/dav/; }
             location = /.well-known/caldav  { return 301 /remote.php/dav/; }

             location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
             location /.well-known/pki-validation    { try_files $uri $uri/ =404; }

             # Let Nextcloud's API for `/.well-known` URIs handle all other
             # requests by passing them to the front-end controller.
             return 301 /index.php$request_uri;
         }

         # Rules borrowed from `.htaccess` to hide certain paths from clients
         location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
         location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }

         # Ensure this block, which passes PHP files to the PHP process, is above the blocks
         # which handle static assets (as seen below). If this block is not declared first,
         # then Nginx will encounter an infinite rewriting loop when it prepends `/index.php`
         # to the URI, resulting in a HTTP 500 error response.
         location ~ \.php(?:$|/) {
             # Required for legacy support
             rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|ocs-provider\/.+|.+\/richdocumentscode(_arm64)?\/proxy) /index.php$request_uri;

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
         location ~ \.(?:css|js|mjs|svg|gif|ico|jpg|png|webp|wasm|tflite|map|ogg|flac)$ {
             try_files $uri /index.php$request_uri;
             # HTTP response headers borrowed from Nextcloud `.htaccess`
             add_header Cache-Control                     "public, max-age=15778463$asset_immutable";
             add_header Referrer-Policy                   "no-referrer"       always;
             add_header X-Content-Type-Options            "nosniff"           always;
             add_header X-Frame-Options                   "SAMEORIGIN"        always;
             add_header X-Permitted-Cross-Domain-Policies "none"              always;
             add_header X-Robots-Tag                      "noindex, nofollow" always;
             add_header X-XSS-Protection                  "1; mode=block"     always;
             access_log off;     # Optional: Don't log access to assets
         }

         location ~ \.(otf|woff2?)$ {
             try_files $uri /index.php$request_uri;
             expires 7d;         # Cache-Control policy borrowed from `.htaccess`
             access_log off;     # Optional: Don't log access to assets
         }

         # Rule borrowed from `.htaccess`
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
     nginx -t
     ln -s /etc/nginx/sites-available/nextcloud.conf /etc/nginx/sites-enabled/
     nginx -s reload
     ```

6. [Crear certificado](../../web/general/certbot.md#generar-certificados).

7. Entrar a la url de nextcloud e instalar.

8. Instalar Redis para mejorar el rendimiento.

   ```sh
   apt install redis-server
   systemctl enable --now redis-server
   ```

   - Agregar en **_/var/www/nextcloud/config/config.php_**:

     ```php
     'memcache.local' => '\OC\Memcache\APCu',
     'filelocking.enabled' => true,
     'memcache.locking' => '\OC\Memcache\Redis',
     'redis' => array(
       'host' => '/run/redis/redis.sock',
       'port' => 0,
       'timeout' => 0.0,
     ),
     'loglevel' => 3,
     ```

   - Ejecutar:

     ```sh
     echo "unixsocket /run/redis/redis.sock" >> /etc/redis/redis.conf
     echo "unixsocketperm 777" >> /etc/redis/redis.conf

     echo "vm.overcommit_memory = 1" | tee /etc/sysctl.d/nextcloud-aio-memory-overcommit.conf
     ```

9. [Habilitar cron](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html#cron-jobs):

   ```sh
   crontab -u www-data -e
   ```

   ```text
   */5 * * * * php -f /var/www/nextcloud/cron.php --define apc.enable_cli=1
   ```

10. Agregar en **/var/www/nextcloud/config/config.php**:

    ```php
    'default_phone_region' => 'AR',
    'overwritehost' => 'cloud.ejemplo.com',
    'overwriteprotocol' => 'https',
    'overwritewebroot' => '/',
    'overwrite.cli.url' => 'https://cloud.ejemplo.com',
    'trusted_proxies' =>
      array (
        '192.168.100.10', # o la IP interna del proxy
      ),
    ```

11. Ir al panel de administración y corregir las advertencias.

    - Corregir el error del teléfono: agregar en **_/var/www/nextcloud/config/config.php_** "'default_phone_region' => 'AR',".

### [Instalar Nextcloud con docker](../../contenedores/nextcloud.md#instalación)

---

## Extras

### Activar directorios virtuales en el cliente

- En linux los directorios virtuales no vienen activables por defecto.
- Ir al archivo **_~/.config/Nextcloud/nextcloud.cfg_** y agregar `showExperimentalOptions=true`, luego reiniciar el cliente y activar la opción de discos virtuales en la configuración de la carpeta (en la interfaz).

### Activar LDAP

1. Asegurarse de tener instalado el paquete "php-ldap".

2. Activar en la web la app "LDAP user and group backend".

3. Entrar al panel de administración y configurar la app.

<!--

#### [Instalar con Apache](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)

1. Instalar requisitos:

    ```sh
    apt update && apt upgrade -y

    apt install apache2 libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip php-bz2 php-apcu php-redis php-ldap libmagickcore-6.q16-6-extra unzip wget sudo -y
    ```

2. [Instalar MariaDB y crear db](../../database/sql/mysql_mariadb.md#instalar-mariadb-en-debian-12):

     1. Configurar:

         - Tener ***/etc/mysql/my.conf*** como:

            ```conf
            [server]
            skip_name_resolve = 1
            innodb_buffer_pool_size = 1G
            innodb_buffer_pool_instances = 1
            innodb_flush_log_at_trx_commit = 2
            innodb_log_buffer_size = 32M
            innodb_max_dirty_pages_pct = 90
            query_cache_type = 1
            query_cache_limit = 2M
            query_cache_min_res_unit = 2k
            query_cache_size = 64M
            tmp_table_size= 64M
            max_heap_table_size= 64M
            slow_query_log = 1
            slow_query_log_file = /var/log/mysql/slow.log
            long_query_time = 1

            [client-server]
            !includedir /etc/mysql/conf.d/
            !includedir /etc/mysql/mariadb.conf.d/

            [client]
            default-character-set = utf8mb4

            [mysqld]
            character_set_server = utf8mb4
            collation_server = utf8mb4_general_ci
            transaction_isolation = READ-COMMITTED
            binlog_format = ROW
            innodb_large_prefix=on
            innodb_file_format=barracuda
            innodb_file_per_table=1
            read_rnd_buffer_size = 4M
            sort_buffer_size = 4M
            ```

         - Tener ***/etc/php/x.x/apache2/conf.d/20-pdo_mysql.ini*** como:

            ```ini
            extension=pdo_mysql.so

            [mysql]
            mysql.allow_local_infile=On
            mysql.allow_persistent=On
            mysql.cache_size=2000
            mysql.max_persistent=-1
            mysql.max_links=-1
            mysql.default_port=
            mysql.default_socket=/run/mysqld/mysqld.sock
            mysql.default_host=
            mysql.default_user=
            mysql.default_password=
            mysql.connect_timeout=60
            mysql.trace_mode=Off
            ```

     2. Crear:

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
            <IfModule mod_headers.c>
                Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
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

    3. Habilitar ssl:

        ```sh
        a2enmod ssl && \
        a2ensite default-ssl
        ```

    4. Editar en ***/etc/php/x.x/apache2/php.ini***:

        ```ini
        max_execution_time = 300
        memory_limit = 2G
        post_max_size = 128M
        upload_max_filesize = 128M
        ```

    5. Habilitar OPCache en ***/etc/php/x.x/apache2/php.ini***:

        ```ini
        [opcache]
        opcache.enable=1
        opcache.memory_consumption=512
        opcache.interned_strings_buffer=64
        opcache.max_accelerated_files=50000
        opcache.max_wasted_percentage=15
        opcache.validate_timestamps=0
        opcache.revalidate_freq=0
        opcache.save_comments=1
        ```

    6. Editar en ***/etc/php/x.x/apache2/pool.d/www.conf:

        ```conf
        pm = dynamic
        pm.max_children = 120
        pm.start_servers = 12
        pm.min_spare_servers = 6
        pm.max_spare_servers = 18
        ```

    7. Reiniciar servicio:

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

    > Una vez que se cambie la ip o el dominio de la web, debe modificarse la linea overwrite.

    ```sh
    sudo -u www-data php /var/www/nextcloud/occ maintenance:update:htaccess
    ```

7. [Instalar Redis](../../database/nosql/redis.md#instalar-redis-en-debian-12) para mejorar el rendimiento.

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
      'loglevel' => 3,
      ```

    - Ejecutar:

        ```sh
        echo "unixsocket /var/run/redis/redis.sock" >> /etc/redis/redis.conf
        echo "unixsocketperm 777" >> /etc/redis/redis.conf

        echo "vm.overcommit_memory = 1" | tee /etc/sysctl.d/nextcloud-aio-memory-overcommit.conf
        ```

8. [Habilitar cron](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html#cron-jobs):

    ```sh
    crontab -u www-data -e
    ```

    ```text
    */5 * * * * php -f /var/www/nextcloud/cron.php --define apc.enable_cli=1
    ```

9.  Ir al panel de administración y corregir las advertencias.

    - Corregir el error del teléfono: agregar en ***/var/www/nextcloud/config/config.php*** "'default_phone_region' => 'AR',".

-->
