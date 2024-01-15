# Redis

## Contenido
- [Redis](#redis)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Redis en Debian 12](#instalar-redis-en-debian-12)

## Documentación
- [Para Debian](https://www.linuxcapable.com/how-to-install-redis-on-debian-linux/)

## Instalación

### Instalar Redis en Debian 12
1. Instalar requisitos:
```sh
sudo apt install software-properties-common apt-transport-https curl ca-certificates -y
```

2. Importar repositorio:
```sh
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

sudo apt update
```

3. Instalar redis:
```sh
sudo apt install redis redis-server redis-tools -y

apt-cache policy redis

sudo systemctl enable redis-server --now
```