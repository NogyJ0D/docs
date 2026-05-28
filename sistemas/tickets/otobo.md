# Otobo

---

## Contenido

- [Otobo](#otobo)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Otobo 11 en Debian 13](#instalar-otobo-11-en-debian-13)
  - [Extras](#extras)
    - [Primeros Pasos](#primeros-pasos)
    - [Cambiar Contraseña Desde la Consola](#cambiar-contraseña-desde-la-consola)
    - [Agregar usuario desde la consola](#agregar-usuario-desde-la-consola)
    - [Eliminar Ticket Definitivamente](#eliminar-ticket-definitivamente)
    - [Migrar/Actualizar Otobo](#migraractualizar-otobo)
    - [Migrar de OTRS a Otobo](#migrar-de-otrs-a-otobo)

---

## Documentación

---

## Instalación

### [Instalar Otobo 11 en Debian 13](https://doc.otobo.org/manual/installation/11.0/en/content/installation/installation-ubuntu.html)

1. Deshabilitar SELinux.

2. Descargar Otobo:
   - [Buscar la última versión de las latest](https://ftp.otobo.org/pub/otobo/)
     - Si se va a descargar para migrar OTRS, [descargar la latest-10.1](https://doc.otobo.org/manual/installation/10.1/en/content/installation.html)

   ```sh
   mkdir /opt/otobo-install /opt/otobo
   cd /opt/otobo-install
   wget https://ftp.otobo.org/pub/otobo/otobo-latest-11.0.tar.gz
   tar xzf otobo-latest-11.0.tar.gz
   cp -r otobo-11.x.x/* /opt/otobo
   ```

3. Instalar adicionales:

   ```sh
   apt-get install -y libarchive-zip-perl libtimedate-perl libdatetime-perl libconvert-binhex-perl libcgi-psgi-perl libdbi-perl libdbix-connector-perl libfile-chmod-perl liblist-allutils-perl libmoo-perl libnamespace-autoclean-perl libnet-dns-perl libnet-smtp-ssl-perl libpath-class-perl libsub-exporter-perl libtemplate-perl libtext-trim-perl libtry-tiny-perl libxml-libxml-perl libyaml-libyaml-perl libdbd-mysql-perl libapache2-mod-perl2 libmail-imapclient-perl libauthen-sasl-perl libauthen-ntlm-perl libjson-xs-perl libtext-csv-xs-perl libpath-class-perl libplack-perl libplack-middleware-header-perl libplack-middleware-reverseproxy-perl libencode-hanextra-perl libio-socket-ssl-perl libnet-ldap-perl libcrypt-eksblowfish-perl libxml-libxslt-perl libxml-parser-perl libconst-fast-perl libdbd-pg-perl rsyslog
   apt-get install -y libcapture-tiny-perl libcss-minifier-xs-perl libjavascript-minifier-xs-perl libtext-csv-perl

   /opt/otobo/bin/otobo.CheckModules.pl --list
   /opt/otobo/bin/otobo.CheckModules.pl --inst
   ```

4. Crear el usuario de Otobo:

   ```sh
   useradd -r -U -d /opt/otobo -c 'OTOBO user' otobo -s /bin/bash
   #usermod -G www-data otobo
   ```

5. Activar la configuración por defecto:

   ```sh
   cp /opt/otobo/Kernel/Config.pm.dist /opt/otobo/Kernel/Config.pm
   cp /opt/otobo/scripts/systemd/* /etc/systemd/system/
   systemctl daemon-reload
   ```

6. Instalar nginx:

   ```sh
   apt install nginx -y
   cp /opt/otobo/scripts/nginx-vhost-80.include.conf /etc/nginx/conf.d
   rm /etc/nginx/sites-enabled/default
   systemctl restart nginx
   ```

7. Otorgar permisos:

   ```sh
   /opt/otobo/bin/otobo.SetPermissions.pl --otobo-user=otobo --web-group=otobo
   ```

8. Instalar base de datos:
   - A otobo no le gusta usar una base de datos existente con el instalador web, la opcion es crear una db con sql, usarla en la instalación y hacer un restore del dump en esta.
   - Con Postgres:

     ```sh
     apt install postgresql postgresql-contrib -y
     su postgres -c psql
     ```

     1. Crear usuario:

        ```sql
        CREATE ROLE otobo WITH ENCRYPTED PASSWORD 'contraseña' LOGIN;
        CREATE DATABASE otobo WITH OWNER otobo;
        ```

   - [Con MariaDB](../../database/sql/mysql_mariadb.md#instalar-mariadb-en-debian-12).
     1. Crear usuario y db:

        ```sql
        CREATE USER 'otobo'@'host' IDENTIFIED BY 'pass';
        CREATE DATABASE otobo CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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

   - Usar base de datos existente en el instalador web.

9. [Instalar ElasticSearch](../../database/nosql/elasticsearch.md#instalar-elasticsearch-9-en-debian-13).
   1. Instalar módulos extras:

      ```sh
      /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment
      /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch analysis-icu
      systemctl restart elasticsearch.service
      ```

10. Iniciar servicio otobo: `systemctl enable --now otobo-web.service`.
    - Si da error porque falta Gazelle.pm:

      ```sh
      apt install build-essential -y
      cpan Gazelle
      ```

11. Ingresar a <http://ip/otobo/installer.pl>
    - Usar una base de datos existente para OTOBO.
    - Al darle a Siguiente en la base de datos, esperar a que termine. No darle dos veces o habrá que droppear la db.
    - El FQDN debe ser el dominio de la página.
    - Configurar el Log Engine como syslog.
    - Para el correo:
      - Si es SMTP SSL/TLS usar SMTPS.
      - Si es POP SSL/TLS usar POP3S.

12. Finales:
    1. Iniciar el daemon como otobo: `systemctl enable --now otobo-daemon.service`.
    2. Hacer los [primeros pasos](#primeros-pasos).

---

## Extras

### Primeros Pasos

1. Agregar grupo soporte:
   - Administración > Usuarios, Grupos y Roles > Grupos > Añadir grupo
     - Agregar grupo "Soporte"
     - Agregar a los usuarios al grupo
2. Agregar correos:
   1. Administración > Comunicación y Notificaciones > Cuentas de Correo Electrónico - **Este es el que se conecta para obtener los correos del servidor**
      - Agregar si no se agregó en la instalación.
      - Si ya está, modificarlo para poner "Validado" "Si".
   2. Administración > Comunicación y Notificaciones > Direcciones de Correo > Añadir dirección - **Este es el que se usa para los correos salientes**
      - Nombre: "Soporte", Cola: "Soporte" (**agregar cuando esté la cola**)
3. Añadir cola soporte:
   - Administración > Ajustes de Tickets > Colas > Añadir cola
     - Nombre: "Soporte", Grupo: "Soporte", Dirección del sistema: la agregada antes.
4. Crear saludo y firma:
   1. Administración > Ajustes de los tickets > Saludos > Añadir firma
      - Nombre: "Saludo"
      - Contenido:

        ```text
        Hola <OTOBO_CUSTOMER_DATA_UserFirstname>,
        ```

   2. Administración > Ajustes de los tickets > Firmas > Añadir firma
      - Nombre: "Firma"
      - Contenido:

        ```text
        Atentamente,

        <OTOBO_CURRENT_UserFirstname> <OTOBO_CURRENT_UserLastname>
        Empresa
        --
        Este es un correo automatizado. Por favor, responda directamente a este mensaje si necesita agregar más información sobre este caso.
        ```

   3. Agregarlos en la cola "Soporte".

5. Crear respuesta automática (recordar asignarles el correo):
   1. Seguimiento por defecto:
      - Asunto: "Recibimos tu solicitud de soporte"
      - Tipo: "auto responder"

      ```text
      Hola <OTOBO_Customer_Data_UserFirstname>,

      Hemos recibido tu solicitud de soporte de manera correcta. Se ha generado un ticket en nuestro sistema para hacer el seguimiento de tu caso.

      A partir de este momento, un técnico revisará tu reporte. Los datos de tu caso son:
      - Número de Ticket: [Ticket#<OTOBO_TICKET_TicketNumber>]
      - Asunto: <OTOBO_Customer_Subject>

      Si deseas agregar más detalles o capturas de pantalla, simplemente responde a este correo electrónico manteniendo el asunto intacto para que se adjunte automáticamente a tu historial.

      Te mantendremos informado/a de cualquier avance.
      ```

   2. Rechazo por defecto:
      - Asunto: "[Rechazado] Tu correo no pudo ser procesado por el sistema de soporte"

      ```text
      Hola,

      Lamentamos informarte que tu correo electrónico con el asunto "<OTOBO_Customer_Subject>" no ha podido ser procesado por nuestro sistema de tickets.

      Esto puede deberse a una de las siguientes razones:
      1. Tu dirección de correo no está autorizada para abrir solicitudes.
      2. El mensaje contiene archivos adjuntos no permitidos o sospechosos.
      3. El formato del correo no es compatible con nuestra plataforma.

      Si crees que esto es un error, por favor ponte en contacto con el administrador de sistemas de tu empresa o intenta enviar el correo nuevamente sin archivos adjuntos pesados.
      ```

   3. Rechazo por defecto / Nuevo ticket creado:
      - Asunto: "Solicitud reabierta en un nuevo caso"

      ```text
      Hola <OTOBO_Customer_Data_UserFirstname>,

      Hemos recibido tu mensaje respecto al caso anterior. Dado que ese ticket ya se encontraba cerrado y resuelto definitivamente, nuestro sistema ha rechazado la reapertura del registro por control de calidad.

      Sin embargo, para no dejar de atenderte, **hemos creado automáticamente un NUEVO ticket** para procesar tu consulta actual.

      Tus nuevos datos de seguimiento son:
      - Nuevo Número de Ticket: [Ticket#<OTOBO_TICKET_TicketNumber>]

      A la brevedad un agente retomará el caso analizando tus comentarios. ¡Muchas gracias!
      ```

   4. Respuesta por defecto:
      - Asunto: "Actualización del sistema de soporte"

      ```text
      Hola <OTOBO_Customer_Data_UserFirstname>,

      Te escribimos para notificarte que ha habido una actualización en tu ticket de soporte [Ticket#<OTOBO_Ticket_TicketNumber>].

      El estado actual de tu solicitud ha cambiado debido a las últimas acciones tomadas por nuestro equipo técnico o por la inactividad del caso.

      Para revisar cualquier novedad o si consideras que aún necesitas asistencia con este problema, por favor responde a este mensaje para informarle directamente al técnico asignado.
      ```

   5. Asignar las respuestas a la cola "Soporte":
      - Administración > Ajustes de Tickets > Colas - Auto Respuestas

6. Crear plantilla de respuesta:
   1. Administración > Ajustes de Tickets > Plantillas
      - Tipo: "Responder".
      - Nombre: "Común".
      - Contenido:

        ```text
        Nos ponemos en contacto para informarte que hemos revisado tu solicitud respecto al caso "<OTOBO_TICKET_Subject>".

        [ESCRIBIR AQUÍ LA RESPUESTA O SOLUCIÓN PARA EL CLIENTE]

        Por favor, realiza las pruebas correspondientes y confírmanos si el inconveniente quedó resuelto o si necesitas asistencia adicional.
        ```

   2. Administración > Ajustes de Tickets > Plantillas - Colas
      - Cola "Soporte"
      - Asignar la plantilla "Correo electrónico - Común".

7. Desactivar notificación de bloqueo/desbloqueo de tickets al agente:
   - Administración > Comunicación y Notificaciones > Notificaciones de Ticket
     - Notificación de seguimiento del ticket (bloqueado): invalidar
     - Notificación de seguimiento del ticket (bloqueado): invalidar
8. Definir clientes (empresas y usuarios)
   1. Administración > Usuarios, Grupos y Roles > Clientes
      - El cliente es la empresa.
   2. Administración > Usuarios, Grupos y Roles > Clientes (Usuarios)
      - El usuario pertenece a un cliente (empresa).
9. Desactivar el portal de clientes:
   - Administración > Administración > Configuración de Sistema
     - CustomerFrontend::Active desactivado
   - Hacer deploy
10. **Reducir el tiempo de búsqueda de correos de 10m a 2m**:
    - Administración > Administración > Configuración de Sistema
      - Daemon::SchedulerCronTaskManager::Task###MailAccountFetch
        - Schedule: `*/2 * * * *`
    - Hacer deploy

### Cambiar Contraseña Desde la Consola

```sh
su otobo -c "/opt/otobo/bin/otobo.Console.pl Admin::User::SetPassword <usuario> <contraseña>"
```

### Agregar usuario desde la consola

```sh
su otobo -c "/opt/otobo/bin/otobo.Console.pl Admin::User::Add --user-name <> --first-name <> --last-name <> --email-address <> --password <>"
```

### Eliminar Ticket Definitivamente

```sh
su otobo -c "/opt/otobo/bin/otobo.Console.pl Maint::Ticket::Delete --ticket-number 2015071510123456"
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
