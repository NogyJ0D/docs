# Squid

Proxy y cache

## Instalar Squid en Debian 13

1. Instalar squid: `apt install squid`
2. Configurar squid:

   ```sh
   mv /etc/squid/squid.conf /etc/squid/squid.conf.bak
   egrep -v "^#|^$" /etc/squid/squid.conf.bak > /etc/squid/squid.conf
   editor /etc/squid/squid.conf # Generar archivo limpio sin los miles de comentarios
   ```

   - El archivo procesa las directivas secuencialmente, de arriba a abajo.
   - Patrón común:
     1. Definir ACLs (Access Control Lists) - grupos de IPs
     2. Setear reglas de http_access - permitir y denegar basado en ACLs
     3. Configurar puertos y cache
     4. Configurar logging y rendimiento

   ```conf
   # Ir cerca de la línea 1400, donde están las reglas básicas

   # Agregar la subred en uso
   acl localnet src 192.168.0.0/24

   # Definir los puertos seguros, los que pueden ser usados. Los que no están en la lista son considerados peligrosos.
   acl SSL_ports port 443
   acl Safe_ports port 80          # http
   acl Safe_ports port 443         # https
   acl Safe_ports port 1025-65535  # unregistered ports

   # Deshabilitar la funcionalidad de cache de Squid
   cache deny all

   # Restringir acceso
   http_access deny !Safe_ports # Denegar el acceso si el puerto de destino NO es uno de la lista
   http_access deny CONNECT !SSL_ports # Denegar las conexiones tipo túnel si NO van dirigidas al 443.
   http_access allow localhost # Permitir que el servidor use el proxy
   http_access allow localnet # Permitir que las máquinas de la subred naveges a través del proxy
   http_access deny all # Denegar todo lo demás

   # Configuración del servicio
   http_port 3128 # Puerto por defecto de squid
   coredump_dir /var/spool/squid # Dónde guarda los reportes por si falla
   ```

3. Reiniciar squid:

   ```sh
   squid -k parse
   systemctl restart squid
   ```

## Extras

### Restringir Sitios con Archivo

- Prohibir una computadora a una lista de sitios y limitar todas a solo los sitios permitidos.

1. Crear archivo `/etc/squid/prohibidos`.
2. Agregar los sitios prohibidos:

   ```text
   .juegos.com
   .bloqueado.com
   ```

3. Crear archivo `/etc/squid/permitidos`.
4. Agregar los sitios permitidos para todos:

   ```text
   .google.com
   .noticias.com
   ```

5. En `squid.conf`:

   ```conf
   acl localnet src 192.168.0.0/24
   acl pc_prohibida src 192.168.0.34 # Agregar la IP de la computadora

   acl sitios_prohibidos dstdomain "/etc/squid/prohibidos" # Agregar grupo de dominios por archivo
   acl sitios_permitidos dstdomain "/etc/squid/permitidos"

   # acl de puertos

   http_access deny !Safe_ports
   http_access deny CONNECT !SSL_ports

   http_access deny pc_prohibida sitios_prohibidos # Prohibir el acceso a los sitios a esa computadora

   http_access allow localnet sitios_permitidos

   http_access deny localnet # Prohibir todos los sitios que no sean permitidos
   http_access deny all
   ```

### Requerir Proxy en las Computadoras

- En el router:
  - Permitir que la ip del Squid salga con los puertos 80 y 443.
  - Denegar los puertos 80 y 443 para todos.
- Después hay que configurar en cada máquina el proxy con el puerto 3128.
- Como alternativa, se puede usar WPAD (Web Proxy Auto-Discovery):
  - Crear un archivo de texto llamado `wpad.dat` que contiene la ip del proxy.
  - Configurar el servidor DHCP y agregar la opción 252 con la ruta de ese archivo.
  - Cuando las computadoras se conecten, van a buscar el archivo y se configuran el proxy solas.
