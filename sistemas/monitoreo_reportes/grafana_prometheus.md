# Grafana + Prometheus

---

## Contenido

- [Grafana + Prometheus](#grafana--prometheus)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
    - [Observability](#observability)
    - [Grafana](#grafana)
    - [Primeros pasos](#primeros-pasos)
  - [Instalación](#instalación)
    - [Instalar grafana OSS en Debian 12](#instalar-grafana-oss-en-debian-12)
  - [Extras](#extras)

---

## Documentación

### Observability

- O11Y = Olly = Observability
- El cuerpo tiene varios sistemas internos
  - Primero: ver cómo está cuerpo
  - Si algo está mal, ver qué pasa
  - Usar máquinas para ver los órganos internos
  - Recopilar, analizar y visualizar información para ver que pasa
  - Con eso, se puede solucionar un problema
- Entender el rendimiento, comportamiento y estado de un sistema mediante análisis de datos de varias fuentes (métricas, registros, trazas)
  - **Métricas**: datos numéricos, algo pasa
    - Un sistema de observabilidad lanza alertas si las métricas superan ciertos umbrales
  - **Registros**: archivos de texto, qué pasa
  - **Trazas**: rastrear solicitudes, cómo interactúan y rastrear dónde se produce el problema.

### Grafana

- Grafana en sí no almacena datos, de eso se encargan las fuentes de datos (Loki, Tempo y Mimir por ejemplo)

### Primeros pasos

- Agregar una fuente de datos:
  1. Ir a _Connections_ > _Data Sources_ > **Add data source**.
  2. Si hay soporte nativo para la fuente, aparece ahí. Si no hay, se requieren plugins.
  3. Buscar la fuente elegida.
  4. Entrar y completar los datos (nombre, conexión, autenticación), ir al fondo y agregar.
- Agregar plugins:
  1. Ir a _Administration_ > _Plugins and data_ > _Plugins_.
  2. Elegir el deseado, entrar y darle a **Install**.
  3. Ahora se puede agregar como fuente de datos.
- Explorar los datos:
  1. Ir a _Explore_.
  2. Elegir una fuente de datos arriba.
  3. Elegir un rango de tiempo.
  4. Seleccionar un **Label Filter** y un **Value**. Esto arma la query

---

## Instalación

### Instalar grafana OSS en Debian 12

1. Instalar grafana-server:

   ```sh
   apt install -y apt-transport-https software-properties-common wget
   mkdir -p /etc/apt/keyrings/
   wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | tee /etc/apt/keyrings/grafana.gpg > /dev/null
   echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
   apt update

   apt install grafana

   systemctl daemon-reload
   systemctl enable --now grafana-server
   ```

2. Loguearse en el puerto 3000 como admin:admin.

3. Instalar prometheus:

   - Buscar última versión de [prometheus](https://prometheus.io/download/#prometheus) y [node_exporter](https://prometheus.io/download/#node_exporter)

   1. Descargar node_exporter:

      ```sh
      wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
      tar xvfz node_exporter-*.*-amd64.tar.gz
      cd node_exporter-*.*-amd64
      ./node_exporter
      ```

   2. Descargar prometheus:

      ```sh
      wget https://github.com/prometheus/prometheus/releases/download/v2.45.3/prometheus-2.45.3.linux-amd64.tar.gz && \
        tar xvfz prometheus-*.tar.gz
      cd prometheus-*
      nano prometheus.yml
      ```

      - Agregar:

        ```ini
        # A scrape configuration containing exactly one endpoint to scrape from node_exporter running on a host:
        scrape_configs:
            # The job name is added as a label `job=<job_name>` to any timeseries scraped from this config.
            - job_name: 'node'

            # metrics_path defaults to '/metrics'
            # scheme defaults to 'http'.

              static_configs:
              - targets: ['localhost:9100']
        ```

      ```sh
      ./prometheus --config.file=./prometheus.yml
      ```

---

## Extras
