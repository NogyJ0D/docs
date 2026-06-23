# DBA - Database Administrator

## Estudio

### 1. Arquitectura Interna

- Cómo escribe Postgres en el disco.
  - Proceso de memoria (shared_buffers)
  - Archivo WAL (Write-Ahead Logging)
  - MVCC (Control de concurrencia multiversión)
- Práctica:
  - Investigar VACUUM y ANALYZE
  - Forzar actualizaciones masivas en una tabla y observar cómo quedan las filas bloat y cómo el Vacuum las limpia

### 2. Optimización y Performance (Tuning)

- Tunear Postgres para producción.
  - Configuración del servidor:
    - Modificar el archivo postgresql.conf
    - PGTune para entender qué valores asignar a max_connections, shared_buffers, effective_cache_size y work_mem según la RAM de la VM.
  - Optimización de queries:
    - Leer cómo el motor ejecuta una consulta.
    - Estudiar EXPLAIN ANALYZE.
    - Aprender a identificar cuándo Postgres hace un Sequential Scan vs Index Scan.
    - Aprender a crear índices compuestos o parciales.

### 3. Seguridad y Accesos Avanzados

- El archivo pg_hba.conf: firewall interno de Postgres.
  - Configurar qué IPs o subredes pueden conectarse y bajo qué métodos de autenticación (md5, scram-sha-256, etc)
- Roles y privilegios:
  - Herencia de roles.
  - Creación de esquemas y asignación de permisos específicos de solo lectura para usuarios de analítica.

### 4. Monitoreo y Diagnóstico

- Vistas Estadísticas:
  - Extensión pg_stat_statements para ver las queries más lentas.
- Herramientas visuales y alertas:
  - pgAdmin, DBeaver.
  - Prometheus + Grafana con postgres_exporter.

### 5. Respaldo, Réplica y Alta Disponibilidad

- Backups lógicos vs físicos:
  - pg_dump y pg_restore (lógicos).
  - pg_basebackup (físicos).
- Replicación Streaming (Master-Slave):
  - Un motor configurado como primario (lectura/escritura) y otro como réplica (solo lectura).
  - Replicación asíncrona a tra´ves de los WALs.

## Práctica

### Compose para Pruebas

```yml
services:
  postgres_lab:
    image: postgres:16-alpine
    container_name: postgres_lab
    restart: unless-stopped
    ports:
      - '5432:5432'
    environment:
      POSTGRES_USER: lab_user
      POSTGRES_PASSWORD: contraseña
      POSTGRES_DB: lab_db
    volumes:
      - ./postgres_data:/var/lib/postgresql/data
```

- Crear la carpeta "ejemplos_bd" y cargar dumps:

  ```sh
  # https://github.com/neondatabase/postgres-sample-dbs
  wget https://raw.githubusercontent.com/neondatabase/postgres-sample-dbs/main/chinook.sql
  wget https://raw.githubusercontent.com/neondatabase/postgres-sample-dbs/main/periodic_table.sql

  cat ./ejemplos_bd/chinook.sql | docker exec -i postgres_lab psql -U lab_user lab_db
  ```

### Teoría

#### [Consumo de Recursos](https://www.postgresql.org/docs/18/runtime-config-resource.html)

- `shared_buffers` (integer): _es la cantidad de memoria que usa el servidor para los buffers comparidos de memoria_.
  - El valor por defecto es 128MB, pero puede ser menos si el kernel no lo soporta.
  - El valor debe ser al menos 128KB.
  - Si no se especifica la unidad, esta se entenderá como bloques/blocks (BLCKSZ bytes, 8kB).
  - **Modificar el valor requiere reiniciar el servidor**.
  - Si el servidor tiene **al menos 1GB de RAM**, se recomienda un **valor inicial de al menos el 25% de la memoria total**.
    - **No se recomienda poner más del 40% de la memoria total**, ya que PG también depende de la caché del servidor y reservarle tanta memoria puede ser peor.
  - Valores altos en `shared_buffers` usualmente requieren un **incremento similar en `max_wal_size`**.

#### [Write Ahead Log](https://www.postgresql.org/docs/18/runtime-config-wal.html)

- Cada vez que se ejecuta una transacción (INSERT, UPDATE o DELETE), primero se registran los valores en un archivo WAL, asegurandosé de que si se apaga el servidor, el dato sigue ahí incluso antes de terminar el INSERT.
- Los archivos WAL se guardan en `pg_wal/`.
  - Cada archivo, llamado segmento, pesa 16MB por defecto.
  - Cuando un segmento se llena, PG crea uno nuevo y escribe en este.
  - Cuando un Checkpoint (escribir cambios de la memoria a los archivos principales) se completa, PG sabe que esos datos están asegurados, **por lo que elimina los segmentos viejos**.
- Es importante conocer el _WAL Archiving_:
  - _WAL Archiving_ es el proceso donde, en lugar de eliminar directamente los segmentos viejos, estos se copian en otro lado.

</br>

- `wal_level` (enum): _determina cuánta información se escribe en el WAL_.
  - El valor por defecto es `replica`, que escribe suficiente información para soportar archivado y replicación.
  - El valor `minimal` elimina todo el logging excepto la información requerida para recuperarse de un crasheo o apagado. No escribe información de transacciones.
    - Suele hacer más rápido el servidor, **a costa de perder información en caso de errores**.
    - Si el valor de `max_wal_senders` es distinto a cero con `minimal`, el servidor no va a iniciar.
  - El valor `logical` agrega información necesaria para soportar decodificación lógica.
    - Escribe la misma información que con `replica`, además de su información.
  - **Modificar el valor requiere reiniciar el servidor**.
  - Acepta también los valores `archive` y `hot_standby`, pero son deprecados y mapean a `replica`.
