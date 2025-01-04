# Code server

## Compose

```yaml
services:
  code-server:
    image: lscr.io/linuxserver/code-server:latest
    container_name: code-server
    restart: unless-stopped
    ports:
      - 127.0.0.1:3000:8443
    volumes:
      - /home/usuario/code-server-config:/config
      - /home/usuario/docs:/docs # Ejemplo repositorio
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/Argentina/Buenos_Aires
      - PASSWORD=contraseña
      - PROXY_DOMAIN=wiki.example.com
      - DEFAULT_WORKSPACE=/config/workspace
```
