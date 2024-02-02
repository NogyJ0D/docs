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
    git clone https://github.com/phpipam/phpipam.git /var/www/html/phpipam/ && \
      cd /var/www/html/phpipam && \
      git checkout 1.6 && \
      git submodule update --init --recursive
    ```

4. Configuración de la base de datos:

    ```sh
    cp config.dist.php config.php && \
      nano config.php
    # Modificar tambien "define('BASE', '/phpipam');"
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
    chown -R www-data:www-data /var/www/html/phpipam && \
      chmod -R 755 /var/www/html/phpipam
    nano /etc/apache2/sites-available/phpipam.conf
    ```

    ```apache
    <VirtualHost *:80>
      DocumentRoot "/var/www/html/phpipam"
      ServerName example.com
      <Directory "/var/www/html/phpipam">
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
      </Directory>
      ErrorLog "/var/log/phpipam-error_log"
      CustomLog "/var/log/phpipam-access_log" combined
    </VirtualHost>
    ```

    ```sh
    a2ensite phpipam && \
      a2enmod rewrite && \
      systemctl restart apache2
    ```

6. Entrar a "<http://x.x.x.x/phpipam/index.php?page=install>" e instalar. Al poner los datos de la base de datos, desmarcar las tres opciones.

---

## Extras

### Habilitar duplicacion de redes

Ir a Administration > Sections > Editar red > Strict Mode No.