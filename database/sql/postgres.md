# Postgres

---

## Contenido

- [Postgres](#postgres)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
  - [Instalación](#instalación)
    - [Instalar Postgresql en Debian 12](#instalar-postgresql-en-debian-12)

---

## Documentación

- <https://wiki.debian.org/PostgreSql>

---

## Comandos

- Entrar a psql:

  ```sh
  su -c /usr/bin/psql postgres
  # O
  sudo -u postgres psql
  ```

- Crear usuario:

  ```sh
  createuser --pwprompt {usuario}
  ```

- Crear DB:

  ```sh
  createdb -O {owner} db
  ```

---

## Instalación

### Instalar Postgresql en Debian 12

```sh
sudo apt -y install postgresql-15
```
