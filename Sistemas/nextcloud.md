# Nextcloud

## [Instalar Nextcloud en Debian 12](https://docs.nextcloud.com/server/latest/admin_manual/installation/example_ubuntu.html)
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
CREATE USER 'username'@'localhost' IDENTIFIED BY 'password';
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES ON nextcloud.* TO 'username'@'localhost';
FLUSH PRIVILEGES;
QUIT;
```

3. Descargar Nextcloud:
```sh
wget https://download.nextcloud.com/server/releases/latest.zip && unzip latest.zip

cp -r nextcloud /var/www
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
    a2enmod rewrite
    a2enmod headers
    a2enmod env
    a2enmod dir
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