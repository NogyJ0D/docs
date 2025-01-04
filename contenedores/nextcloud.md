# Nextcloud

- [Nextcloud](#nextcloud)
  - [Componentes](#componentes)
  - [Directorios](#directorios)
  - [Compose](#compose)
  - [Extras](#extras)
    - [Configuraciones a hacer](#configuraciones-a-hacer)
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

## Compose

```yaml
services:
  nextcloud:
    image: nextcloud:latest
    container_name: nextcloud
    restart: unless-stopped
    networks:
      - nextcloud
    ports:
      - 127.0.0.1:3000:80
    environment:
      TZ: America/Argentina/Buenos_Aires
      POSTGRES_HOST: nextcloud-db
      POSTGRES_DB: nextcloud
      POSTGRES_USER: nextcloud
      POSTGRES_PASSWORD: nextcloud
      REDIS_HOST: nextcloud-redis
      REDIS_HOST_PASSWORD: redis
    volumes:
      - ./html:/var/www/html
      - ./data:/var/www/html/data
      - ./config:/var/www/html/config
    depends_on:
      - nextcloud-db
      - nextcloud-redis

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
    image: collabora/code:latest
    container_name: nextcloud-collabora
    restart: unless-stopped
    networks:
      - nextcloud
    environment:
      - TZ=America/Argentina/Buenos_Aires
      - username=admin
      - password=admin
      - domain=archivos\.example\.com
      - dictionaries=en_US es_ES
      - DONT_GEN_SSL_CERT="True"
      - cert_domain=office.example.com
      - server_name=office.example.com
      - extra_params=--o:ssl.enable=false --o:ssl.termination=true
    ports:
      - 127.0.0.1:3001:9980

networks:
  nextcloud:
    name: nextcloud
    driver: bridge
```

## Extras

### Configuraciones a hacer

- Agregar a **_config/config.php_**:

  ```php
  'overwrite.cli.url' => 'https://archivos.example.com', # Modificar https
  'overwriteprotocol' => 'https',
  'maintenance_window_start' => 6,
  'maintenance' => false,
  'default_phone_region' => 'AR',
  ```

- Agregar al crontab del root en el host:

  ```sh
  */5 * * * * docker exec -u www-data nextcloud php -f /var/www/html/cron.php
  ```

  - Configurar también que use Cron en la interfaz.

- Collabora:
  - Instalar la app **"Nextcloud Office"**.
  - En la web ir a **"Administration Settings"** > **"Office"**.
  - Marcar "Use your own server" y poner la url (<https://office.example.com>).
  - En **"Configuraciones Avanzadas"** > **"Allow list of WOPI requests"** agregar la IP permitida.
    - Configurar una cualquiera e intentar abrir un archivo con collabora.
    - Si no funciona, revisar en los registros que IP intentó acceder y poner esa en la lista.
    - Probar primero la IP pública por la que sale a internet.

### Comandos

- Forzar el escaneo de archivos:

  ```sh
  docker exec -it -u www-data nextcloud php -f /var/www/html/occ files:scan -all
  ```
