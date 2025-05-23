# Docker

- [Docker](#docker)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Docker en Alpine](#instalar-docker-en-alpine)
  - [Comandos](#comandos)
  - [Configuración](#configuración)
  - [Extras](#extras)
    - [Mi entorno](#mi-entorno)

---

## Documentación

- [Página oficial](https://www.docker.com/)

---

## Instalación

### Instalar Docker en Alpine

```sh
apk add --update docker docker-cli-compose
rc-service docker start
rc-update add docker boot
```

---

## Comandos

- Ver log de contenedor:

  ```sh
  docker logs -f -t contenedor
  ```

- Levantar compose con prefijo:

  ```sh
  docker-compose -p prefijo up
  ```

---

## Configuración

- Configuración del daemon en **_/etc/docker/daemon.json_**:

- Cambiar pool de ips:

  ```json
  {
    "default-address-pools": [{ "base": "10.10.0.0/16", "size": 24 }]
  }
  ```

---

## Extras

### Mi entorno

Cosas que podría tener en una VM para contenedores.

- Sistema operativo: Alpine o Debian.
- Docker engine, sin portainer ni interfaces.
- Docker-compose para organización.
- Un dashboard para organizar todo: [Homepage](https://gethomepage.dev/).
- [Taiga](https://taiga.io/) para organización de tareas.
- [FreshRSS](https://github.com/FreshRSS/FreshRSS) para RSS.
