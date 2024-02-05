# Contenedores

---

## Contenido

- [Contenedores](#contenedores)
  - [Contenido](#contenido)
  - [Lista](#lista)
    - [Heimdall](#heimdall)
    - [Portainer](#portainer)

---

## Lista

### [Heimdall](https://heimdall.site/)

- Dashboard de páginas para acceder rápidamente.

```sh
sudo docker run --name=heimdall -d -v /home/kodestar/docker/heimdall:/config -e PGID=1000 -e PUID=1000 -p 8080:80 -p 8443:443 linuxserver/heimdall
```

### [Portainer](portainer.md#instalación)

- Centro de instalación y monitoreo de contenedores.