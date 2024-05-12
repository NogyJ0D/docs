# OCS Inventory

---

## Contenido

- [OCS Inventory](#ocs-inventory)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar OCS Server en Debian 12](#instalar-ocs-server-en-debian-12)
  - [Extra](#extra)
    - [Instaladores](#instaladores)
      - [Server](#server)
      - [Agente](#agente)
      - [Plugins](#plugins)

---

## Documentación

---

## Instalación

### [Instalar OCS Server en Debian 12](https://www.youtube.com/watch?v=ijOTemn1QjE)

1. Instalar el stack LAMP

    ```sh
    apt install apache2 libapache2-mod-perl2 libapache2-mod-perl2-dev libapache-dbi-perl libapache-db-perl libapache2-mod-php libarchive-zip-perl mariadb-server mariadb-client composer php-mbstring php-xml php-mysql php-zip php-pclzip php-gd php-soap php-curl php-json -y
    ```

2. Instalar paquetes de PERL

    ```sh
    apt install git curl wget make cmake gcc make -y
    
    apt install perl libxml-simple-perl libcompress-zlib-perl libdbi-perl libdbd-mysql-perl libnet-ip-perl libsoap-lite-perl libio-compress-perl -y
    ```

3. Habilitar servicios

    ```sh
    systemctl enable --now apache2
    systemctl enable --now mariadb
    ```

4. Instalar módulos de PERL

    ```sh
    perl -MCPAN -e 'install Apache2::SOAP' && \
    perl -MCPAN -e 'install XML::Entities' && \
    perl -MCPAN -e 'install Net::IP' && \
    perl -MCPAN -e 'install Apache::DBI' && \
    perl -MCPAN -e 'install Mojolicious' && \
    perl -MCPAN -e 'install Switch' && \
    perl -MCPAN -e 'install Plack::Handler'
    ```

5. Crear base de datos

    ```sh
    mysql -u root -p
    ```

    ```sql
    CREATE DATABASE ocsweb;
    CREATE USER ocsuser@localhost IDENTIFIED BY 'ocsPWD';
    GRANT ALL ON ocsdb.* TO ocsuser@localhost;
    FLUSH PRIVILEGES;
    exit
    ```

6. Cambiar zona horaria:

   - Editar en **/etc/php/8.1/apache2/php.ini**:

      ```text
      memory_limit = 512M
      post_max_size = 100M
      upload_max_filesize = 100M
      max_execution_time = 360
      date.timezone = America/Argentina/Buenos_Aires
      ```

    ```sh
    systemctl restart apache2
    ```

7. Instalar OCS Inventory

    ```sh
    wget https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.12.0/OCSNG_UNIX_SERVER-2.12.0.tar.gz &&
    tar -xvf OCSNG_UNIX_SERVER-2.12.0.tar.gz &&
    cd OCSNG_UNIX_SERVER-2.12.0 &&
    ```

   - Editar en ***setup.sh***:

      ```text
      DB_SERVER_USER="ocsuser"
      DB_SERVER_PWD="ocsPWD"
      ```

   ```sh
   ./setup.sh
   ```

8. Crear links:

    ```sh
    ln -s /etc/apache2/conf-available/ocsinventory-reports.conf /etc/apache2/conf-enabled/ocsinventory-reports.conf &&
    ln -s /etc/apache2/conf-available/z-ocsinventory-server.conf /etc/apache2/conf-enabled/z-ocsinventory-server.conf &&
    ln -s /etc/apache2/conf-available/zz-ocsinventory-restapi.conf /etc/apache2/conf-enabled/zz-ocsinventory-restapi.conf
    ```

9. Finalizar:

    ```sh
    cd /etc/apache2/conf-enabled/
    nano z-ocsinventory-server.conf # Cambiar el usuario y contraseña de la db
    nano zz-ocsinventory-restapi.conf
    chown -R www-data:www-data /var/lib/ocsinventory-reports/
    systemctl restart apache2
    ```

10. Configurar OCS con la interfaz "<http://x.x.x.x/ocsreports/index.php>".

11. Backup:

    ```sh
    cd /usr/share/ocsinventory-reports/ocsreports/
    mv install.php install.php.bak # Esto una vez completada la instalación web
    ```

> El script para crear la DB está en: "carpeta de instalacion/ocsreports/files/ocsbase.sql". Hay otro archivo que se llama "ocsbase_new.sql", no se cuál es el correcto.

---

## Extra

### Instaladores

#### Server

- [Linux/Unix Server 2.12.0](https://github.com/OCSInventory-NG/OCSInventory-ocsreports/releases/download/2.12.0/OCSNG_UNIX_SERVER-2.12.0.tar.gz)

#### Agente

- [Windows Agent 2.10.1.0 (64 bits)](https://github.com/OCSInventory-NG/WindowsAgent/releases/download/2.10.1.0/OCS-Windows-Agent-2.10.1.0_x64.zip)
- [Windows Agent 2.10.1.0 (32 bits)](https://github.com/OCSInventory-NG/WindowsAgent/releases/download/2.10.1.0/OCS-Windows-Agent-2.10.1.0_x86.zip)
- [Windows Agent 2.1.1.1 (XP & 2003R2 only)](https://github.com/OCSInventory-NG/WindowsAgent/releases/download/2.1.1.1/OCSNG-Windows-Agent-2.1.1.zip)
- [Unix/Linux Agent 2.10.0](https://github.com/OCSInventory-NG/UnixAgent/releases/download/v2.10.0/Ocsinventory-Unix-Agent-2.10.0.tar.gz)

#### [Plugins](https://github.com/orgs/PluginsOCSInventory-NG/repositories)