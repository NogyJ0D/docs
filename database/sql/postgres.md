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

- Crear usuario readonly para base de datos:

  ```sql
  CREATE USER readonly WITH ENCRYPTED PASSWORD 'readonly';
  GRANT CONNECT ON DATABASE mydb TO readonly;
  \c mydb
  -- Dar SELECT en tablas
  GRANT SELECT ON ALL TABLES IN SCHEMA public TO readonly;
  ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readonly;

  -- Dar SELECT en vistas
  -- Por cada vista nueva hay que asignar permiso
  SELECT 'GRANT SELECT ON ' || quote_ident(schemaname) || '.' || quote_ident(viewname) || ' TO readonly;' FROM pg_views WHERE schemaname = 'public';
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
