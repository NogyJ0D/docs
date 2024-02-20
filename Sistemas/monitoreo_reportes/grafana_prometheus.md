# Grafana + Prometheus

---

## Contenido

- [Grafana + Prometheus](#grafana--prometheus)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar grafana OSS en Debian 12](#instalar-grafana-oss-en-debian-12)
  - [Extras](#extras)

---

## Documentación

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
