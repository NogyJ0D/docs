# Nextcloud

- [Nextcloud](#nextcloud)
  - [Componentes](#componentes)
  - [Directorios](#directorios)
  - [Nginx](#nginx)
  - [Compose](#compose)
  - [Instalación](#instalación)
  - [Extras](#extras)
    - [Comandos](#comandos)

---

## Componentes

- Nextcloud
- Postgres
- Redis
- Collabora
  - Se puede acceder a la interfaz de admin con la url: <https://office.example.com/browser/dist/admin/admin.html>

## Directorios

- nextcloud/ (root:root)
  - config/ (www-data:www-data)
  - data/ (www-data:www-data)
  - db_data/ (999:root)
  - html/ (www-data:www-data)
  - redis/ (999:root)
  - docker-compose.yml (root:root)

## Nginx

> ⚠️ Guardar ambos en sites-available y mover luego.

- **_nextcloud.conf_**:

  ```nginx
  server {
    listen 80;
    listen [::]:80;
    server_name nube.dominio.com;

    return 301 https://$host$request_uri;
  }

  upstream nextcloud {
    server x.x.x.x:80;
    keepalive 32;
  }

  server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name nube.dominio.com;

    proxy_send_timeout 330s;
    proxy_read_timeout 330s;
    proxy_connect_timeout 60s;
    proxy_buffering off;
    proxy_request_buffering off;

    ssl_certificate /etc/letsencrypt/live/nube.dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/nube.dominio.com/privkey.pem;
    ssl_session_cache shared:WEBSSL:10m;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_session_timeout 10m;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers off;

    # Cabeceras de seguridad
    more_set_headers 'Referrer-Policy: no-referrer' always;
    more_set_headers 'X-Content-Type-Options: nosniff' always;
    more_set_headers 'X-Frame-Options: SAMEORIGIN' always;
    more_set_headers 'X-Permitted-Cross-Domain-Policies: none' always;
    more_set_headers 'X-Robots-Tag: noindex, nofollow' always;
    more_set_headers 'X-XSS-Protection: 1; mode=block' always;

    # Tamaño maximo de carga
    client_max_body_size 16G;
    client_body_timeout 300s;
    client_body_buffer_size 512k;
    proxy_buffers 64 4k;
    proxy_buffer_size 4k;
    proxy_busy_buffers_size 8k;

    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header Referrer-Policy "no-referrer" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Permitted-Cross-Domain-Policies "none" always;
    add_header X-Robots-Tag "noindex, nofollow" always;
    add_header X-XSS-Protection "1; mode=block" always;

    error_log /var/log/nginx/nube.dominio.com_error.log;
    access_log /var/log/nginx/nube.dominio.com.log;

    # Bloquear acceso a archivos sensibles
    location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/) {
      return 404;
    }
    location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
      return 404;
    }

    # Optimización para archivos estáticos
    location ~* \.(?:css|js|mjs|svg|gif|ico|jpg|jpeg|png|webp|wasm|woff2?|ttf|otf|map)$ {
      proxy_pass http://nextcloud;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port $server_port;

      expires 6M;
      access_log off;
      add_header Cache-Control "public, immutable";
    }

    # Configuración específica para .well-known (CalDAV/CardDAV)
    location ^~ /.well-known {
      location = /.well-known/carddav {
        return 301 $scheme://$host/remote.php/dav;
      }
      location = /.well-known/caldav {
        return 301 $scheme://$host/remote.php/dav;
      }
      location ^~ /.well-known/ {
        proxy_pass http://nextcloud;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;
      }
    }

    # APIs y endpoints específicos de Nextcloud
    location ~ ^/(remote|public|dav|ocs|ocs-provider|status|index\.php|avatar|thumbnails)(?:$|/) {
      proxy_pass http://nextcloud;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port $server_port;
      proxy_set_header X-Forwarded-Ssl on;

      proxy_max_temp_file_size 2048m;
    }

    # Ubicación principal
    location / {
      proxy_pass http://nextcloud;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header X-Forwarded-Host $host;
      proxy_set_header X-Forwarded-Port $server_port;
      proxy_set_header X-Forwarded-Ssl on;

      proxy_max_temp_file_size 2048m;
    }

    # Bloquear archivos php
    location ~ \.php$ {
      return 404;
    }
  }
  ```

- **_collabora.conf_**:

```nginx
upstream office {
  server x.x.x.x:9980;
}

map $http_upgrade $connection_upgrade_keepalive {
  default upgrade;
  ''      '';
}

server {
  listen 80;
  listen [::]:80;
  server_name office.dominio.com;

  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  listen [::]:443 ssl;
  server_name office.dominio.com;

  ssl_certificate /etc/letsencrypt/live/office.dominio.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/office.dominio.com/privkey.pem;

  #client_max_body_size 0;
  add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";

  error_log /var/log/nginx/office.dominio.com_error.log;
  access_log /var/log/nginx/office.dominio.com.log;

  location ^~ /browser {
    proxy_pass http://office;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
  }
  location ^~ /hosting/discovery {
    proxy_pass http://office;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
  }
  location ^~ /hosting/capabilities {
    proxy_pass http://office;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
  }

  location ~ ^/cool/(.*)/ws$ {
    proxy_pass http://office;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
    proxy_read_timeout 36000s;
  }

  location ~ ^/(c|l)ool {
    proxy_pass http://office;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
  }

  location ^~ /cool/adminws {
    proxy_pass http://office;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "Upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_buffering off;
    proxy_read_timeout 36000s;
  }
}
```

## Compose

```yaml
services:
  nextcloud:
    profiles:
      - donotstart
    image: nextcloud:latest
    container_name: nextcloud
    restart: unless-stopped
    networks:
      - nextcloud
    ports:
      - 3000:80
    environment:
      TZ: America/Argentina/Buenos_Aires
      POSTGRES_HOST: nextcloud-db
      POSTGRES_DB: nextcloud
      POSTGRES_USER: nextcloud
      POSTGRES_PASSWORD: nextcloud
      REDIS_HOST: nextcloud-redis
      REDIS_HOST_PASSWORD: redis
      TRUSTED_PROXIES: <IP privada del proxy reverso>
      TRUSTED_DOMAINS: nextcloud.dominio.com
      OVERWRITEPROTOCOL: https
      OVERWRITECLIURL: https://nextcloud.dominio.com
      OVERWRITEHOST: nextcloud.dominio.com
    volumes:
      - ./html:/var/www/html
      - ./data:/var/www/html/data
      - ./config:/var/www/html/config
    depends_on:
      - nextcloud-db
      - nextcloud-redis
    extra_hosts:
      - 'nextcloud.dominio.com:<IP privada del proxy reverso>'
      - 'office.dominio.com:<IP privada del proxy reverso>'

  nextcloud-db:
    image: postgres:15
    container_name: nextcloud-db
    restart: unless-stopped
    networks:
      - nextcloud
    environment:
      POSTGRES_DB: nextcloud
      POSTGRES_USER: nextcloud
      POSTGRES_PASSWORD: nextcloud
    volumes:
      - ./db_data:/var/lib/postgresql/data

  nextcloud-redis:
    image: redis:alpine
    container_name: nextcloud-redis
    command: ['redis-server', '--requirepass', 'redis']
    restart: unless-stopped
    networks:
      - nextcloud
    environment:
      REDIS_PASSWORD: redis
    volumes:
      - ./redis:/data

  nextcloud-collabora:
    profiles:
      - donotstart
    image: collabora/code:latest
    container_name: nextcloud-collabora
    restart: unless-stopped
    networks:
      - nextcloud
    environment:
      - TZ=America/Argentina/Buenos_Aires
      - username=admin
      - password=admin
      - domain=nextcloud\.dominio\.com
      - aliasgroup1=https://nextcloud.dominio.com:443,https://nextcloud\\.dominio\\.com
      - dictionaries=en_US es_ES
      - DONT_GEN_SSL_CERT="True"
      - cert_domain=office.dominio.com
      - server_name=office.dominio.com
      - extra_params=
        --o:ssl.enable=false
        --o:ssl.termination=true
        --o:user_interface.mode=compact
        --o:net.frame_ancestors=nextcloud.dominio.com:443
        --o:storage.wopi.host[0]=nextcloud.dominio.com
    ports:
      - 9980:9980
    extra_hosts:
      - 'office.dominio.com:<IP privada del proxy reverso>'
      - 'nextcloud.dominio.com:<IP privada del proxy reverso>'

networks:
  nextcloud:
    name: nextcloud
    driver: bridge
```

## Instalación

> No habilitar aún los sitios en nginx, mantenerlo local.

1. [Instalar docker engine](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
2. Crear la carpeta y cargar el **_[docker-compose.yml](#compose)_**
3. Agregar las url con la ip del proxy a **_/etc/hosts_**.
4. Iniciar con `docker compose up` y cuando esté lista la DB (aceptando conexiones), cortar con Control+D.
5. Comentar "profiles" en el contenedor de nextcloud y volver a iniciar con `docker compose up -d && docker compose logs -f`.

   1. Cuando esté listo (o si empieza a fallar la instalación), conectarse con `docker exec -it -u www-data nextcloud /bin/bash`.
   2. Dentro del contenedor iniciar instalación con:

      ```sh
      php /var/www/html/occ maintenance:install \
        --database "pgsql" --database-host "nextcloud-db" \
        --database-name "nextcloud" --database-user "nextcloud" --database-pass "nextcloud" \
        --admin-user "admin" --admin-pass "admin"
      ```

   3. Salir cuando esté listo.

6. Configuración de nextcloud:

   1. Agregar a **_./config/config.php_**:

      ```sh
      'maintenance_window_start' => 5,
      'maintenance' => false,
      'default_phone_region' => 'AR',
      'trusted_domains' =>
      array (
        0 => 'nextcloud.dominio.com'
      )
      ```

      - _maintenance_window_start_ es la hora en la que comienza el mantenimiento diario, está en UTC (3 horas menos que AR). Trabaja entre la hora puesta y las 4 siguientes, 5-9 UTC = 2-6 AR.
      - _maintenance_ dice si el servicio está en modo mantenimiento ahora mismo.

   2. Cambiar contraseña del admin porque no la toma: `docker exec -it -u www-data nextcloud php occ user:resetpassword admin`

   3. Agregar cron al root (`crontab -u root -e`):

      ```cron
      */5 * * * * docker exec -u www-data nextcloud php -f /var/www/html/cron.php
      ```

7. Comentar "profiles" en el contenedor de collabora y volver a iniciar con `docker compose up -d && docker compose logs -f`. Cuando esté listo, habilitar los sitios en nginx y entrar a la página de Nextcloud.
8. Comprobar que funcione con el usuario admin y entrar a la pestaña de administración para ver los ítems que faltan configurar.
   - Asegurarse que esté habilitado el cron en la interfaz.
9. Ejecutar estos comandos de mantenimiento general para quitar advertencias:

   ```sh
   docker exec -u www-data nextcloud php occ maintenance:repair --include-expensive
   docker exec -u www-data nextcloud php occ db:add-missing-indices
   docker exec -u www-data nextcloud php occ files:scan --all
   docker exec -u www-data nextcloud php occ maintenance:mode --on
   docker exec -u www-data nextcloud php occ maintenance:mode --off
   ```

## Extras

- Collabora:

  - Instalar la app **"Nextcloud Office"**.
  - En la web ir a **"Administration Settings"** > **"Office"**.
  - Marcar "Use your own server" y poner la url (<https://office.dominio.com>).
  - En **"Configuraciones Avanzadas"** > **"Allow list of WOPI requests"** agregar la IP permitida.
    - Probar primero la IP privada del host.
    - Si no funciona, revisar en los registros que IP intentó acceder y poner esa en la lista.
    - Si no funciona, configurar una cualquiera e intentar abrir un archivo con collabora.

- Actualizar contenedor:

  ```sh
  docker container stop nextcloud
  docker container rm nextcloud
  docker compose up -d && docker compose logs -f
  ```

### Comandos

- Forzar el escaneo de archivos:

  ```sh
  docker exec -it -u www-data nextcloud php -f /var/www/html/occ files:scan -all
  ```
