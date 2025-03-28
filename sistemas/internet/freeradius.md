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

2. Configurar clientes:

   - Agregar al comienzo de **_/etc/freeradius/3.0/clients.conf_**:

     ```conf
     client unifi {
       ipaddr = x.x.x.x/x # Rango de DHCP
       secret = secreto # Secreto a usar
       proto = *
       shortname = 'Nombre'
       require_message_authenticator = yes
     }
     ```

3. Crear base de datos:

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

4. Habilitar sql:

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

   3. Cambiar "-sql" por "sql" en las secciones "authorize{}" "accounting{}", "post-auth{}" y "session {}" en los archivos **_/etc/freeradius/3.0/sites-available/default_** y **_/etc/freeradius/3.0/sites-available/inner-tunnel_**

5. Modo testing:

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

     INSERT INTO radcheck (username, attribute, op, value) VALUES ('user', 'Cleartext-Password', ':=' 'pass');
     exit

     radtest user pass localhost 10 testing123
     # Debe responder "Access-Accept"
     ```

---

## Extras

### SQL

#### Inserts

```sql
INSERT INTO radcheck (username, attribute, op, value) VALUES ('usuario', 'Cleartext-Password', ':=', 'pass');
INSERT INTO radcheck (username, attribute, op, value) VALUES ('usuario', 'Expiration', ':=', '23 Sep 2024 12:00');
```

#### Reemplazar radcheck por varias tablas

1. Detener servicio, borrar base de datos y volverla a crear.

2. Modificar esquema en **_/etc/freeradius/3.0/mods-config/sql/main/postgresql/schema.sql_**:

   ```sql
   CREATE TABLE IF NOT EXISTS usuarios1 (
       id                      serial PRIMARY KEY,
       UserName                text NOT NULL DEFAULT '',
       Attribute               text NOT NULL DEFAULT '',
       op                      VARCHAR(2) NOT NULL DEFAULT '==',
       Value                   text NOT NULL DEFAULT ''
   );
   create index usuarios1_UserName_lower on usuarios1 (lower(UserName),Attribute);

   CREATE TABLE IF NOT EXISTS usuarios2 (
           id                      serial PRIMARY KEY,
           UserName                text NOT NULL DEFAULT '',
           Attribute               text NOT NULL DEFAULT '',
           op                      VARCHAR(2) NOT NULL DEFAULT '==',
           Value                   text NOT NULL DEFAULT ''
   );
   create index usuarios2_UserName_lower on usuarios2 (lower(UserName),Attribute);

   -- Para grupos
   create index radusergroup_UserName_lower on radusergroup (lower(UserName));
   ```

3. Importar nueva base de datos:

   ```sh
   psql -U radius radius < /etc/freeradius/3.0/mods-config/sql/main/postgresql/schema.sql
   ```

4. Modificar variables en **_/etc/freeradius/3.0/mods-available/sql_**:

   ```conf
   authcheck_table1 = "usuarios1"
   authcheck_table2 = "usuarios2"
   ```

5. Modificar consultas en **_/etc/freeradius/3.0/mods-config/sql/main/postgresql/queries.conf_**:

   ```conf
   authorize_check_query = "\
       SELECT id, UserName, Attribute, Value, Op \
       FROM ${authcheck_table1} \
       WHERE LOWER(Username) = LOWER('%{SQL-User-Name}') \
       UNION ALL \
       SELECT id, UserName, Attribute, Value, Op \
       FROM ${authcheck_table2} \
       WHERE LOWER(Username) = LOWER('%{SQL-User-Name}') \
       ORDER BY id"

   group_membership_query = "\
       SELECT GroupName \
       FROM ${usergroup_table} \
       WHERE LOWER(UserName) = LOWER('%{SQL-User-Name}') \
       ORDER BY priority"
   ```
