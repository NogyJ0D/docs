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

   define('VERBOSE', true); // Para ver más en System -> Log of Events

   $pageroot = '';
   $default_system_language = 'es';
   define('PUBLIC_PROTOCOL', 'https');
   // La Base Url se define en la interfaz

   // Velocidad de envio (https://www.phplist.org/manual/books/phplist-manual/page/setting-the-send-speed-%28rate%29):
   //      Enviar no más de N correos cada T segundos.
   //      N = Cantidad de correos
   //define('MAILQUEUE_BATCH_SIZE', 360);
   //      T = Cada cuantos segundos
   //define('MAILQUEUE_BATCH_PERIOD', 3600);
   //      Pausa entre mensajes (segundos)
   //define('MAILQUEUE_THROTTLE', 1);
   //      Ejemplo: enviar 360 correos por hora, esperando 1 segundo entre cada uno

   // Para configurar el servidor SMTP:
   define('PHPMAILERHOST', 'mail.server.hostname');
   $phpmailer_smtpuser = 'user@login.com';
   $phpmailer_smtppassword = 'user_password';
   define("PHPMAILERPORT", '587');
   define("PHPMAILER_SECURE", 'tls');
   ```

   - Configurar cron:

     1. Editar **_/var/www/phplist/bin/phplist_** y dar permisos 755:

        ```sh
        #!/bin/bash

        /usr/bin/php /var/www/phplist/public_html/lists/admin/index.php -c /var/www/phplist/public_html/lists/config/config.php $*
        ```

     2. Agregar al crontab (como root):

        ```cron
        0-59/5 * * * * /var/www/phplist/bin/phplist -pprocessqueue > /dev/null 2>&1
        0 3 * * * /var/www/phplist/bin/phplist -pprocessbounces > /dev/null 2>&1
        ```

     3. Agregar al **_config.php_**:

        ```php
        // Para habilitar el cron de las campañas
        define('MANUALLY_PROCESS_BOUNCES', 0);
        define('MANUALLY_PROCESS_QUEUE', 0);
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
