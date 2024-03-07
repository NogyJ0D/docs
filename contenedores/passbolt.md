# Passbolt

- Gestor de contraseñas

## Instalación

1. Contenido del stack:

    ```yml
    version: "3.9"
    services:
    passbolt:
        image: passbolt/passbolt:latest-ce
        restart: unless-stopped
        environment:
        APP_FULL_BASE_URL: https://<host>:<puerto seguro>
        DATASOURCES_DEFAULT_HOST: "<host db>"
        DATASOURCES_DEFAULT_USERNAME: "passbolt"
        DATASOURCES_DEFAULT_PASSWORD: "<contraseña db>%"
        DATASOURCES_DEFAULT_DATABASE: "passbolt"
        EMAIL_DEFAULT_FROM_NAME: "<quien envía el mail>"
        EMAIL_DEFAULT_FROM: "<email>"
        EMAIL_TRANSPORT_DEFAULT_HOST: "mail.x.ar"
        EMAIL_TRANSPORT_DEFAULT_PORT: 465
        EMAIL_TRANSPORT_DEFAULT_USERNAME: "<mail>"
        EMAIL_TRANSPORT_DEFAULT_PASSWORD: "<contraseña mail>"
        EMAIL_TRANSPORT_DEFAULT_TLS: "yes"
        volumes:
        - gpg_volume:/etc/passbolt/gpg
        - jwt_volume:/etc/passbolt/jwt
        - /etc/timezone:/etc/timezone:ro
        - /etc/localtime:/etc/localtime:ro
        command:
        [
            "/usr/bin/wait-for.sh",
            "-t",
            "0",
            "192.168.185.15:3306",
            "--",
            "/docker-entrypoint.sh",
        ]
        ports:
        - 3003:80
        - 3004:443
        #Alternatively for non-root images:
        # - 80:8080
        # - 443:4433

    volumes:
      gpg_volume:
      jwt_volume:
    ```

2. Crear usuarios:

    ```sh
    su -s /bin/bash -c "/usr/share/php/passbolt/bin/cake passbolt register_user -u {email} -f {nombre} -l {apellido} -r admin" www-data
    ```

## Extras

### Verificar configuración

```sh
sudo -u www-data bin/cake passbolt healthcheck
```