# Zabbix

---

## Contenido

- [Zabbix](#zabbix)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Zabbix 7.4 en Debian 12](#instalar-zabbix-74-en-debian-12)
    - [Instalar Zabbix-Proxy en Debian 13](#instalar-zabbix-proxy-en-debian-13)
    - [Instalar Agente 2 en Windows](#instalar-agente-2-en-windows)
    - [Abrir Puertos en Destino](#abrir-puertos-en-destino)
  - [Extras](#extras)
    - [Agregar Mikrotik como equipo](#agregar-mikrotik-como-equipo)
    - [Tunning](#tunning)
      - [TimescaleDB](#timescaledb)
      - [Discard Unchanged](#discard-unchanged)

---

## Documentación

---

## Instalación

### Instalar Zabbix 7.4 en Debian 12

1. Instalar db y nginx:

   ```sh
   apt install postgresql nginx -y
   ```

2. Instalar repositorio:

   ```sh
   wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
   dpkg -i zabbix-release_latest_7.4+debian13_all.deb
   apt update
   ```

3. Instalar componentes:

   ```sh
   apt install zabbix-server-pgsql zabbix-frontend-php php8.4-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent2 zabbix-agent2-plugin-postgresql -y
   ```

4. Crear base de datos:

   ```sh
   su postgres -c "createuser --pwprompt zabbix"
   su postgres -c "createdb -O zabbix zabbix"
   zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | su zabbix -s /bin/bash -c "psql zabbix"
   ```

   - Modificar en **_/etc/zabbix/zabbix_server.conf_**:

     ```conf
     DBPassword=<contraseña>
     ```

5. Configurar lenguaje:

   Zabbix no soporta español asi que hay que descargar el paquete ingles.
   - Descomentar en **_/etc/locale.gen_**:

     ```text
     en_US.UTF-8 UTF-8
     es_ES.UTF-8 UTF-8
     ```

   - Ejecutar:

     ```sh
     locale-gen
     ```

   - Agregar en **_/etc/zabbix/php-fpm.conf_** para que tome el horario:

     ```conf
     php_value[date.timezone] = America/Argentina/Buenos_Aires
     ```

6. Editar en **_/etc/zabbix/nginx.conf_**:

   ```nginx
   listen 80 default_server;
   server_name _;
   ```

   > Este archivo tiene un link simbólico en /etc/nginx/conf.d/zabbix.conf (carpeta incluida en el bloque http).
   > Borrar /etc/nginx/sites-enabled/default

7. Iniciar Zabbix:

   ```sh
   systemctl enable zabbix-server zabbix-agent2 nginx php8.4-fpm
   reboot # Reiniciar para que tome el lenguaje
   ```

Abrir la web. El usuario por defecto es Admin y la contraseña zabbix.

### Instalar Zabbix-Proxy en Debian 13

1. Instalar repositorio:

   ```sh
   wget https://repo.zabbix.com/zabbix/7.4/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.4+debian13_all.deb
   dpkg -i zabbix-release_latest_7.4+debian13_all.deb
   apt update
   ```

2. Instalar proxy:

   ```sh
   apt install zabbix-proxy-sqlite3
   ```

3. Crear PSK:

   ```sh
   openssl rand -hex 32 > /etc/zabbix/zabbix_proxy.psk
   chown zabbix:zabbix /etc/zabbix/zabbix_proxy.psk
   chmod 600 /etc/zabbix/zabbix_proxy.psk
   ```

4. Configurar `/etc/zabbix/zabbix_proxy.conf`:

   ```conf
   ProxyMode=0 # Modo activo
   Server=IP/DOMINIO # IP Pública o dominio donde está el server
   Hostname=Proxy Empresa # Host del proxy
   DBName=/var/lib/zabbix/zabbix_proxy.db # Ruta a la db sqlite
   ProxyConfigFrequency=60 # Enviar datos cada 60 segundos

   TLSConnect=psk
   TLSAccept=psk
   TLSPSKIdentity=PSK-Empresa
   TLSPSKFile=/etc/zabbix/zabbix_proxy.psk
   ```

5. Crear carpeta de la db:

   ```sh
   mkdir /var/lib/zabbix
   chown -R zabbix:zabbix /var/lib/zabbix
   ```

6. [Abrir puerto en el destino](#abrir-puertos-en-destino).
7. Agregar el proxy en zabbix:
   1. Administración > Proxies > Create Proxy
      - Proxy:
        - Proxy name: Proxy Empresa
        - Proxy mode: Active
      - Encryption:
        - Connections from proxy: PSK
        - PSK Identity: PSK-Empresa
        - PSK: <PSK generado en /etc/zabbix/zabbix_proxy.psk>
8. Reiniciar servicio: `systemctl restart zabbix-proxy`.

### Instalar Agente 2 en Windows

1. [Descargar agente 2](https://www.zabbix.com/download_agents).
2. Abrir cmd donde está el instalador y ejecutar:
   - Hay que poner la ruta completa del instalador.
   - Para que sea silencioso: agregar `/qn`.
   - SERVERACTIVE: el dominio del zabbix-server (si está fuera de la red) o la ip (si está dentro). **Si hay un proxy en la oficina**, poner la ip de este.
   - SERVER: el localhost para que el agente sea activo. **Si hay un proxy en la oficina**, poner la ip de este.
   - STARTAGENTS: 0 para agente activo (envia los datos) y 1 para agente pasivo (el server le pide los datos). Si está fuera de la red, tiene que ser 0.
   - HOSTNAME: todos los equipos tienen que tener nombres distintos. Ej: Empresa-Servidor1, Empresa2-Servidor1

   ```cmd
   msiexec /i "C:\...\zabbix_agent2-x.x.x-windows-amd64-openssl.msi" /norestart SERVERACTIVE="dominio o ip" SERVER="127.0.0.1" STARTAGENTS=0 HOSTNAME="nombre diferenciable"
   ```

3. Una vez instalado, ir a la web:
   1. Recopilación de Datos > Equipos
   2. Crear equipo
      - Nombre: el mismo tal cual en el instalador.
      - Plantillas: "Windows by Zabbix agent active".
      - Grupos: el grupo al que pertenece.
      - Interfaces: **vacio**, es un agente activo.

### Abrir Puertos en Destino

- Usando router Mikrotik
- Usando proxy reverso Nginx con Stream para centralización

1. En mikrotik redirigir los puertos 80, 443 y 10051:

   ```routeros
   /ip firewall nat add chain=dstnat action=dst-nat to-addresses=<ip nginx> to-ports=10051 protocol=tcp in-interface=ether5 dst-port=10051 comment="zabbix"
   /ip firewall filter add chain=forward action=accept protocol=tcp dst-address=<ip zabbix> dst-port=80,443,10051 comment="nginx"
   ```

2. En nginx configurar el stream:

   ```sh
   apt install libnginx-mod-stream
   vim /etc/nginx/nginx.conf
   ```

   ```conf
   stream {
     upstream zabbix_backend_tcp {
       server <ip zabbix>:10051;
     }

     server {
       listen 10051;
       proxy_pass zabbix_backend_tcp;
       proxy_timeout 60s;
       proxy_connect_timeout 30s;
     }
   }
   ```

   ```sh
   nginx -s reload
   ```

## Extras

### Agregar Mikrotik como equipo

- Hay que usar SNMP que es bastante inseguro. Mínimo SNMPv2c.
- Si el Mikrotik está fuera de la red del Zabbix Server es preferible no hacer el proceso de activarlo y abrir el puerto para que se comunique directo con el server (que también tendría que ser SNMPv3 con el cifrado de cada paquete), sino que activar el v2c y usar un Zabbix Proxy en una máquina local (que de paso junte toda la data de los equipos en esa red) y haga ese el envio al server por ser active.

1. Activar SNMP en el router:
   1. Ir a IP > SNMP > Communities:
      1. Renombrar "public" con un nombre recordable (EmpresaInternalMon, ej), con la IP apuntando al server (o proxy) y read access activado.
      - SNPMv2c se activa por defecto (si no se pone usuario y contraseña), no v1.
   2. Volver a SNMP:
      1. Activar el Enabled y listo.
2. Dar de alta el Mikrotik en la web:
   1. Ir a Zabbix > Data Collection > Hosts
   2. Agregar equipo:
      - Nombre: Mikrotik-Oficina
      - Template: Mikrotik by SNMP
      - Interfaces:
        - IP address: 192.168.0.1
        - Port: 161
      - Monitored by: Server/Proxy
      - Macros:
        - Macros heredadas y de equipo > Buscar {$SNMP_COMMUNITY} y setear con el nombre de la community que se puso en el router.
      - Aplicar

### Tunning

#### TimescaleDB

- <https://www.zabbix.com/documentation/current/en/manual/appendix/install/timescaledb>
- <https://www.tigerdata.com/docs/get-started/choose-your-path/install-timescaledb>
- <https://infotechys.com/zabbix-7-0-timescaledb-compression/>

<br>

- Es una extensión de PostgresDB que permite la compresión de registros repetidos en una base de datos.
- Instalación:
  1. Instalar dependencias: `apt install gnupg postgresql-common apt-transport-https lsb-release`
  2. Agregar repositorio:

     ```sh
     wget --quiet -O- https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor | tee /usr/share/keyrings/timescaledb-archive-keyring.gpg > /dev/null

     cat <<EOF > /etc/apt/sources.list.d/timescaledb.sources
     Types: deb
     URIs: https://packagecloud.io/timescale/timescaledb/debian/
     Suites: trixie
     Components: main
     Signed-By: /usr/share/keyrings/timescaledb-archive-keyring.gpg
     EOF

     apt update
     apt install timescaledb-2-postgresql-17 # Revisar qué versión se tiene de pg
     ```

  3. Optimizar PostgreSQL:

     ```sh
     timescaledb-tune --quiet --yes
     systemctl restart postgresql
     ```

  4. Habilitar la extensión en la base de datos de Zabbix:

     ```sh
     echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" | su zabbix -s /bin/bash -c "psql zabbix"
     ```

  5. Migrar el esquema:

     ```sh
     systemctl stop zabbix-server
     cat /usr/share/zabbix/sql-scripts/postgresql/timescaledb/schema.sql | su zabbix -s /bin/bash -c "psql zabbix"
     ```

     - Ahora se debería iniciar el servicio de zabbix-server, pero en este momento da error porque la versión instalada de TimescaleDB es superior a la que Zabbix 7.4 soporta (2.26 < 2.27.1) pero no es problema porque realmente lo soporta igual.
     - Hay que obligarlo a aceptar esta versión editando el archivo `/etc/zabbix/zabbix_server.conf`:

       ```sh
       AllowUnsuportedDBVersions=1 # Descomentar y poner en 1
       ```

     ```sh
     systemctl restart zabbix-server
     ```

  6. Habilitar TimescaleDB en la web:
     - Administración > Housekeeping (Limpieza)
     - History, trends and audit log compression (Historial, tendencias y compresión de registros de auditoría): Activar

- En la base de datos (`su zabbix -s /bin/bash -c "psql zabbix"`) se puede ver con `\dx` que está la extensión activada.
  - También con `SELECT * from timescaledb_information.hypertables;`

#### Discard Unchanged

- Si un dato es siempre el mismo, no se registra el valor hasta que cambie, evitando la duplicación de datos innecesaria.
- Es mejor usar [TimescaleDB](#timescaledb).
- Esto se activa métrica por métrica, no es global ni en masa.

1. Ir a "Preprocessing" en la métrica deseada de una plantilla.
2. Añadir el paso "Discard Unchanged with heartbeat" con un tiempo de "1h" o "2h". Si a las 12h el valor no cambia, igualmente se hace el registro para saber que el equipo está funcionando.
