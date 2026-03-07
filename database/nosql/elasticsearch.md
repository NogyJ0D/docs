# ElasticSearch

---

## Contenido

- [ElasticSearch](#elasticsearch)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar ElasticSearch 9 en Debian 13](#instalar-elasticsearch-9-en-debian-13)
  - [Extras](#extras)
    - [Si no levanta después de un upgrade](#si-no-levanta-después-de-un-upgrade)

---

## Documentación

---

## Instalación

### [Instalar ElasticSearch 9 en Debian 13](https://www.elastic.co/docs/deploy-manage/deploy/self-managed/install-elasticsearch-with-debian-package)

1. Instalar elasticsearch:

   ```sh
   apt install -y gnupg apt-transport-https

   wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/9.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-9.x.list
   apt update && apt install elasticsearch -y
   ```

2. Modificar el archivo **_/etc/elasticsearch/elasticsearch.yml_**:

   ```yml
   cluster.name: cluster
   node.name: node
   network.host: 127.0.0.1
   http.port: 9200
   xpack.security.enabled: false # Deshabilitar hasta ser requerido
   ```

3. Modificar el archivo **_/etc/elasticsearch/jvm.options_**:

   ```ini
   -Xms[mitad de la ram]g
   -Xmx[mitad de la ram]g
   ```

4. Iniciar servicio:

   ```sh
   systemctl daemon-reload && systemctl enable elasticsearch.service --now
   ```

5. Probar si funciona:

   ```sh
   curl -X GET localhost:9200

   curl -X GET localhost:9200/_cat/health
   ```

   - Si el "\_cat/health" devuelve un error como este:

     ```json
     {
       "error": {
         "root_cause": [{ "type": "master_not_discovered_exception", "reason": null }],
         "type": "master_not_discovered_exception",
         "reason": null
       },
       "status": 503
     }
     ```

     1. Agregar `discovery.type: single-node` a `/etc/elasticsearch/elasticsearch.yml` fijándose que no esté la opción `cluster.initial_master_nodes`.
     2. Volver a probar el health.

## Extras

### Si no levanta después de un upgrade

- Puede ser porque tiene algún plugin (y estos no se actualizan con apt):

  ```sh
  /usr/share/elasticsearch/bin/elasticsearch-plugin list
  /usr/share/elasticsearch/bin/elasticsearch-plugin remove <plugin conflictivo>
  /usr/share/elasticsearch/bin/elasticsearch-plugin install <plugin conflictivo>
  systemctl restart elasticsearch
  ```
