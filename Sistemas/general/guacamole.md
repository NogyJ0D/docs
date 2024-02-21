# Guacamole

---

## Contenido

- [Guacamole](#guacamole)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar guacamole-server en Debian 12 compilando](#instalar-guacamole-server-en-debian-12-compilando)
    - [Instalar guacamole-server en Debian 12 compilando](#instalar-guacamole-server-en-debian-12-compilando-1)
  - [Extras](#extras)
    - [Agregar a nginx](#agregar-a-nginx)
    - [Migrar de Proxmox LXC a Proxmox VM](#migrar-de-proxmox-lxc-a-proxmox-vm)
    - [Branding](#branding)

---

## Documentación

---

## Instalación

### [Instalar guacamole-server en Debian 12 compilando](https://github.com/itiligent/Guacamole-Install)

1. Ejecutar el script:

    ```sh
    wget https://raw.githubusercontent.com/itiligent/Guacamole-Install/main/1-setup.sh && chmod +x 1-setup.sh && ./1-setup.sh
    ```

### Instalar guacamole-server en Debian 12 compilando

1. Instalar requisitos:

    ```sh
    apt install -y make libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin uuid-dev
    apt install -y libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev libwebsockets-dev
    ```

2. [Instalar mariadb](../../database/sql/mysql_mariadb.md#instalar-mariadb-en-debian-12) o usar remoto.

    ```sql
    CREATE USER 'guacamole_user'@'host' IDENTIFIED BY 'pass';
    CREATE DATABASE guacamole;
    GRANT ALL ON guacamole.* TO 'guacamole_user'@'host';
    FLUSH PRIVILEGES;
    EXIT;
    ```

3. Instalar guacamole-server:

   - Buscar última versión: <https://guacamole.apache.org/releases/>.

    ```sh
    wget https://dlcdn.apache.org/guacamole/1.5.4/source/guacamole-server-1.5.4.tar.gz && \
      tar -xzf guacamole-server-1.5.4.tar.gz && \
      cd guacamole-server-1.5.4/

    ./configure --with-init-dir=/etc/init.d
    make
    make install
    ldconfig
    # reboot

    systemctl daemon-reload
    ```

    > Si al compilar da error por algo de video.c, volver a configurar agregando "--disable-guacenc" y compilar.

4. Instalar guacamole-client:

   - [Instalar tomcat](../../web/servidores/tomcat.md#instalar-tomcat-en-debian-12).

   - Buscar última versión del .war: <https://guacamole.apache.org/releases/>.

    ```sh
    wget https://dlcdn.apache.org/guacamole/1.5.4/binary/guacamole-1.5.4.war && \
      mv guacamole-1.5.4.war /opt/tomcat/webapps/guacamole.war && \
      systemctl restart tomcat guacd && \
      systemctl enable --now guacd.service
    ```

---

## Extras

### Agregar a nginx

```nginx
location /guacamole/ {
    proxy_pass http://HOSTNAME:8080;
    proxy_buffering off;
    proxy_http_version 1.1;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $http_connection;
    client_max_body_size 1g;
    access_log off;
}
```

### Migrar de Proxmox LXC a Proxmox VM

1. Guardar archivos importantes:

     - /etc/guacamole/guacamole.properties
     - /etc/guacamole/extensions
     - Base de datos dump

2. [Instalar guacamole en nueva VM](#instalación).

3. Migrar los backups.

### Branding

1. Instalar java y repositorio:

    ```sh
    apt install default-jdk git
    git clone https://github.com/itiligent/Guacamole-Install
    ```

2. Editar archivos de ***./guacamole-install/guac-custom-theme-builder***.

3. Compilar:

    ```sh
    jar cfmv branding.jar META-INF/MANIFEST.MF guac-manifest.json css images translations META-INF
    mv branding.jar /etc/guacamole/extensions && chmod 664 /etc/guacamole/extensions/branding.jar && TOMCAT=$(ls /etc/ | grep tomcat) && systemctl restart guacd && systemctl restart ${TOMCAT}
    ```