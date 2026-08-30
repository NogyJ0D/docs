# Postgres

---

## Contenido

- [Postgres](#postgres)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar PostgreSQL con Docker](#instalar-postgresql-con-docker)
    - [Instalar PostgreSQL en Debian](#instalar-postgresql-en-debian)
  - [Comandos](#comandos)
  - [Extras](#extras)
    - [Activar WAL Archiving](#activar-wal-archiving)

## Documentación

- <https://wiki.debian.org/PostgreSql>

## Instalación

### Instalar PostgreSQL con Docker

```yml
services:
  postgres-db:
    image: postgres:17
    container_name: postgres-db
    restart: unless-stopped
    #ports:
    #  - "127.0.0.1:5433:5432"
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_DB: postgres
    volumes:
      - ./postgres-db:/var/lib/postgresql/data
```

### Instalar PostgreSQL en Debian

- Método 1, recomendado:

  ```sh
  apt install postgresql # O postgresql-[version]
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

- Obtener archivo de configuración:

  ```sql
  show config_file;
  ```

## Extras

### Activar WAL Archiving

1. Crear carpeta de archivo:

   ```sh
   mkdir /postgres_archive
   chown postgres:postgres /postgres_archive
   chmod 700 /postgres_archive
   ```

2. Editar el archivo de configuración `postgresql.conf`:

   ```conf
   wal_level = replica

   archive_mode = on
   archive_command = 'cp %p /postgres_archive/%f'

   max_wal_senders = 10
   wal_keep_size = 1GB
   ```

3. Reiniciar servicio: `systemctl restart postgresql`
4. Verificar:

   ```sql
   # Con psql
   show archive_mode;
   show archive_command;
   show wal_level;

   select * from pg_stat_archiver;
   ```

5. Configurar limpieza:

   ```sh
   find /postgres_archive/ -mtime +10 -type f # Probar comando. Encuentra todos los archivos con más de 10 días

   find /postgres_archive/ -mtime +10 -type f -delete # Elimina los archivos encontrados
   ```

   - Agregar al cron:

     ```sh
     0 0 * * * find /postgres_archive/ -mtime +10 -type f -delete
     ```
