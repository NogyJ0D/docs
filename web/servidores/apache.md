# Apache

---

## Contenido

- [Apache](#apache)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Extras](#extras)
    - [Crear certificado auto firmado](#crear-certificado-auto-firmado)
    - [Reemplazar "https://url/carpeta" por "https://url"](#reemplazar-httpsurlcarpeta-por-httpsurl)

---

## Documentación

---

## Instalación

---

## Extras

### Crear certificado auto firmado

1. Instalar openssl.

2. Crear certificado:

    ```sh
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
    ```

3. Editar en ***/etc/apache2/sites-available/default-ssl.conf***:

    ```apache
    SSLEngine on
    SSLCertificateFile      /etc/ssl/certs/apache-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    ```

4. Ejecutar:

    ```sh
    a2enmod ssl
    a2ensite default-ssl
    systemctl restart apache2
    ```

### Reemplazar "<https://url/carpeta>" por "<https://url>"

- Editar en ***/etc/apache2/sites-available/default-ssl.conf*** o ***/etc/apache2/sites-available/000-default.conf***:

   ```apache
   DocumentRoot {ruta del index}
   ```

- Reiniciar servicio.
