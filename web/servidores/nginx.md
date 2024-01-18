# Nginx

## Contenido
- [Nginx](#nginx)
  - [Contenido](#contenido)
  - [Instalación](#instalación)
    - [Instalar Nginx en Debian](#instalar-nginx-en-debian)
    - [Instalar nginx en Alpine](#instalar-nginx-en-alpine)

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