# PGAdmin

---

## Contenido

- [PGAdmin](#pgadmin)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar PGAdmin como contenedor](#instalar-pgadmin-como-contenedor)
  - [Extras](#extras)
    - [Crear proxy reverso nginx](#crear-proxy-reverso-nginx)

---

## Documentación

---

## Instalación

### Instalar PGAdmin como contenedor

1. [Instalar Docker](../../Herramientas/docker.md#instalación).

2. Descargar la imagen:

    ```sh
    docker pull dpage/pgadmin4
    ```

3. Iniciar el contenedor:

   - Contenedor simple:

      ```sh
      docker run -p 80:80 \
      -e 'PGADMIN_DEFAULT_EMAIL=user@domain.com' \
      -e 'PGADMIN_DEFAULT_PASSWORD=SuperSecret' \
      -d dpage/pgadmin4
      ```

   - Composer:

      ```docker
      version: '3.3'
      services:
          run:
              ports:
                  - '80:80'
              environment:
                  - PGADMIN_DEFAULT_EMAIL=user@domain.com
                  - PGADMIN_DEFAULT_PASSWORD=SuperSecret
                  - PGADMIN_CONFIG_ENHANCED_COOKIE_PROTECTION=True
                  - 'PGADMIN_CONFIG_LOGIN_BANNER="Authorised users only!"'
                  - PGADMIN_CONFIG_CONSOLE_LOG_LEVEL=10
              restart: always
              image: run
      ```

---

## Extras

### Crear proxy reverso nginx

```nginx
server {
    listen 443;
    server_name _;

    ssl_certificate /etc/nginx/server.cert;
    ssl_certificate_key /etc/nginx/server.key;

    ssl on;
    ssl_session_cache builtin:1000 shared:SSL:10m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;

    location /pgadmin4/ {
        proxy_set_header X-Script-Name /pgadmin4;
        proxy_set_header X-Scheme $scheme;
        proxy_set_header Host $host;
        proxy_pass http://localhost:5050/;
        proxy_redirect off;
    }
}
```
