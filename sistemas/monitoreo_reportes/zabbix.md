# Zabbix

---

## Contenido

- [Zabbix](#zabbix)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Zabbix 6.4 en Debian 12](#instalar-zabbix-64-en-debian-12)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### Instalar Zabbix 6.4 en Debian 12

1. Instalar db y nginx:

   1. **Postgresql y Nginx**:

      ```sh
      apt install sudo postgresql nginx sudo -y
      ```

   2. **MariaDB y Nginx**:

      ```sh
      apt install sudo mariadb-server mariadb-client nginx -y
      systemctl enable --now mariadb
      mysql_secure_installation
      ```

2. Instalar repositorio:

   ```sh
   wget https://repo.zabbix.com/zabbix/7.2/release/debian/pool/main/z/zabbix-release/zabbix-release_latest_7.2+debian12_all.deb && dpkg -i zabbix-release_latest_7.2+debian12_all.deb && apt update
   ```

3. Instalar componentes:

   - **Con Postgres**:

     ```sh
     apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -y
     ```

   - **Con MariaDB**:

     ```sh
     apt install zabbix-server-mysql zabbix-frontend-php zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -y
     ```

4. Crear base de datos:

   - **Con Postgres**:

     ```sh
     sudo -u postgres createuser --pwprompt zabbix
     sudo -u postgres createdb -O zabbix zabbix
     zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
     ```

   - **Con MariDB**:

     ```sh
     mysql
     ```

     ```sql
     CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
     CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'password';
     GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
     SET GLOBAL log_bin_trust_function_creators = 1;
     QUIT;
     ```

     ```sh
     zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -u zabbix -p zabbix
     mysql
     ```

     ```sql
     SET GLOBAL log_bin_trust_function_creators = 0;
     QUIT;
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
   listen 80;
   server_name <_ o IP o dominio>;
   ```

   > Este archivo tiene un link simbólico en /etc/nginx/conf.d/zabbix.conf (carpeta incluida en el bloque http).

7. Iniciar Zabbix:

   ```sh
   systemctl enable zabbix-server zabbix-agent nginx php8.2-fpm
   reboot # Reiniciar para que tome el lenguaje
   ```

Abrir la web. El usuario por defecto es Admin y la contraseña zabbix.

---

## Extras
