# GLPI

- [GLPI](#glpi)

---

## Instalación

### Instalar GLPI en Debian 12

1. Instalar nginx:

   ```sh
   apt install nginx nginx-extra php8.2-fpm
   ```

   - Configurar **_/etc/nginx/sites-enabled/glpi.conf_**:

     ```conf
     server {
       listen 80;
       listen [::]:80;

       server_name glpi.localhost;

       root /var/www/glpi/public;

       location / {
           try_files $uri /index.php$is_args$args;
       }

       location ~ ^/index\.php$ {
         # the following line needs to be adapted, as it changes depending on OS distributions and PHP versions
         fastcgi_pass unix:/run/php/php-fpm.sock;

         fastcgi_split_path_info ^(.+\.php)(/.*)$;
         include fastcgi_params;

         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
       }
     }
     ```

2. Instalar módulos de php:

   ```sh
   apt install php-dom php-fileinfo php-xml php-json php-simplexml php-xmlreader php-xmlwriter php-curl php-gd php-intl php-mysqli php-bz2 php-phar php-zip php-exif php-ldap php-opcache
   ```

   - Configurar session en **_/etc/php/8.2/fpm/php.ini_**:

     ```ini
     ; Si solo se accede por HTTPS
     session.cookie_secure = on

     session.cookie_httponly = on
     session.cookie_samesite = Lax
     ```

3. Instalar base de datos:

   ```sh
   apt install mariadb-server
   mariadb-secure-installation

   mariadb-tzinfo-to-sql /usr/share/zoneinfo | mariadb -p -u root mysql
   systemctl restart mariadb

   mariadb # Crear DB
   ```

   ```sql
   CREATE DATABASE glpi;
   CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpi';
   GRANT ALL ON glpi.* TO 'glpi'@'localhost';
   GRANT SELECT ON mysql.time_zone_name TO 'glpi'@'localhost';
   FLUSH PRIVILEGES;
   EXIT;
   ```

4. Instalar GLPI:

   - Obtener última release stable de <https://github.com/glpi-project/glpi/releases>

   ```sh
   cd /var/www
   wget https://github.com/glpi-project/glpi/releases/download/10.0.18/glpi-10.0.18.tgz
   tar xvzf glpi-10.0.18.tgz
   chown -R www-data:www-data /var/www/glpi
   ```

   - Acceder a http-s://x/install/install.php e instalar con wizard
   - Datos por defecto:
     - glpi/glpi administrador > cambiar contraseña
     - tech/tech técnico > borrar
     - normal/normal normal > borrar
     - post-only/postonly sólo-reportar > borrar
   - Borrar archivo **_/var/www/glpi/install/install.php_**
