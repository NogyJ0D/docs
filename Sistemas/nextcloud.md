# Nextcloud

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

## Documentación

## Instalación

### [Instalar Nextcloud en Debian 12]()

#### [Instalar con Apache](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)
1. Instalar requisitos:
```sh
apt update && apt upgrade -y

apt install apache2 mariadb-server libapache2-mod-php php-gd php-mysql php-curl php-mbstring php-intl php-gmp php-bcmath php-xml php-imagick php-zip unzip wget sudo -y
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

7. [Habilitar SSL](https://docs.nextcloud.com/server/latest/admin_manual/installation/source_installation.html#enabling-ssl)

8. [Habilitar cron](https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/background_jobs_configuration.html#cron-jobs):
```sh
crontab -u www-data -e
```

```text
*/5 * * * * php -f /var/www/nextcloud/cron.php
```

#### [Instalar con Nginx](https://www.linuxtuto.com/how-to-install-nextcloud-on-debian-12/)

1. [Instalar Nginx](../web/servidores/nginx.md#instalar-nginx-en-debian).

2. Instalar php y extensiones:
   1. Instalar php
   ```sh
   apt install -y php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-intl php-curl php-xml php-mbstring php-bcmath php-gmp wget
   ```

   2. Editar en ***/etc/php/x.x/fpm/php.ini***:
   ```ini
   max_execution_time = 300
   memory_limit = 512M
   post_max_size = 128M
   upload_max_filesize = 128M
   ```

   3. Reiniciar servicio:
   ```sh
   systemctl restart php8.2-fpm
   ```

3. [Instalar MariaDB](../database/sql/mariadb.md#instalar-mariadb-en-debian-12).
   1. Crear DB:
   ```sql
   CREATE DATABASE nextcloud;
   GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'localhost' IDENTIFIED BY 'Password';
   FLUSH PRIVILEGES;
   EXIT;
   ```

4. Descargar Nextcloud:
```sh
wget  https://download.nextcloud.com/server/releases/latest.zip
unzip latest.zip -d /var/www/
chown -R www-data:www-data /var/www/nextcloud
```

5. Configurar nginx:

    Agregar en ***/etc/nginx/conf.d/nextcloud.conf***:
    ```nginx
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
    ```

```sh
systemctl restart nginx
```

6. Crear certificado:
```sh
apt install -y certbot python3-certbot-nginx

certbot --nginx -d your-domain.com -d www.your-domain.com
```

7. Entrar a la url de nextcloud e instalar.

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