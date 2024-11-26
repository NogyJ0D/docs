# phpList

- [phpList](#phplist)

---

## Instalación

### Instalar phpList en Debian 12

1. Descargar phpList:

   - [Buscar última versión](https://www.phplist.org/download-phplist/).

   ```sh
   wget https://sourceforge.net/projects/phplist/files/phplist/3.6.15/phplist-3.6.15.tgz/download -O phplist-3.6.15.tar.gz

   tar xvzf phplist-3.6.15.tar.gz
   ```

2. Instalar nginx:

   > La guía realmente usa apache.

   ```sh
   apt install nginx php-fpm php-mysql php-xml
   ```

3. Instalar mariadb:

   ```sh
   apt install mariadb-server mariadb-client
   mysql_secure_installation
   mysql
   ```

   1. Crear DB:

   ```sql
   CREATE DATABASE phplist;
   CREATE USER 'phplist'@'localhost' IDENTIFIED BY 'phplist';
   GRANT ALL PRIVILEGES ON phplist.* TO 'phplist'@'localhost';
   FLUSH PRIVILEGES;
   SHOW GRANTS FOR 'phplist'@'localhost';
   EXIT;
   ```

4. Configurar phpList:

   ```sh
   cd phplist-3.6.15
   vim public_html/lists/config/config.php
   ```

   ```php
   $database_host = 'localhost';
   $database_name = 'phplist';
   $database_user = 'phplist';
   $database_password = 'phplist';

   $pageroot = '';
   $default_system_language = 'es';

   # Para configurar el servidor SMTP:
   define('PHPMAILERHOST', 'mail.server.hostname');
   $phpmailer_smtpuser = 'user@login.com';
   $phpmailer_smtppassword = 'user_password';
   define("PHPMAILERPORT", '587');
   define("PHPMAILER_SECURE", 'tls');
   ```

5. Configurar nginx:

   ```sh
   mv phplist-3.6.15 /var/www/phplist
   chown -R www-data:www-data /var/www/phplist
   chmod -R 755 /var/www/phplist-3.6.15
   rm /etc/nginx/sites-enabled/default
   vim /etc/nginx/sites-available/phplist
   ```

   ```nginx
   server {
     listen 80;
     server_name _;

     root /var/www/phplist/public_html/lists;
     index index.php index.html index.html;

     location / {
       try_files $uri $uri/ =404;
     }

     location ~ \.php$ {
       include snippets/fastcgi-php.conf;
       fastcgi_pass unix:/run/php/phpX.Y-fpm.sock; # Reemplaza X.Y con la versión de PHP instalada
       fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
       include fastcgi_params;
     }

     location ~ /\.ht {
       deny all;
     }

     access_log /var/log/nginx/phplist-access.log;
     error_log /var/log/nginx/phplist-error.log;
   }
   ```

   ```sh
   ln -s /etc/nginx/sites-available/phplist /etc/nginx/sites-enabled

   systemctl restart nginx
   systemctl restart php8.2-fpm
   ```

6. Entrar a phpList:

   1. Ir a <http://ip/admin>.
   2. Inicializar base de datos.
   3. Hacer configuraciones básicas que recomiende.
   4. Actualizar traducción (System > Updatetranslation).
   5. Listar administradores (Config > Enumerar administradores).
