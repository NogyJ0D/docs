# ElasticSearch

---

## Contenido

- [ElasticSearch](#elasticsearch)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar ElasticSearch 8 en Debian 12](#instalar-elasticsearch-8-en-debian-12)

---

## Documentación

---

## Instalación

### Instalar ElasticSearch 8 en Debian 12

```sh
apt install -y gnupg apt-transport-https

wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-8.x.list && \
  apt update && \
  apt install elasticsearch -y && \
  systemctl daemon-reload && systemctl enable elasticsearch.service --now
```
