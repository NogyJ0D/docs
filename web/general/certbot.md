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
      - [Wildcard con Cloudflare](#wildcard-con-cloudflare)
      - [Nginx](#nginx)

---

## Documentación

- [Web](https://certbot.eff.org)

---

## Instalación

### Instalar Certbot en Debian y Ubuntu

- Con apt

  ```sh
  apt install certbot
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

#### Wildcard con Cloudflare

1. Instalar el paquete **python3-certbot-dns-cloudflare**.
2. Crear Token API en Cloudflare para el dominio con _permiso para edición_.
3. Crear archivo **_/etc/letsencrypt/cloudflare.ini_**:

   ```ini
   dns_cloudflare_api_token = <Token API>
   ```

4. Crear certificado con certbot:

   ```sh
   certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini --dns-cloudflare-propagation-seconds 60 -d "example.com" -d "*.example.com"
   # Para probar la renovación: certbot renew --dry-run
   ```

#### Nginx

1. Instalar el paquete **python3-certbot-nginx**.
2. Crear dominio/subdominio.
3. Crear certificado con certbot:

   ```sh
   certbot certonly --nginx --agree-tos -d example.com
   ```
