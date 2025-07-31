# Excalidraw

- [Excalidraw](#excalidraw)
  - [Instalar Excalidraw](#instalar-excalidraw)
    - [Instalar en Debian como docker](#instalar-en-debian-como-docker)

---

## Instalar Excalidraw

### Instalar en Debian como docker

- docker-compose.yml:

  ```yml
  networks:
    excalidraw:
      name: excalidraw
      driver: bridge

  services:
    excalidraw:
      image: excalidraw/excalidraw:latest
      container_name: excalidraw
      restart: unless-stopped
      networks:
        - excalidraw
      ports:
        - 127.0.0.1:x:80
      environment:
        - NODE_ENV=production
  ```
