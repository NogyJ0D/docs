# Docker

---

## Contenido

- [Docker](#docker)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Docker en Alpine](#instalar-docker-en-alpine)
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

## Extras
