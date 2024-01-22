# Nginx
-------

## Contenido
- [Nginx](#nginx)
  - [Contenido](#contenido)
  - [Instalación](#instalación)
    - [Instalar Nginx en Debian](#instalar-nginx-en-debian)
    - [Instalar nginx en Alpine](#instalar-nginx-en-alpine)
  - [Extras](#extras)
    - [Migrar nginx a otro servidor:](#migrar-nginx-a-otro-servidor)

--------------
## Instalación

### Instalar Nginx en Debian

```sh
apt install nginx

systemctl enable --now nginx
```

### Instalar nginx en Alpine

```sh
apk add nginx

rc-update add nginx boot
rc-service start nginx
```

---------
## Extras

### Migrar nginx a otro servidor:

1. Hacer backups:
```sh
zip -ry nginx.zip /etc/nginx/nginx.conf /etc/nginx/sites-available /etc/nginx/sites-enabled /etc/nginx/modules-enabled
zip -ry nginx_mods.zip /usr/share/nginx/modules /usr/share/nginx/modules-available
zip -ry certs.zip /etc/letsencrypt
# Revisar /var
```

1. [Instalar nginx](#instalación).

2. [Instalar certbot](../certbot.md#instalación).

3. Mover los backups:
```sh
scp nginx_bkp.tar.gz {usuario}@{ip}:/{ruta_destino}
scp letsencrypt_bkp.tar.gz {usuario}@{ip}:/{ruta_destino}
```

1. Hacer un dry-run de certbot.