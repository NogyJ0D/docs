# MYSQL/MariaDB

---

## Contenido

- [MYSQL/MariaDB](#mysqlmariadb)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar mysql con APT](#instalar-mysql-con-apt)
    - [Instalar mariadb en Debian 12](#instalar-mariadb-en-debian-12)
    - [Instalar mariadb en Alpine](#instalar-mariadb-en-alpine)
  - [Comandos](#comandos)
    - [Mostrar usuarios](#mostrar-usuarios)
    - [Mostrar DB](#mostrar-db)
    - [Crear usuario](#crear-usuario)
    - [Ver filas con otro formato](#ver-filas-con-otro-formato)
    - [Ver permisos de usuario](#ver-permisos-de-usuario)
  - [Extras](#extras)
    - [Habilitar conexión remota](#habilitar-conexión-remota)
    - [Backup y restore](#backup-y-restore)

---

## Documentación

---

## Instalación

### [Instalar mysql con APT](https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/#apt-repo-fresh-install)

1. Descargar el repositorio:

   1. Descargar el [archivo .deb](https://dev.mysql.com/downloads/repo/apt/).

   2. Ejecutar:

        ```sh
        apt install gnupg -y
        apt install ./nombre_del_archivo.deb
        apt update
        ```

   - Si se está en debian 12 y pide seleccionar un SO compatible para los repositorios, usar Ubuntu Lunar.

2. Descargar mysql-server:

   1. Ejecutar:

        ```sh
        apt install mysql-server -y
        ```

### [Instalar mariadb en Debian 12](https://voidnull.es/instalar-mariadb-en-debian-12/)

```sh
apt -y install mariadb-server mariadb-client
systemctl enable --now mariadb
mysql_secure_installation
```

### [Instalar mariadb en Alpine](https://www.librebyte.net/base-de-datos/como-instalar-mariadb-en-alpine-linux/)

```sh
apk add mariadb mariadb-client
/etc/init.d/mariadb setup
rc-service mariadb start
rc-update add mariadb default
mariadb-secure-installation 
```

---

## Comandos

### Mostrar usuarios

```sql
SELECT user, host FROM mysql.user;
```

### Mostrar DB

```sql
SHOW DATABASES;
```

### Crear usuario

```sql
CREATE USER 'usuario'@'localhost/%' IDENTIFIED by 'contraseña';
```

### Ver filas con otro formato

```sql
SELECT * FROM sometable\G
```

### Ver permisos de usuario

```sql
SHOW GRANTS FOR usuario;
```

---

## Extras

### Habilitar conexión remota
  
1. Entrar al que exista:

   - /etc/mysql/my.cnf
   - /etc/my.cnf
   - /etc/my.cnf.d/mariadb-server.cnf

2. Modificar:

    ```conf
    [mysqld]
    #skip-networking      # Comentar este
    bind-address=0.0.0.0  # Descomentar este
    ```

3. Reiniciar servicio.

- Para poder conectarse remotamente con un usuario hay que crear el usuario pero en lugar de 'user'@'localhost' es 'user'@'%' o 'user'@'ip'.

### Backup y restore

- Backup

    ```sh
    mysqldump -u root [database / --all-databases] > archivo.sql
    ```

- Restore

    ```sh
    mysql -u root < archivo.sql
    ```
