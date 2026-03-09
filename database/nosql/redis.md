# Redis

---

## Contenido

- [Redis](#redis)
  - [Contenido](#contenido)
  - [Instalación](#instalación)
    - [Instalar Redis en Debian 13](#instalar-redis-en-debian-13)

## Instalación

### [Instalar Redis en Debian 13](https://redis.io/docs/latest/operate/oss_and_stack/install/archive/install-redis/install-redis-on-linux/)

1. Instalar requisitos:

   ```sh
   apt-get install lsb-release curl gpg -y
   ```

2. Importar repositorio:

   ```sh
   curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
   chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
   apt update
   ```

3. Instalar redis:

   ```sh
   apt install redis -y
   systemctl enable redis-server --now
   ```
