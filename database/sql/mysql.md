# MYSQL

---

## Contenido

- [MYSQL](#mysql)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar mysql con APT](#instalar-mysql-con-apt)
  - [Extras](#extras)

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

---

## Extras
