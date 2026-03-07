# Nginx

- [Nginx](#nginx)
  - [Documentación](#documentación)
    - [¿Qué es?](#qué-es)
  - [Extras](#extras)
    - [Configuración básica](#configuración-básica)
    - [Migrar nginx a otro servidor](#migrar-nginx-a-otro-servidor)
  - [Hardening](#hardening)

## Documentación

### [¿Qué es?](https://nginx.org/en/)

- Servidor web HTTP:
  - Sirve archivos estaticos y páginas web.
  - Proxy reverso.
  - [Administra servidores virtuales](https://nginx.org/en/docs/http/request_processing.html).
  - [Genera logs sobre los sitios](https://nginx.org/en/docs/http/ngx_http_log_module.html#log_format).
- Balanceador de carga.
- Proxy TCP/UDP.
- Proxy de emails.

## Extras

### Configuración básica

- Para php:

  ```nginx
  server {
    listen      80;
    server_name example.org www.example.org;
    root        /data/www;

    location / {
      index   index.html index.php;
    }

    location ~* \.(gif|jpg|png)$ {
      expires 30d;
    }

    location ~ \.php$ {
      fastcgi_pass  localhost:9000;
      fastcgi_param SCRIPT_FILENAME
                    $document_root$fastcgi_script_name;
      include       fastcgi_params;
    }
  }
  ```

### Migrar nginx a otro servidor

1. Hacer backups:

   ```sh
   zip -ry nginx.zip /etc/nginx/nginx.conf /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/modules-enabled
   zip -ry nginx_mods.zip /usr/share/nginx/modules /usr/share/nginx/modules-available
   zip -ry certs.zip /etc/letsencrypt
   # Revisar /var
   ```

2. Instalar nginx.

3. [Instalar certbot](../certbot.md#instalación).

4. Mover los backups:

   ```sh
   scp nginx_bkp.tar.gz {usuario}@{ip}:/{ruta_destino}
   scp letsencrypt_bkp.tar.gz {usuario}@{ip}:/{ruta_destino}
   ```

5. Hacer un dry-run de certbot.

## Hardening

- Debian 13
- Instalado como paquete
- Referencia: [CIS NGINX BENCHMARK v3.0.0](https://www.cisecurity.org/benchmark/nginx)

1. Instalación:
   1. Asegurarse que está instalado: `nginx -V`.
   2. 🔁 Asegurarse que está actualizado: `apt upgrade nginx`.
2. Configuración básica:
   1. Seguridad de la cuenta:
      1. Asegurarse de que corre bajo un usuario sin privilegios:

         ```sh
         nginx -T 2>/dev/null | grep -i "^user" # Devuelve el usuario que usa nginx para los procesos.
         id USUARIO # Ver los grupos del usuario usado, no debe tener UID 0 ni pertenecer a root, wheel o sudo.
         sudo -l -U USUARIO # Ver si puede acceder con sudo, no debería.
         ```

         - En Debian corre bajo www-data, que pasa el requerimiento. Si no hay que crear otro usuario:

           ```sh
           useradd -r -d /var/cache/nginx -s /sbin/nologin nginx
           # Modificar user en /etc/nginx/nginx.conf para que use el usuario nginx
           usermod -s /sbin/nologin nginx # Deshabilitar el login
           usermod -L nginx
           ```

      2. Asegurarse de que el usuario no puede loguearse:

         ```sh
         passwd -S www-data # Debería devolver una L de locked
         passwd -l www-data # Si no devuelve
         ```

      3. Asegurarse de que el usuario no tenga una shell:

         ```sh
         getent passwd www-data # Debe devolver como shell /sbin/nologin, /bin/nologin o /bin/false
         usermod -s /sbin/nologin www-data # Si no devuelve esos valores
         ```

   2. Permisos y ownership:
      1. Asegurarse de que las carpetas de configuración pertenezcan a root:

         ```sh
         ls -l /etc/nginx
         chown -R root:root /etc/nginx
         ```

      2. 🔁 Asegurarse de que las carpetas y archivos de nginx están restringidos:

         ```sh
         find /etc/nginx -type d -exec stat -Lc "%n %a" {} + # Ver permisos de carpetas. Debe devolver 750 o 700 (más restringido)
         find /etc/nginx -type f -exec stat -Lc "%n %a" {} + # Ver permisos de archivos. Debe devolver 640 o 600 (más restringido)

         find /etc/nginx -type d -exec chmod 750 {} + # Restringir carpetas
         find /etc/nginx -type f -exec chmod 640 {} + # Restringir archivos
         ```

      3. Asegurarse de que el archivo de PID está asegurado:

         ```sh
         nginx -V # Ver cuál es el archivo en --pid-path
         stat -Lc "%U:%G %a" /run/nginx.pid # Ver permisos del archivo. Debe devolver root:root y 644

         chown root:root /run/nginx.pid
         chmod 644 /run/nginx.pid
         ```

   3. Configuración de red:
      1. 🔁 Asegurarse de que no se use otro puerto que **80** y **443**:

         ```sh
         nginx -T 2>/dev/null | grep -r "listen"
         netstat -tulpen | grep -i nginx
         # De devolver otro puerto, revisar los listen en los archivos de configuración
         ```

      2. 🔁 Asegurarse de que se rechacen los dominios inválidos:
         - Mal configurado puede devolver un dominio no expuesto o privado que no queremos que se acceda.

         ```sh
         nginx -T 2>/dev/null | grep -Ei "listen.*default_server|ssl_reject_handshake" # Verificar la existencia de un default_server
         curl -k -v https://127.0.0.1 -H 'Host: invalid.example.com'
         curl -k -v http://127.0.0.1 -H 'Host: invalid.example.com'
         # Deben devolver el contenido del bloque con default_server y no otro dominio
         ```

         - **Configurar un server para respuesta**:

           ```nginx
           server {
             # Listen on standard ports for IPv4 and IPv6
             listen 80 default_server;
             listen [::]:80 default_server;

             # Listen for HTTPS (TCP) and QUIC (UDP)
             listen 443 ssl default_server;
             listen [::]:443 ssl default_server;
             listen 443 quic default_server;
             listen [::]:443 quic default_server;

             # Reject SSL Handshake for unknown domains (Prevents cert leakage)
             ssl_reject_handshake on;

             # Catch-all name
             server_name _;

             # Close connection without response (Non-standard code 444)
             return 444;
           }
           ```

      3. 🔁 Asegurarse de que el valor _keepalive_timeout_ esté entre 10 y 1:
         - Determina el tiempo que duran las conexiones, evita que ataquen el servidor con múltiples conexiones persistentes.

         ```sh
         grep -ir keepalive_timeout /etc/nginx
         # Si devuelve un keepallive 0 y mayor a 10, editarlo a 10
         ```

      4. 🔁 Asegurarse de que el valor _send_timeout_ esté entre 10 y 1:
         - Determina el tiempo que duran las operaciones de escritura, evita que frenen al servidor con subidas infinitas.

         ```sh
         grep -ir send_timeout /etc/nginx
         # Si devuelve un keepallive 0 y mayor a 10, editarlo a 10
         ```

   4. Divulgación de información:
      1. Asegurare de que _server_tokens_ esté apagado:
         - La directiva _server_tokens_ habilita si se muestra la versión de nginx como cabecera. Si en la versión de nuestro nginx hay una vulnerabilidad explotable, el atacante puede aprovecharla fácilmente.

         ```sh
         grep -ir server_tokens /etc/nginx/
         curl -I 127.0.0.1 | grep -i server
         # Si está "on" o devuelve la versión, pasarlo a "off"
         ```

      2. 🔁 Asegurarse de que las páginas de error e index no hagan referencia a nginx:

         ```sh
         nginx -T 2>/dev/null | grep -i "error_page"
         curl -k http://127.0.0.1/non-existent-page | grep -i "nginx" # No debe devolver "nginx"

         mkdir /var/www/html/errors # Crear carpeta para errores personalizados
         echo "<p>404</p>" > /var/www/html/errors/404.html
         echo "<p>50x</p>" > /var/www/html/errors/50x.html
         ```

         - Agregar a los sitios:

           ```nginx
           error_page 404 /404.html;
           error_page 500 502 503 504 /50x.html;
           location = /404.html {
             root /var/www/html/errors;
             internal;
           }
           location = /50x.html {
             root /var/www/html/errors;
             internal;
           }
           ```

      3. 🔁 Asegurarse de que no se muestren archivos ocultos:
         - Agregar a los sitios:

           ```nginx
           # Allow Let's Encrypt validation (must be before the deny rule)
           location ^~ /.well-known/acme-challenge/ {
             allow all;
             default_type "text/plain";
           }
           # Deny access to all other hidden files
           location ~ /\. {
             deny all;
             return 404;
           }
           ```

      4. 🔁 Asegurarse de que no se envien cabeceras con información:

         ```sh
         nginx -T 2>/dev/null | grep -Ei "(proxy|fastcgi)_hide_header"
         curl -k -I http://127.0.0.1 | grep -Ei "^(Server|X-Powered-By)"

         apt install libnginx-mod-http-headers-more-filter # Instalar módulo para eliminar cabeceras
         ```

         - Agregar en el bloque http:

           ```nginx
           more_clear_headers Server;
           more_clear_headers X-Powered-By;
           ```

3. Logging:
   1. Habilitar logging detallado. Modificar `/etc/nginx/nginx.conf`:

      ```nginx
      error_log /var/log/nginx/error.log notice; # Agregar fuera del bloque http

      http {
        log_format main_access_json escape=json '{' # Agregar dentro del bloque http
        '"timestamp": "$time_iso8601",'
        '"remote_addr": "$remote_addr",'
        '"remote_user": "$remote_user",'
        '"server_name": "$server_name",'
        '"request_method": "$request_method",'
        '"request_uri": "$request_uri",'
        '"status": $status,'
        '"body_bytes_sent": $body_bytes_sent,'
        '"http_referer": "$http_referer",'
        '"http_user_agent": "$http_user_agent",'
        '"x_forwarded_for": "$http_x_forwarded_for",'
        '"request_id": "$request_id"'
        '}';

        access_log /var/log/nginx/access.json main_access_json; # Agregar en cada server también
      }
      ```

   2. 🔁 Pasar ip del origen por el proxy reverso:

      ```nginx
      location / { # Agregar en cada server
        proxy_pass <protocol>://example_backend_application;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
      }
      ```

4. Encriptación:
   1. 🔁 Asegurarse de que http redirige a https en cada server:

      ```nginx
      server {
        listen 80;
        server_name servidor;
        return 301 https://$host$request_uri;
      }
      ```

   2. 🔁 Asegurarse de deshabilitar protocolos inseguros en cada server:

      ```sh
      grep -ir ssl_protocol /etc/nginx # Debe devolver TLSv1.2 TLSv1.3, no 1.0 o 1.1
      ```

   3. 🔁 Asegurarse de habilitar HSTS en cada server:

      ```nginx
      # 2 años y preload
      add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
      ```
