# unifi

- [unifi](#unifi)

---

## Instalación

### Instalar UniFi Network Server en Debian 12

1. [Instalar mongodb](../database/nosql/mongodb.md#instalar-mongodb-7-en-debian-12)

2. Instalar:

    ```sh
    apt install ca-certificates apt-transport-https
    
    echo 'deb [ arch=amd64,arm64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list

    wget -O /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ui.com/unifi/unifi-repo.gpg

    apt update
    apt install unifi
    ```
