# php

---

## Contenido

- [php](#php)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar phpipam en Debian 12](#instalar-phpipam-en-debian-12)
  - [Extras](#extras)
    - [Habilitar duplicacion de redes](#habilitar-duplicacion-de-redes)
    - [Habilitar checkeo automático de redes](#habilitar-checkeo-automático-de-redes)

---

## Documentación

- [Instalación oficial](https://phpipam.net/documents/installation/)
- [Instalación alternativa](https://www.howtoforge.com/how-to-install-phpipam-on-ubuntu-1804/)

---

## Instalación

### Instalar phpipam en Debian 12

1. Instalar [mariadb](../../database/sql/mysql_mariadb.md#instalar-mariadb-en-debian-12) o usar remoto.

2. Instalar básicos:

    ```sh
    apt install apache2 libapache2-mod-php php-common php-mysql openssl php-gmp php-ldap php-xml php-json php-cli php-mbstring php-pear php-gd php-curl git
    ```

3. Descargar phpipam:

    ```sh
    rm /var/www/html/index.html && \
      git clone https://github.com/phpipam/phpipam.git /var/www/html && \
      cd /var/www/html && \
      git checkout 1.6 && \
      git submodule update --init --recursive
    ```

4. Configuración de la base de datos:

    ```sh
    cp config.dist.php config.php && \
      nano config.php
    # NO HACER # Modificar tambien "define('BASE', '/phpipam/');"
    ```

    - Conectarse al motor y crear:

        ```sql
        CREATE USER 'phpipam'@'host' IDENTIFIED BY 'pass';
        CREATE DATABASE phpipam;
        GRANT ALL ON phpipam.* TO 'phpipam'@'host';
        FLUSH PRIVILEGES;
        EXIT;
        ```

5. Configurar apache:

    ```sh
    chown -R www-data:www-data /var/www/html && \
      chmod -R 755 /var/www/html
    nano /etc/apache2/sites-available/000-default.conf
    ```

    ```apache
    <VirtualHost *:80>
      ServerAdmin webmaster@localhost
      DocumentRoot /var/www/html

      <Directory /var/www/html>
        Options FollowSymLinks
        AllowOverride all
        Order allow,deny
        Allow from all
      </Directory>
    </VirtualHost>
    ```

    ```sh
    a2enmod rewrite && \
      systemctl restart apache2
    ```

6. Entrar a "<http://x.x.x.x/index.php?page=install>" e instalar. Al poner los datos de la base de datos, desmarcar las tres opciones.

---

## Extras

### Habilitar duplicacion de redes

Ir a Administration > Sections > Editar red > Strict Mode No.

### Habilitar checkeo automático de redes

1. Activar el escaneo en la subnet.

2. Agregar el cron:

    ```sh
    crontab -u www-data -e
    ```

    ```text
    */15 * * * * /usr/bin/php /var/www/html/functions/scripts/pingCheck.php
    */15 * * * * /usr/bin/php /var/www/html/functions/scripts/discoveryCheck.php
    ```
