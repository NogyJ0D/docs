# Koha

Sistema para catalogación de libros de una biblioteca.

---

- [Koha](#koha)
  - [Instalación en Debian](#instalación-en-debian)
    - [Pasos](#pasos)
  - [Extras](#extras)
    - [Activar email](#activar-email)
    - [Migrar base de datos de instalación vieja a nueva](#migrar-base-de-datos-de-instalación-vieja-a-nueva)
  - [Plugins](#plugins)
    - [Koha Carrousel](#koha-carrousel)

---

## Instalación en Debian

- +4GB Ram

### Pasos

1. Agregar claves de repositorio:

   ```sh
   apt update
   apt install apt-transport-https ca-certificates curl sudo
   mkdir -p --mode=0755 /etc/apt/keyrings
   curl -fsSL https://debian.koha-community.org/koha/gpg.asc -o /etc/apt/keyrings/koha.asc
   ```

2. Configurar repositorio:

   - Hay dos opciones:

     - Configurar por número de versión (RECOMENDADO, ej: 24.11)
     - Configurar por nombre (ej: stable)

   - Crear `/etc/apt/sources.list.d/koha.sources` con:

   ```sources
   Types: deb
   URIs: https://debian.koha-community.org/koha/
   Suites: 25.05
   Components: main
   Signed-By: /etc/apt/keyrings/koha.asc
   ```

   ```sh
   apt update
   ```

3. Instalar paquetes:

   ```sh
   apt install koha-common mariadb-server
   ```

4. Configurar Koha:

   1. Editar `/etc/koha/koha-sites.conf`:

      ```conf
      DOMAIN=".dominio.com"
      INTRAPORT="80" # Usar 8080 si no se quiere tener INTRASUFFIX o para acceder por IP
      INTRAPREFIX=""
      INTRASUFFIX="-intra" # El dominio del uso interno sería "libreria-intra.dominio.com"
      OPACPORT="80" # Es la librería de acceso público
      OPACPREFIX=""
      OPACSUFFIX=""

      ZEBRA_MARC_FORMAT="marc21"
      ZEBRA_LANGUAGE="es"
      ```

   2. Agregar la ip privada en `/etc/hosts`:

      ```plain
      127.0.0.1 localhost
      127.0.1.1 nombre-host

      192.168.0.2 libreria.dominio.com
      192.168.0.2 libreria-intra.dominio.com
      ```

5. Configurar apache:

   ```sh
   a2enmod rewrite cgi headers proxy_http
   systemctl restart apache2
   ```

   - Si se usa otro puerto para intranet, modificar `/etc/apache2/ports.conf`:

     ```conf
     Listen 80
     Listen 8080
     ```

   - Revisar si se quiere `/etc/apache2/sites-enabled/libreria.conf`.

6. Crear instancia de Koha:

   ```sh
   koha-create --create-db libreria
   koha-plack --enable libreria
   koha-plack --start libreria

   koha-language --install es-ES # Instalar traducción

   systemctl restart apache2
   ```

7. Acceder a la web de intranet (según la configuración elegida):
   1. Pide iniciar sesión, los datos están en `/etc/koha/sites/libreria/koha-conf.xml` o se ven con `koha-passwd libreria`.
   2. Seguir pasos para instalar.

## Extras

- Guías: <https://kohageek.blogspot.com/>

### Activar email

```sh
koha-email-enable libreria
```

### Migrar base de datos de instalación vieja a nueva

1. Hacer dump de la db vieja:

   ```sh
   mysqldump -u root -p koha_libreria | xz > koha_libreria.sql.xz
   ```

   - Copiarla al nuevo servidor.

2. Crear la instancia:

   ```sh
   koha-create --create-db libreria
   koha-plack --enable libreria
   koha-plack --start libreria

   systemctl restart apache2
   ```

3. Limpiar base de datos nueva:

   ```sh
   mysql -u root -p
   ```

   ```sql
   drop database koha_libreria;
   create database koha_libreria;
   quit;
   ```

4. Restaurar dump:

   ```sh
   xz -d koha_libreria.sql.xz
   mysql -u root -p koha_libreria < koha_libreria.sql
   systemctl restart memcached
   koha-upgrade-schema libreria
   koha-rebuild-zebra -v -f -libreria
   ```

5. Entrar a la web y revisar.

- Si se tenían plugins, habrá que limpiarlos de la base de datos o copiar los archivos del servidor original en `/var/lib/koha/libreria/plugins`:
  - Para limpiarlos ejecutar `truncate table plugin_data;` y `truncate table plugin_methods` en la base de datos.

## Plugins

- Para habilitarlos:
  - Cambiar `<enable_plugins>0</enable_plugins>` a `<enable_plugins>1</enable_plugins>` en `/etc/koha/sites/libreria/koha-conf.xml`
  - Cambiar `<plugins_restricted>1</plugins_restricted>` a `<plugins_restricted>0</plugins_restricted>` en `/etc/koha/sites/libreria/koha-conf.xml`
  - Reiniciar **apache2** y **koha-common**.
- Ir a Herramientas Administrativas > Complementos > Administra los complementos.
- Cargar.

### Koha Carrousel

- Fuente: <https://github.com/inLibro/koha-plugin-carrousel>

1. Descargar última release.
2. Cargar desde menú.
3. Configurar.
4. Ejecutar.
