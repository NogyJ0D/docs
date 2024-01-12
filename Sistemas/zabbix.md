# Zabbix

## Instalación

### Especificación:
- Zabbix 6.4
- Debian 12
- Server, Frontend, Agent
- PostgreSQL
- Nginx

### Pasos
0. **Instalar PostgreSQL y Nginx**:
Postgres 15 y Nginx 1.22 ya incluidos en Debian 12.
```sh
apt install sudo postgresql-15 nginx -y
```

1. **Instalar repositorio**:
```sh
wget https://repo.zabbix.com/zabbix/6.4/debian/pool/main/z/zabbix-release/zabbix-release_6.4-1+debian12_all.deb &&
dpkg -i zabbix-release_6.4-1+debian12_all.deb &&
apt update
```

2. **Instalar componentes**:
```sh
apt install zabbix-server-pgsql zabbix-frontend-php php8.2-pgsql zabbix-nginx-conf zabbix-sql-scripts zabbix-agent -y
```

3. **Crear base de datos**:
Tener instalado postgres.
```sh
sudo -u postgres createuser --pwprompt zabbix
sudo -u postgres createdb -O zabbix zabbix
zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix 
```
Modificar ***/etc/zabbix/zabbix_server.conf***:
```text
DBPassword=<contraseña>
```

4. **Configurar lenguaje**:
Zabbix no soporta español asi que hay que descargar el paquete ingles.
Descomentar en ***/etc/locale.gen***:
```text
en_US.UTF-8 UTF-8
```
Ejecutar:
```sh
locale-gen
```

Agregar en ***/etc/zabbix/php-fpm.conf*** para que tome el horario:
```text
php_value[date.timezone] = America/Argentina/Buenos_Aires
```

5. **Configurar nginx**:
Editar en ***/etc/zabbix/nginx.conf***:
```text
listen 80;
server_name <IP o dominio>;
```
Este archivo tiene un link simbólico en /etc/nginx/conf.d/zabbix.conf (carpeta incluida en el bloque http).

6. **Iniciar Zabbix**:
```sh
systemctl restart zabbix-server zabbix-agent nginx php8.2-fpm
systemctl enable zabbix-server zabbix-agent nginx php8.2-fpm
```
Abrir la web. El usuario por defecto es Admin y la contraseña zabbix.