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

### Instalar MongoDB 7 en Debian 12

> Si se está instalando en una VM de Proxmox, la arquitectura de CPU debe ser "host", no acepta emuladas.

```sh
apt install gnupg curl

curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt update
apt install -y mongodb-org

systemctl daemon-reload
systemctl enable --now mongod


```

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
    mongodump --db database -o dbdump

    # Para transferirlo:
    tar -cvzf dbdump.tar.gz dbdump
    scp dbdump.tar.gz <user>@<ip>:/path
    ```

- Restore:

    ```sh
    tar -xvzf dmdump.tar.gz
    mongorestore --verbose dbdump/

    # Opcional:
    # --drop (borra la db existente)

    # A otra db
    mongorestore --db database --verbose dbdump/archivo/
    ```
