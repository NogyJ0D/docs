# Nginx

## Contenido

- [Nginx](#nginx)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
    - [¿Qué es?](#qué-es)
  - [Extras](#extras)
    - [Configuración básica](#configuración-básica)
    - [Migrar nginx a otro servidor](#migrar-nginx-a-otro-servidor)

---

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

---

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