- `fsync` (boolean): _determina si el servidor se asegura de que las actualizaciones se escriban fisicamente en el disco, usando `fsync()` o similar (ver `wal_sync_method`)_.
  - Desactivarlo puede mejorar el rendimiento, a costa de generar datos corruptos irrecuperables en el caso de crasheo o apagado.
  - Solo se recomienda desactivarlo si se puede recrear toda la base de datos con datos externos. Si se desactiva, desactivar también `full_page_writes`.
- `wal_sync_method` (enum): _el método usado para escribir el WAL en el disco_.
  - Si `fsync` está apagado (`false`), este parámetro no hace nada.
  - Los valores posibles son:
    - `open_datasync`: escribe archivos WAL con `open()` y `O_DSYNC`.
    - `fdatasync`: llama a `fdatasync()` en cada commit.
    - `fsync`: llama a `fsync()` en cada commit.
    - `fsync_writethrough`: llama a `fsync()` en cada commit, forzando write-through de cualquier disk write cache.
    - `open_sync`: escribe archivos WAL con `open()` y `O_SYNC`.
  - El valor por defecto es el primero de esa lista que soporte el sistema, excepto por `fdatasync` que es el default en Linux y FreeBSD. El default no es necesariamente el ideal.
- `wal_compression` (enum): _habilita la compresión del WAL_.
  - El valor por defecto es `off`.
  - Los valores aceptados son:
    - `off`.
    - `pglz`.
    - `lz4` (si PG se compiló con `--with-lz4`).
    - `zstd` (si PG se compiló con `--with-zstd`).
  - Habilitar la compresión puede reducir el volumen de WAL, a costa de aumentar el uso de procesador.

</br>

- [Archivado](https://www.postgresql.org/docs/18/runtime-config-wal.html#RUNTIME-CONFIG-WAL-ARCHIVING):
  - `archive_mode` (enum): _si está activado, cuando se completa un checkpoint se almacenan los segmentos en otro lugar en lugar de borrarlos_.
    - Los valores son:
      - `off` (valor por defecto).
      - `on`.
      - `always`: todos los segmentos recuperados del archivo o streaming replication van a ser archivados otra vez.
    - **No puede sec archivado cuando `wal_level` es igual a `minimal`**.
  - `archive_command` (string): _es el comando que se ejecuta para archivar al finalizar un checkpoint_.
    - Solo se usa si `archive_mode` está habilitado y si `archive_library` es un string vacío.
    - Dentro del string: la cadena `%p` es reemplazada por la ruta (relativa) del segmento a archivar, y la cadena `%f` es reemplazada por solamente el nombre del segmento. EJ: `'cp %p /var/lib/postgresql/archive/%f'`.
    - Tener en cuenta que es lento y usa un solo hilo, se pueden usar alternativas modernas como "pgBackRest".
    - Si el directorio de segmentos no se puede limpiar rápidamente, PG deja de escribir datos y la aplicación se cae.

- [Recuperación](https://www.postgresql.org/docs/18/runtime-config-wal.html#RUNTIME-CONFIG-WAL-ARCHIVE-RECOVERY):
  - La recuperación de archivos/segmentos se produce durante el modo "standby". El modo "standby" se activa creando el archivo `standby.signal` en el directorio de data.
  - La idea de la recuperación es: si se eliminaron datos un día viernes a las 06:02:20 horas (milisegundo de la ejecución del DELETE), se debe usar un backup completo del día jueves a última hora (o viernes primera hora) y hacer el restore de todos los archivos WAL correspondientes a ese bache de tiempo entre el full backup y la query.
  - `restore_command` (string): _el comando a ejecutar para recuperar archivos WAL archivados_.
    - Ejemplo: `'cp /mnt/server/archivedir/%f "%p"'`.
  - `recovery_target_time` (timestamp): _el tiempo donde va a dejarse de recuperar los archivos_.
    - Ejemplo: `2026-06-23 06:02:20` -> Se recupera todo **HASTA** las 06:02:19 inclusive.

#### [MVCC](https://www.postgresql.org/docs/current/mvcc-intro.html)

- Con un modelo de multiversión para acceso concurrente a datos (de varias personas), se muestra al cliente un estado previo de la base de datos, no lo más actual.
- Cuando se produce un cambio en una fila, el cambio se hace sobre una snapshot de esta y no la fila real, asegurando la integridad de los datos. Así, otras transacciones continúan viendo SU versión de la fila.

#### VACUUM

- Es una herramienta para eliminar datos innecesarios, recuperar espacio libre y actualizar las estadísticas del planificador de consultas.
  - Ejemplos: `VACUUM FULL tabla`, `VACUUM ANALYZE tabla`, ` VACUUM VERBOSE tabla`.

### Comandos

- Conectarse a la BD del contenedor:

  ```sh
  docker exec -it postgres_lab psql -U lab_user lab_db
  ```

### Pruebas

- Aumentar el valor de `shared_buffers`.
- Iniciar el servidor con `wal_level` = `minimal` y `max_wal_senders` <> `0`.
