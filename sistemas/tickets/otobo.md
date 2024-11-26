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
    - [Migrar de OTRS a Otobo](#migrar-de-otrs-a-otobo)

---

## Documentación

---

## Instalación

### [Instalar Otobo en Debian 12](https://doc.otobo.org/manual/installation/10.1/en/content/installation.html)

1. Deshabilitar SELinux.

2. Descargar Otobo:

   - [Buscar la última versión](https://ftp.otobo.org/pub/otobo/)
     - Si se va a descargar para migrar OTRS, descargar la latest-10.1

   ```sh
   mkdir /opt/otobo-install /opt/otobo
   cd /opt/otobo-install
   wget https://ftp.otobo.org/pub/otobo/otobo-latest-...
   tar -xvzf otobo-latest-...
   cp -r otobo-.../* /opt/otobo
   ```

3. Instalar adicionales:

   ```sh
   apt install -y libarchive-zip-perl libtimedate-perl libdatetime-perl libconvert-binhex-perl libcgi-psgi-perl libdbi-perl libdbix-connector-perl libfile-chmod-perl liblist-allutils-perl libmoo-perl libnamespace-autoclean-perl libnet-dns-perl libnet-smtp-ssl-perl libpath-class-perl libsub-exporter-perl libtemplate-perl libtext-trim-perl libtry-tiny-perl libxml-libxml-perl libyaml-libyaml-perl libdbd-mysql-perl libapache2-mod-perl2 libmail-imapclient-perl libauthen-sasl-perl libauthen-ntlm-perl libjson-xs-perl libtext-csv-xs-perl libpath-class-perl libplack-perl libplack-middleware-header-perl libplack-middleware-reverseproxy-perl libencode-hanextra-perl libio-socket-ssl-perl libnet-ldap-perl libcrypt-eksblowfish-perl libxml-libxslt-perl libxml-parser-perl libconst-fast-perl libtext-csv-perl libjavascript-minifier-xs-perl libcss-minifier-xs-perl libcapture-tiny-perl libdbd-pg-perl
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

   a2dismod mpm_event mpm_worker
   a2enmod mpm_prefork perl deflate filter headers
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

8. Instalar base de datos:

   - [Con MariaDB](../../database/sql/mariadb.md#instalar-mariadb-en-debian-12).

     - A otobo no le gusta usar una base de datos existente con el instalador web, la opcion es crear una db con sql, usarla en la instalación y hacer un restore del dump en esta.

       1. Crear usuario y db:

          ```sql
          CREATE USER 'otobo'@'host' IDENTIFIED BY 'pass';
          CREATE DATABASE otobo;
          GRANT ALL ON otobo.* TO 'otobo'@'host';
          FLUSH PRIVILEGES;
          EXIT;
          ```

       2. Agregar en **_/etc/mysql/my.cnf_**:

          ```conf
          [mysqld]
          max_allowed_packet = 64M
          innodb_log_file_size = 256M
          ```

   - Con Postgres:

     1. Crear usuario:

        ```sh
        CREATE ROLE otobo WITH ENCRYPTED PASSWORD '[contraseña]' LOGIN;
        CREATE DATABASE otobo WITH OWNER otobo;
        ```

     2. Usar base de datos existente en el instalador web.

9. [Instalar ElasticSearch](../../database/nosql/elasticsearch.md#instalar-elasticsearch-8-en-debian-12).

   1. Instalar módulos extras:

      ```sh
      /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment && \
        /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch analysis-icu
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
   systemctl stop apache2 cron
   su otobo
   cd /opt/otobo
   bin/Cron.sh stop
   bin/otobo.Daemon.pl stop
   ```

2. Respaldar:

   ```sh
   # como root
   cd /opt
   mkdir otobo-update
   cp -pr otobo otobo-update/otobo-1x.x-old
   mysqldump -u otobo -p otobo -r otobodump.sql

   # Apache y certs
   ```

   - /etc/apache2/sites-enabled/zzz_otobo-443.conf
   - /etc/apache2/sites-enabled/zzz_otobo-80.conf
   - [Base de datos](../../database/sql/mysql_mariadb.md#backup-y-restore)

3. Si se actualiza de la 10.1 a la 11 borrar esto:

   ```sh
   rm -rf /opt/otobo/Kernel/cpan-lib/*
   ```

4. Descargar nueva versión:

   ```sh
   wget https://ftp.otobo.org/pub/otobo/otobo-latest-...
   tar -xvzf otobo-latest-...
   cp -r otobo-x.x/* /opt/otobo
   ```

5. Poner respaldos:

   ```sh
   cd /root/otobo-update

   cp -p otobo-prod-old/Kernel/Config.pm /opt/otobo/Kernel
   cp -p otobo-prod-old/var/cron/* /opt/otobo/var/cron/

   cp -pr otobo-prod-old/var/article/* /opt/otobo/var/article/

   cd otobo-prod-old/var/stats
   cp *.installed /opt/otobo/var/stats
   ```

6. Actualizar e iniciar:

   ```sh
   /opt/otobo/bin/otobo.SetPermissions.pl

   su - otobo
   /opt/otobo/bin/otobo.Console.pl Admin::Package::ReinstallAll
   /opt/otobo/bin/otobo.Console.pl Admin::Package::UpgradeAll
   /opt/otobo/bin/otobo.Console.pl Maint::Config::Rebuild

   # Si se actualiza a una versión mayor (10.1 a 11):
   /opt/otobo/scripts/DBUpdate-to-11.0.pl
   exit

   systemctl start apache2 cron
   ```

### Migrar de OTRS a Otobo

> Otobo tiene que ser versión 10, no sirve 11 o superior.

1. Desactivar "SecureMode" en la administración de OTOBO.

2. Detener el daemon de OTOBO:

   ```sh
   su - otobo
   /opt/otobo/bin/Cron.sh stop
   /opt/otobo/bin/otobo.Daemon.pl stop --force
   ```

3. Empaquetar la carpeta **_/opt/otrs_** y enviarla al servidor de otobo:

   ```sh
   su otrs -c "/opt/otrs/bin/Cron.pl stop"
   su otrs -c "/opt/otrs/bin/otrs.Daemon.pl stop"
   cd /opt
   tar cvf otrs.otobo.tar otrs
   su otrs -c "/opt/otrs/bin/Cron.pl start"
   su otrs -c "/opt/otrs/bin/otrs.Daemon.pl start"

   scp /opt/otrs.otobo.tar usuario@ip:/opt/

   tar vxf otrs.otobo.tar
   ```

4. Migrar la base de datos:

   - Si OTOBO no se puede conectar a la DB de OTRS: crear el dump, importarlo en OTOBO y crear la DB con el dump.
     - Crear db otrs con owner otrs, "psql -U otrs otrs < otrs.sql"

5. Asignar permisos a otrs:

   ```sh
   chown otobo:www-data /opt/otrs -R
   ```

6. Meterse a https://[ip]/otobo/migration.pl y seguir los pasos.

   - Si dice que SecureMode está activado, desactivarlo por consola:

     ```sh
     su - otobo
     /opt/otobo/bin/otobo.Console.pl Admin::Config::Update --setting-name SecureMode --value 0
     ```

   - Si se usa Postgres, hay que darle permiso de superusuario a otobo antes de iniciar la migración:

     ```psql
     ALTER USER otobo WITH SUPERUSER;
     ALTER USER otobo WITH NOSUPERUSER; # Despues de migrar hay que quitarlo
     ```

7. Reactivar el daemon:

   ```sh
   su otobo -c "/opt/otobo/bin/Cron.pl start"
   su otobo -c "/opt/otobo/bin/otobo.Daemon.pl start"
   ```
