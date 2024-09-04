# freeRADIUS

- [freeRADIUS](#freeradius)

---

## Instalacion

### Instalar freeRADIUS en Debian 12

1. Instalar freeradius:

    ```sh
    apt install freeradius freeradius-utils freeradius-postgresql postgresql-15
    ```

    > Cambiar "MemoryLimit" por "MemoryMax" en /lib/systemd/system/freeradius.service

2. Crear base de datos:

    ```sh
    su - postgres
    createuser radius --no-superuser --no-createdb --no-createrole -P
    createdb radius --owner=radius
    exit

    editor /etc/postgresql/15/main/pg_hba.conf
    # Editar local  all  all  md5
    systemctl restart postgresql

    psql -U radius radius < /etc/freeradius/3.0/mods-config/sql/main/postgresql/schema.sql
    ```

3. Habilitar sql:

   1. Habilitar:

      ```sh
      cd /etc/freeradius/3.0
      editor radiusd.conf # Descomentar #INCLUDE mods-enabled/sql
      ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mod-enabled/sql
      ```

   2. Configurar en **_/etc/freeradius/3.0/mods-available/sql_**:

      ```conf
      dialect = "postgresql"
      driver = "rlm_sql_postgresql"
      
      server = "localhost"
      port = 5432
      login = "radius"
      password = "radpass"
      
      radius_db = "radius"
      
      read_clients = yes
      client_table = "nas"
      ```

   3. Cambiar "-sql" por "sql" en las secciones "authorize{}" "accounting{}" y "post-auth{}" en el archivo **_/etc/freeradius/3.0/sites-available/default_** y solo para "authorize{}" en **_/etc/freeradius/3.0/sites-available/inner-tunnel_**

4. Modo testing:

    ```sh
    systemctl stop freeradius
    systemctl daemon-reload
    ```

   - En una terminal:

      ```sh
      freeradius -X
      ```

   - En otra terminal:

      ```sh
      psql -U radius radius

      INSERT INTO radcheck VALUES (1, 'user', 'Cleartext-Password', ':=' 'pass');
      exit

      radtest user pass localhost 10 testing123
      # Debe responder "Access-Accept"
      ```

---

## Extras
