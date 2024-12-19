# Homepage

[Homepage](https://gethomepage.dev/)

- [Homepage](#homepage)
  - [Creación](#creación)
  - [Configuración](#configuración)

---

## Creación

- Compose:

  ```yaml
  version: '3'

  services:
    homepage:
      image: ghcr.io/gethomepage/homepage:latest
      container_name: homepage
      ports:
        - 3001:3000
      volumes:
        - /root/containers/homepage/config:/app/config
        - /var/run/docker.sock:/var/run/docker.sock
      restart: unless-stopped
  ```

## Configuración

- Los marcadores se agregan en ~/config/bookmarks.yaml
- Ejemplo:

  ```yaml
  - Categoría:
      - Elemento 1:
          - abbr: 1
            href: http://1
      - Elemento 2:
          - abbr: 2
            href: http://2
  ```
