# MongoDB

---

## Contenido

- [MongoDB](#mongodb)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar MongoDB 7 en Ubuntu 22.04](#instalar-mongodb-7-en-ubuntu-2204)
  - [Extras](#extras)
    - [Backup y Restore](#backup-y-restore)

---

## Documentación

---

## Instalación

### Instalar MongoDB 7 en Ubuntu 22.04

```sh
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt update && apt install -y mongodb-org

systemctl daemon-reload
# O reboot
```

---

## Extras

### Backup y Restore

- Backup:

    ```sh
    mongodump --db database

    # Para transferirlo:
    tar -cvzf dump.tar.gz dump_folder
    scp meshdump.tar.gz <user>@<ip>:/path
    ```

- Restore:

    ```sh
    mongorestore --verbose archivo

    # Opcional:
    # --drop (borra la db existente)

    # A otra db
    mongorestore --db database --verbose archivo
    ```
