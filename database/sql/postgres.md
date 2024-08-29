# Postgres

---

## Contenido

- [Postgres](#postgres)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
  - [Instalación](#instalación)
    - [Instalar Postgresql en Debian 12](#instalar-postgresql-en-debian-12)

---

## Documentación

- <https://wiki.debian.org/PostgreSql>

---

## Comandos

- Entrar a psql:

  ```sh
  su -c /usr/bin/psql postgres
  sudo -u postgres psql
  su postgres -c psql
  ```

- Crear usuario:

  ```sh
  createuser --pwprompt {usuario}
  ```

  ```sql
  CREATE USER usuario WITH CREATEDB CREATEROLE;
  ALTER USER usuario WITH ENCRYPTED PASSWORD 'contraseña';
  ```

- Crear DB:

  ```sh
  createdb -O {owner} db
  ```

---

## Instalación

### Instalar Postgresql en Debian 12

- Método 1, recomendado:

    ```sh
    apt install postgresql-[version]
    ```

- Método 2, si no funciona el otro:

    ```sh
    apt -y install postgresql-common
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh
    apt update
    apt install postgresql-[version]
    ```

- Entrar a la consola:

    ```sh
    su postgres -c psql
    ```

- Cambiar contraseña por defecto:

    ```sql
    ALTER USER postgres WITH PASSWORD 'contraseña';
    ```
