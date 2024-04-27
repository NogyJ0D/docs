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
      - [Nginx](#nginx)

---

## Documentación

- [Web](https://certbot.eff.org)

---

## Instalación

### Instalar Certbot en Debian y Ubuntu

- Con apt

  ```sh
  apt install certbot python3-certbot-nginx
  ```

- Con snap

  1. [Instalar snap](../sistemas_operativos/linux/gestor_paquetes/snap.md#instalar-snap-en-debian).

  2. Instalar Certbot:

      ```sh
      snap install --classic certbot
      ln -s /snap/bin/certbot /usr/bin/certbot
      snap set certbot trust-plugin-with-root=ok
      snap install certbot-dns-<PLUGIN> # google, cloudflare
      ```

- Probar renovación:

  ```sh
  certbot renew --dry-run
  ```

---

## Extras

### Generar certificados

#### Nginx

```sh
certbot --nginx -d example.com -d www.example.com
```
