# Dashy

- [Dashy](#dashy)
  - [Directorios](#directorios)
  - [Compose](#compose)
  - [Extras](#extras)
    - [Configuración](#configuración)

---

## Directorios

- dashy/
  - config.yml
  - docker-compose.yml

## Compose

```yaml
services:
  dashy:
    image: lissy93/dashy
    container_name: dashy
    restart: unless-stopped
    networks:
      - dashy
    ports:
      - 127.0.0.1:3000:8080
    volumes:
      - ./config.yml:/app/user-data/conf.yml
    environment:
      NODE_ENV: production
    healthcheck:
      test: ['CMD', 'node', '/app/services/healthcheck']
      interval: 1m30s
      timeout: 10s
      retries: 3
      start_period: 40s

networks:
  dashy:
    name: dashy
    driver: bridge
```

## Extras

### Configuración

```yaml
---
pageInfo:
  title: Home
sections:
appConfig:
  defaultOpeningMethod: newtab
  preventLocalSave: true
  theme: dashy-docs
  layout: horizontal
  iconSize: large
  faviconApi: iconhorse
  auth:
    users:
      - user: usuario
        hash: <Contraseña hasheada como SHA-256>
        type: admin
```
