# Racktables

---

## Contenido

- [Racktables](#racktables)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Racktables en Debian 12](#instalar-racktables-en-debian-12)
  - [Extras](#extras)
    - [Agregar plugins](#agregar-plugins)
    - [Cambiar datos de la base de datos](#cambiar-datos-de-la-base-de-datos)

---

## Documentación

- [Página oficial](https://www.racktables.org)

---

## Instalación

### [Instalar Racktables en Debian 12](https://unixcop.com/how-to-install-racktable-on-ubuntu-debian-servers/)
<!-- 1. Instalar requisitos
```sh
apt install apt-transport-https lsb-release ca-certificates -y
``` -->

1. Instalar php:

    ```sh
    apt install php php-cli php-snmp php-gd php-mysql php-mbstring php-bcmath php-json php-fpm php-ldap php-curl git -y
    ```

2. [Instalar MariaDB](../../database/sql/mariadb.md#instalar-mariadb-en-debian-12).

   1. Crear DB:

      ```sql
      CREATE DATABASE racktables_db CHARACTER SET utf8 COLLATE utf8_general_ci;
      CREATE USER 'racktables_user'@'localhost' IDENTIFIED by 'racktablepassword';
      GRANT ALL PRIVILEGES ON racktables_db.* TO 'racktables_user'@'localhost' WITH GRANT OPTION;
      FLUSH PRIVILEGES;
      QUIT;
      ```

3. Instalar Racktables:

    ```sh
    cd /var/www/html
    rm index.html
    git clone https://github.com/RackTables/racktables.git .
    rm ChangeLog COPYING LICENSE README.Fedora README.md

    chown -R www-data:www-data /var/www/html

    touch wwwroot/inc/secret.php
    #chmod a=rw /var/www/html/racktables/wwwroot/inc/secret.php
    chown www-data:nogroup wwwroot/inc/secret.php
    chmod 440 wwwroot/inc/secret.php
    ```

- Ir a <http://ip/wwwroot/?module=installer> y seguir los pasos.

- Opcional:
  
  - [Crear certificado](../../web/certbot.md#generar-certificados).

---

## Extras

### Agregar plugins

1. Ir a ***/var/www/racktables/plugins***.

2. Crear la carpeta con el nombre del plugin.

3. Descargar adentro el plugin bajo el nombre de ***plugin.php***.

### Cambiar datos de la base de datos

- Modificar en ***/var/www/html/wwwroot/inc/secret.php***:

    ```php
    $pdo_dsn = 'mysql:host=IP;dbname=racktables_db';
    $db_username = 'racktables_user';
    $db_password = 'Contraseña';
    ```
