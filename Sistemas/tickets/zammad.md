# Zammad

## Contenido
- [Zammad](#zammad)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Zammad en Debian 12](#instalar-zammad-en-debian-12)
      - [Pre-Requisitos](#pre-requisitos)
      - [Instalación](#instalación-1)

## Documentación

- [Pre-requisitos](https://docs.zammad.org/en/latest/prerequisites/software.html)

- [Instalación por paquete](https://docs.zammad.org/en/latest/install/package.html)

## Instalación

### Instalar Zammad en Debian 12
- Zammad 7+ ya no soporta mysql

#### [Pre-Requisitos](https://docs.zammad.org/en/latest/prerequisites/software.html)

1. Instalar requisitos:
```sh
apt install libimlib2 curl apt-transport-https gnupg
```

2. [Instalar Postgres](../database/postgres.md#instalar-postgresql-en-debian-12)

3. Instalar NodeJS:
   - NodeJS ya viene con el paquete, no hace falta instalarlo si no se va a usar para otra cosa.
   - Zammad 6.2+ usa Node 18.0+

4. Instalar proxy reverso:
   - [Nginx 1.3+](../web/servidores/nginx.md#instalar-nginx-en-debian)
   - Apache 2.2+

5. [Instalar Redis](../database/redis.md#instalar-redis-en-debian-12).

6. [Instalar ElasticSearch](../../database/nosql/elasticsearch.md#instalar-elasticsearch-8-en-debian-12).

    1. Configurar */etc/elasticsearch/elasticsearch.yml*:
    ```text
    # Zammad
    http.max_content_length: 400mb
    indices.query.bool.max_clause_count: 2000
    ```

#### [Instalación](https://docs.zammad.org/en/latest/install/package.html)
1. Configurar local:
```sh
# Obtener idioma del sistema
locale | grep "LANG="
```

2. Agregar repositorio e instalar:
```sh
curl -fsSL https://dl.packager.io/srv/zammad/zammad/key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/pkgr-zammad.gpg> /dev/null

echo "deb [signed-by=/etc/apt/trusted.gpg.d/pkgr-zammad.gpg] https://dl.packager.io/srv/deb/zammad/zammad/stable/debian 12 main"| tee /etc/apt/sources.list.d/zammad.list > /dev/null

apt update && apt install zammad -y
```

3. [Configuraciones de seguridad](https://docs.zammad.org/en/latest/install/package.html#firewall-selinux).

4. [Conectar ElasticSearch](https://docs.zammad.org/en/latest/getting-started/configure-webserver.html#adjusting-the-webserver-configuration):
```sh
zammad run rails r "Setting.set('es_url', 'https://localhost:9200')"

zammad run rake zammad:searchindex:rebuild
```

5. [Configurar proxy](https://docs.zammad.org/en/latest/getting-started/configure-webserver.html#adjusting-the-webserver-configuration):
```sh
# HTTP
cp /opt/zammad/contrib/nginx/zammad.conf /etc/nginx/sites-available/zammad.conf

# HTTPS
cp /opt/zammad/contrib/nginx/zammad_ssl.conf /etc/nginx/sites-available/zammad.conf

rm /etc/nginx/sites-enabled/default

nginx -s reload
```

