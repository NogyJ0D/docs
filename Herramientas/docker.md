# Docker

- [Docker](#docker)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Docker en Alpine](#instalar-docker-en-alpine)
  - [Comandos](#comandos)
  - [Extras](#extras)

---

## Documentación

- [Página oficial](https://www.docker.com/)

---

## Instalación

### Instalar Docker en Alpine

```sh
apk add --update docker docker-cli-compose openrc
rc-update add docker boot
service docker start
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

## Extras
