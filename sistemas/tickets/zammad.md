# Zammad

---

## Contenido

- [Zammad](#zammad)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Zammad en Debian 13](#instalar-zammad-en-debian-13)
      - [Pre-Requisitos](#pre-requisitos)
      - [Instalación](#instalación-1)
  - [Extras](#extras)
    - [Configurar correo](#configurar-correo)

---

## Documentación

- [Pre-requisitos](https://docs.zammad.org/en/latest/prerequisites/software.html)

- [Instalación por paquete](https://docs.zammad.org/en/latest/install/package.html)

---

## Instalación

### Instalar Zammad en Debian 13

- Zammad 7+ ya no soporta mysql

#### [Pre-Requisitos](https://docs.zammad.org/en/latest/prerequisites/software.html)

1. Instalar requisitos:

   ```sh
   apt install libimlib2 curl apt-transport-https gnupg
   ```

2. [Instalar ElasticSearch](../../database/nosql/elasticsearch.md#instalar-elasticsearch-9-en-debian-13).
   1. Configurar en **_/etc/elasticsearch/elasticsearch.yml_**:

      ```yml
      # Zammad
      http.max_content_length: 400mb
      indices.query.bool.max_clause_count: 2000
      ```

3. [Instalar Postgres](../../database/sql/postgres.md#instalar-postgresql-en-debian)

4. Instalar NodeJS:
   - NodeJS ya viene con el paquete, no hace falta instalarlo si no se va a usar para otra cosa.
   - Zammad 6.2+ usa Node 18.0+

5. [Instalar nginx](../../web/servidores/nginx.md#instalar-nginx-en-debian)

6. [Instalar Redis](../../database/nosql/redis.md#instalar-redis-en-debian-13).

#### [Instalación](https://docs.zammad.org/en/latest/install/package.html)

1. Configurar local:

   ```sh
   # Obtener idioma del sistema
   locale | grep "LANG="
   ```

2. Agregar repositorio e instalar:

   ```sh
   curl -fsSL https://go.packager.io/srv/deb/zammad/zammad/gpg-key.asc | \
   gpg --dearmor | tee /usr/share/keyrings/zammad.gpg > /dev/null \
   && chmod 644 /usr/share/keyrings/zammad.gpg

   curl -fsSL https://go.packager.io/srv/zammad/zammad/stable/installer/debian/13.list \
   -o /etc/apt/sources.list.d/zammad.list

   apt update && apt install zammad -y
   ```

3. [Configuraciones de seguridad](https://docs.zammad.org/en/latest/install/package.html#firewall-selinux)

   ```sh
   chcon -Rv --type=httpd_sys_content_t /opt/zammad/public/
   setsebool httpd_can_network_connect on -P
   semanage fcontext -a -t httpd_sys_content_t /opt/zammad/public/
   restorecon -Rv /opt/zammad/public/
   chmod -R a+r /opt/zammad/public/
   ```

4. [Conectar ElasticSearch](https://docs.zammad.org/en/latest/getting-started/configure-webserver.html#adjusting-the-webserver-configuration):

   ```sh
   zammad run rails r "Setting.set('es_url', 'https://localhost:9200')"
   zammad run rails r "Setting.set('es_user', 'elastic')"
   /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic -i # Copiar contraseña
   zammad run rails r "Setting.set('es_password', '<password>')" # Poner contraseña anterior
   cat /etc/elasticsearch/certs/http_ca.crt | zammad run rails r 'SSLCertificate.create!(certificate: STDIN.read)'

   zammad run rake zammad:searchindex:rebuild
   ```

5. [Configurar proxy](https://docs.zammad.org/en/latest/getting-started/configure-webserver.html#adjusting-the-webserver-configuration):
   - HTTP:

     ```sh
     # Ya viene por defecto
     cp /opt/zammad/contrib/nginx/zammad.conf /etc/nginx/sites-available/zammad.conf
     rm /etc/nginx/sites-enabled/default
     nginx -s reload
     ```

   - HTTPS:

     ```sh
     cp /opt/zammad/contrib/nginx/zammad_ssl.conf /etc/nginx/sites-available/zammad.conf
     rm /etc/nginx/sites-enabled/default
     nginx -s reload
     ```

6. Entrar a `http://ip/` para crear el administrador y finalizar.

---

## Extras

### Configurar correo

1. Ir a Ajustes > Canales > Correo electrónico > Ajustes:
   1. Configurar el _Notificador de la notificación/Remitente_ como _<ejemplo@dominio.com>_
2. Ir a Ajustes > Canales > Correo electrónico > Accounts:
   1. Agregar el servidor SMTP saliente.
   2. En _Cuentas de Correo Electrónico_ agregar la cuenta de la que se van a tomar los correos.
