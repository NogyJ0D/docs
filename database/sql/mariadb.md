# MariaDB

---

## Contenido

- [MariaDB](#mariadb)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar mariadb en Debian 12](#instalar-mariadb-en-debian-12)
    - [Instalar mariadb en Alpine](#instalar-mariadb-en-alpine)
  - [Extras](#extras)
    - [Habilitar conexión remota](#habilitar-conexión-remota)

## Documentación

---

## Instalación

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

- Para poder conectarse remotamente con un usuario hay que crear el usuario pero en lugar de 'user'@'localhost' es 'user'@'%'.
