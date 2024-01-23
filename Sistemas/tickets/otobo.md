# Otobo

---

## Contenido

- [Otobo](#otobo)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Otobo en Debian 12](#instalar-otobo-en-debian-12)
  - [Extras](#extras)

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
    cp -r otobo-.../* /opt/otobo
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

   1. Ejecutar en mysql:

        ```sql
        ALTER USER 'root'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD('root');
        ```

   2. Agregar en ***/etc/mysql/my.cnf***:

        ```conf
        [mysqld]
        max_allowed_packet = 64M
        innodb_log_file_size = 256M
        ```

9. [Instalar ElasticSearch](../../a_clasificar/elasticsearch.md#instalar-elasticsearch-8-en-debian-12).

   1. Instalar módulos extras:

      ```sh
      /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment
      /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch analysis-icu
      ```

   2. Modificar en ***/etc/elasticsearch/jvm.options***:

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
