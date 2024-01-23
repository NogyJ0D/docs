# Certbot

---

## Contenido

- [Certbot](#certbot)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Certbot en Debian y Ubuntu](#instalar-certbot-en-debian-y-ubuntu)
  - [Extras](#extras)
    - [Generar certificados](#generar-certificados)
      - [Self Signed](#self-signed)
      - [Nginx](#nginx)

---

## Documentación

- [Web](https://certbot.eff.org)

---

## Instalación

### Instalar Certbot en Debian y Ubuntu

1. [Instalar snap](../sistemas_operativos/linux/gestor_paquetes/snap.md#instalar-snap-en-debian).

2. Instalar Certbot:

    ```sh
    snap install --classic certbot
    ln -s /snap/bin/certbot /usr/bin/certbot
    snap set certbot trust-plugin-with-root=ok
    snap install certbot-dns-<PLUGIN> # google, cloudflare
    ```

3. Probar renovación:

    ```sh
    certbot renew --dry-run
    ```

---

## Extras

### Generar certificados

#### Self Signed

1. Instalar openssl.

2. Crear certificado:

    ```sh
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/cert-selfsigned.key -out /etc/ssl/certs/cert-selfsigned.crt
    ```

#### Nginx

```sh
certbot certonly --nginx -d example.com -d www.example.com
```
