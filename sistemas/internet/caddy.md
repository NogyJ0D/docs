# Caddy

- Proxy reverso simplificado..
- Gestiona los certificados automáticamente.
- Agrega las cabeceras de seguridad solo.

## Instalar Caddy en Debian

```sh
apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
chmod o+r /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install caddy
mkdir /var/log/caddy
chmod g+s /var/log/caddy
editor /etc/caddy/Caddyfile # Único archivo que hace falta modificar
```

- Para reiniciar después de modificar el archivo:

  ```sh
  caddy validate --config /etc/caddy/Caddyfile # Revisar archivo, opcional
  caddy fmt --overwrite # Formatear, opcional
  systemctl reload caddy
  ```

## Ejemplos de Configuración

- Función reutilizable (muy recomendable):

  ```Caddyfile
  # Al principio del archivo
  (config_estandar) {
    encode zstd gzip # Comprimir peticiones

    log {
      output file /var/log/caddy/{args[0]}.log { # Archivo de log
        mode 0660
      }
    }

    header {
      Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"

      X-Frame-Options "DENY"
      X-Content-Type-Options "nosniff"

      -Server
      -X-Powered-By
    }
  }

  # Utilizarlo en algún sitio:
  import config_estandar oficina
  ```

- Denegar acceso si no hay un dominio válido:
  - Mejor al final de todo.

  ```Caddyfile
  :80 {
    respond "Acceso no autorizado o sitio no configurado" 404
  }

  :443 {
    tls internal
    respond "Acceso no autorizado o sitio no configurado" 404
  }
  ```

- Servir HTML:

  ```Caddyfile
  oficina.dominio.com {
    header Content-Type "text/html; charset=utf-8"

    respond `
      <html>
        <head><title>Sitio con Caddy</title></head>
        <body>
          <h1>Sitio con Caddy</h1>
        </body>
      </html>
    `

    import config_estandar oficina
  }
  ```

- Servir archivos:

  ```Caddyfile
  archivos.dominio.com {
    root * /var/www/html/sitio

    handle {
      try_files {path} {path}/ /index.html
      file_server
    }

    import config_estandar archivos
  }
  ```

- Proxy reverso:
  - No hace falta nada más que esto:

    ```Caddyfile
    soporte.dominio.com {
      reverse_proxy http://192.168.0.2:8080
      import config_estandar soporte
    }
    ```

  - Cosas que se pueden agregar:

    ```Caddyfile
    soporte.dominio.com {
      reverse_proxy http://192.168.0.2:8080 {
        transport http {
          tls_insecure_skip_verify
        }

        header_up X-Forwarded-Port {server_port}
        header_up X-Forwarded-Ssl "on"
      }

      request_body {
        max_size 265mb
      }

      header {
        Referrer-Policy "no-referrer"
        X-Frame-Options "SAMEORIGIN"
        X-Permitted-Cross-Domain-Policies "none"
        X-Robot-Tag "noindex, nofollow"
        X-XSS-Protection "1; mode=block"
      }

      import config_estandar soporte
    }
    ```

  - Agregar location para servir un archivo:

    ```Caddyfile
    soporte.dominio.com {
      handle /archivos* {
        root * /var/www/html
        file_server
      }

      handle {
        reverse_proxy http://192.168.0.2:8080
      }

      import config_estandar soporte
    }
    ```

  - Agregar basic auth a una location:

    ```Caddyfile
    soporte.dominio.com {
      handle /archivos* {
        basic_auth {
          admin $2a$14$xxxxxxxxxxxxxxxx... # Usuario admin y contraseña hasheada
        }

        root * /var/www/html
        file_server
      }

      handle {
        reverse_proxy http://192.168.0.2:8080
      }

      import config_estandar soporte
    }
    ```

    - Crear la contraseña con: `caddy hash-password --plaintext 'Contraseña'`

## Extras

### Agregar Color en Vim

```sh
mkdir -p ~/.vim/pack/plugins/start
git clone https://github.com/isobit/vim-caddyfile.git ~/.vim/pack/plugins/start/vim-caddyfile
vim ~/.vim/rc
```

```vimrc
syntax on
filetype plugin indent on
```
