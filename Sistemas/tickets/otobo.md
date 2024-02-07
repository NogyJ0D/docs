# Otobo

---

## Contenido

- [Otobo](#otobo)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Otobo en Debian 12](#instalar-otobo-en-debian-12)
  - [Extras](#extras)
    - [Cambiar contraseña desde la consola](#cambiar-contraseña-desde-la-consola)
    - [Agregar usuario desde la consola](#agregar-usuario-desde-la-consola)
    - [Migrar/Actualizar Otobo](#migraractualizar-otobo)

---

## Documentación

---

## Instalación

### [Instalar Otobo en Debian 12](https://doc.otobo.org/manual/installation/10.1/en/content/installation.html)

1. Deshabilitar SELinux.

2. Descargar Otobo:

   - [Buscar la última versión](https://ftp.otobo.org/pub/otobo/).

    ```sh
    mkdir /opt/otobo-install /opt/otobo
    cd /opt/otobo-install
    wget https://ftp.otobo.org/pub/otobo/otobo-latest-...
    tar -xvzf otobo-latest-...
    # REVISAR cp -r otobo-.../* /opt/otobo
    ```

3. Instalar adicionales:

    ```sh
    apt install -y libarchive-zip-perl libtimedate-perl libdatetime-perl libconvert-binhex-perl libcgi-psgi-perl libdbi-perl libdbix-connector-perl libfile-chmod-perl liblist-allutils-perl libmoo-perl libnamespace-autoclean-perl libnet-dns-perl libnet-smtp-ssl-perl libpath-class-perl libsub-exporter-perl libtemplate-perl libtext-trim-perl libtry-tiny-perl libxml-libxml-perl libyaml-libyaml-perl libdbd-mysql-perl libapache2-mod-perl2 libmail-imapclient-perl libauthen-sasl-perl libauthen-ntlm-perl libjson-xs-perl libtext-csv-xs-perl libpath-class-perl libplack-perl libplack-middleware-header-perl libplack-middleware-reverseproxy-perl libencode-hanextra-perl libio-socket-ssl-perl libnet-ldap-perl libcrypt-eksblowfish-perl libxml-libxslt-perl libxml-parser-perl libconst-fast-perl
    perl /opt/otobo/bin/otobo.CheckModules.pl -list
    ```

4. Crear el usuario de Otobo:

    ```sh
    useradd -r -U -d /opt/otobo -c 'OTOBO user' otobo -s /bin/bash
    usermod -G www-data otobo
    ```

5. Activar la configuración por defecto:

    ```sh
    cp /opt/otobo/Kernel/Config.pm.dist /opt/otobo/Kernel/Config.pm
    ```

6. Configurar Apache:

    ```sh
    apt install apache2 libapache2-mod-perl2 -y

    a2dismod mpm_event && \
    a2dismod mpm_worker && \
    a2enmod mpm_prefork

    a2enmod perl && \
    a2enmod deflate && \
    a2enmod filter && \
    a2enmod headers
    ```

   - Configurar sin SSL:

      ```sh
      cp /opt/otobo/scripts/apache2-httpd.include.conf /etc/apache2/sites-available/zzz_otobo.conf

      a2ensite zzz_otobo.conf
      ```

   - Configurar con SSL:

      ```sh
      cp /opt/otobo/scripts/apache2-httpd-vhost-80.include.conf /etc/apache2/sites-available/zzz_otobo-80.conf
      cp /opt/otobo/scripts/apache2-httpd-vhost-443.include.conf /etc/apache2/sites-available/zzz_otobo-443.conf

      a2ensite zzz_otobo-80.conf
      a2ensite zzz_otobo-443.conf
      ```

    ```sh
    systemctl restart apache2
    ```

7. Otorgar permisos:

    ```sh
    /opt/otobo/bin/otobo.SetPermissions.pl
    ```

8. [Instalar MariaDB](../../database/sql/mariadb.md#instalar-mariadb-en-debian-12).

   - A otobo no le gusta usar una base de datos existente con el instalador web, la opcion es crear una db con sql, usarla en la instalación y hacer un restore del dump en esta.

   1. Crear usuario y db:

        ```sql
        CREATE USER 'otobo'@'host' IDENTIFIED BY 'pass';
        CREATE DATABASE otobo;
        GRANT ALL ON otobo.* TO 'otobo'@'host';
        FLUSH PRIVILEGES;
        EXIT;
        ```


   2. Agregar en ***/etc/mysql/my.cnf***:

        ```conf
        [mysqld]
        max_allowed_packet = 64M
        innodb_log_file_size = 256M
        ```

9. [Instalar ElasticSearch](../../database/nosql/elasticsearch.md#instalar-elasticsearch-8-en-debian-12).

   1. Instalar módulos extras:

      ```sh
      /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment && \
        /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch analysis-icu
      ```

   2. Descomentar en ***/etc/elasticsearch/jvm.options***:

      ```text
      -Xms4g
      -Xmx4g
      ```

   3. reiniciar servicio:

      ```sh
      systemctl restart elasticsearch
      ```

10. Ingresar a <http://ip/otobo/installer.pl> y seguir los pasos.

11. Finales:

    1. Iniciar el daemon como otobo:

        ```sh
        su otobo
        
        /opt/otobo/bin/otobo.Daemon.pl start

        cd /opt/otobo/var/cron/
        for foo in *.dist; do cp $foo `basename $foo .dist`; done

        cd /opt/otobo/
        bin/Cron.sh start
        ```

---

## Extras

### Cambiar contraseña desde la consola

```sh
su -c "/opt/otobo/bin/otobo.Console.pl Admin::User::SetPassword <usuario> <contraseña>" -s /bin/bash otobo
```

### Agregar usuario desde la consola

```sh
su -c "/opt/otobo/bin/otobo.Console.pl Admin::User::Add --user-name <> --first-name <> --last-name <> --email-address <> --password <>" -s /bin/bash otobo
```

### Migrar/Actualizar Otobo

1. Parar servicios:

    ```sh
    systemctl stop postfix apache2 cron
    su otobo
    cd /opt/otobo
    bin/Cron.sh stop
    bin/otobo.Daemon.pl stop
    ```

2. Respaldar:

    ```sh
    # como root
    mkdir /root/otobo-update
    cd /root/otobo-update
    cp -pr /opt/otobo otobo-prod-old
    mysqldump -u otobo -p otobo -r otobodump.sql

    # Apache y certs
    ```

    - /etc/apache2/sites-enabled/zzz_otobo-443.conf
    - /etc/apache2/sites-enabled/zzz_otobo-80.conf
    - /opt/otobo/Kernel/Config.pm
    - /opt/otobo/var/cron/
    - /opt/otobo/var/article/*
    - /opt/otobo/var/stats/*.installed
    - [Base de datos](../../database/sql/mysql_mariadb.md#backup-y-restore)

3. Descargar nueva versión:

    ```sh
    wget https://ftp.otobo.org/pub/otobo/otobo-latest-...
    tar -xvzf otobo-latest-...
    cp -r otobo-x.x/* /opt/otobo
    ```

4. Poner respaldos:

      ```sh
      cd /root/otobo-update

      cp -p otobo-prod-old/Kernel/Config.pm /opt/otobo/Kernel
      cp -p otobo-prod-old/var/cron/* /opt/otobo/var/cron/

      cp -pr otobo-prod-old/var/article/* /opt/otobo/var/article/

      cd otobo-prod-old/var/stats
      cp *.installed /opt/otobo/var/stats
      ```

5. Actualizar e iniciar:

    ```sh
    /opt/otobo/bin/otobo.SetPermissions.pl

    su otobo
    /opt/otobo/bin/otobo.Console.pl Admin::Package::ReinstallAll
    /opt/otobo/bin/otobo.Console.pl Admin::Package::UpgradeAll
    exit

    systemctl start postfix apache2 cron
    ```