# [Wazuh](https://wazuh.com/)

## Componentes:
- Agente (para los nodos)
- Wazuh Server: procesa los datos de los agentes.
- Wazuh Indexer: almacena las alertas, estadísticas y datos del servidor. Tiene API REST para consultas.
- Wazuh Dashboard: interfaz de usuario.

Los componentes del servidor corren en nodos, mínimo uno, que pueden estar en la misma o distintas máquinas.

Esta instalación sigue los pasos con el asistente, para instalación paso a paso revisar la documentación.

## Instalación
Si no deja ejecutar los comandos por ser el sistema incompatible (ej. ubuntu de otra versión), agregar -i a los comandos.

### 1. Instalar W Indexer

#### 1. Configuración inicial:

1. **Descargar el asistente y configuración**:
```text
apt install curl sudo -y &&
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh &&
curl -sO https://packages.wazuh.com/4.7/config.yml
```

2. **Editar la configuración**:
Reemplazar los nombres e IP de los tres nodos.
```sh
nano config.yml
```

3. **Correr el instalador**:
Genera la cluster key, certificados y contraseñas necesarias para la instalación.
```sh
bash wazuh-install.sh --generate-config-files -i
```

#### 2. Instalar el nodo de W Indexer:

1. **Descargar el asistente**:
Se puede omitir si ya se descargó en el paso anterior.
```sh
# curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
```

2. **Correr el asistente**:
Usar el nombre del nodo definido en ***config.yml***. Repetir por cada nodo que se quiera instalar.
```sh
bash wazuh-install.sh --wazuh-indexer wazuh-indexer -i
```

3. **Iniciar el cluster**:
Hacerlo una sola vez, no por cada nodo.
```sh
bash wazuh-install.sh --start-cluster -i
```

#### 3. Probar la configuración:

1. **Obtener la contraseña de administrador**:
```sh
tar -axf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt -O | grep -P "\'admin\'" -A 1
```

2. Confirmar la instalación:
Usar la contraseña obtenida y la IP asignada al nodo.
```sh
curl -k -u admin:<ADMIN_PASSWORD> https://<WAZUH_INDEXER_IP>:9200
curl -k -u admin:<ADMIN_PASSWORD> https://<WAZUH_INDEXER_IP>:9200/_cat/nodes?v
```

### 2. Instalar W Server

1. **Descargar el asistente de instalación**:
Se puede omitir si ya se descargó en el paso anterior. Repetir por la cantidad de nodos que se desean.
```sh
# curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh --wazuh-server wazuh-server -i
```

### 3. Instalar W Dashboard

1. **Descargar el asistente de instalación**:
Se puede omitir si ya se descargó en el paso anterior. Una copia del archivo ***wazuh-install-files.tar*** (generado en la configuración inicial del indexer) debe estar presente en la misma carpeta del asistente. De no especificar puerto, se usa el 443. Una vez instalado, se muestran las credenciales para acceder.
```sh
# curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
bash wazuh-install.sh --wazuh-dashboard wazuh-dashboard -i
bash wazuh-install.sh --wazuh-dashboard wazuh-dashboard -p <port_number> -i
```

Para todas las contraseñas generadas en la instalación:
```sh
tar -O -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt
```

#### 4. Luego

// Esto no hacerlo
1. **Cambiar contraseñas de la API**:
Una mayuscula, una minuscula, un caracter de los siguientes \(.\*+?-\), de 8 a 64 caracteres.
```sh
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -A --admin-user wazuh --admin-password wazuh -u wazuh-wui -p \<contraseña\>
/usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh -A --admin-user wazuh --admin-password wazuh -u wazuh -p \<contraseña\>
```
//

1. **Modificar el dashboard**:
Modificar el archivo ***/usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml***: donde está la contraseña encriptada, reemplazar por "wazuh-wui".

2. **Reiniciar todo**:
```sh
systemctl restart wazuh-*.service
```

## Actualización:

### 1. Preparar la actualización:

1. **Agregar el repositorio**:
Opcional si ya está agregado.
```sh
apt install gnupg apt-transport-https
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
apt update
```

2. **Detener servicios**:
```sh
systemctl stop filebeat wazuh-dashboard
```

### 2. Actualizar Indexer:
Repetir por cada nodo. No se especifica que usuario y contraseña son.

1. **Deshabilitar**:
```sh
curl -X PUT "https://<WAZUH_INDEXER_IP>:9200/_cluster/settings"  -u <username>:<password> -k -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": "primaries"
  }
}
'
```

2. **Limpiar**:
```sh
curl -X POST "https://<WAZUH_INDEXER_IP>:9200/_flush/synced" -u <username>:<password> -k
```

3. **Detener servicio**:
```sh
systemctl stop wazuh-indexer
```

4. **Actualizar**:
```sh
apt install wazuh-indexer
```

5. **Iniciar servicio**:
```sh
systemctl daemon-reload
systemctl enable wazuh-indexer
systemctl start wazuh-indexer
```

6. **Probar actualización**:
```sh
curl -k -u <username>:<password> https://<WAZUH_INDEXER_IP>:9200/_cat/nodes?v
```

7. **Habilitar**:
```sh
curl -X PUT "https://<WAZUH_INDEXER_IP>:9200/_cluster/settings" -u <username>:<password> -k -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": "all"
  }
}
'
```

8. **Probar**:
```sh
curl -k -u <username>:<password> https://<WAZUH_INDEXER_IP>:9200/_cat/nodes?v
```

### 3. Actualizar Server:
Repetir por cada nodo, iniciando por el master. No se especifica que usuario y contraseña son.

1. **Actualizar manager**:
```sh
apt-get install wazuh-manager
```

2. **Descargar módulo para Filebeat**:
```sh
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.3.tar.gz | sudo tar -xvz -C /usr/share/filebeat/module
```

3. **Descargar alertas**:
```sh
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/v4.7.0/extensions/elasticsearch/7.x/wazuh-template.json
chmod go+r /etc/filebeat/wazuh-template.json
```

4. **Reiniciar Filebeat**:
```sh
systemctl daemon-reload
systemctl enable filebeat
systemctl start filebeat
```

5. **Actualizar plantillas**:
> **Importante**: se puede omitir si el indexer trabaja en un solo nodo.
```sh
filebeat setup --index-management -E output.logstash.enabled=false
```

### 4. Actualizar Dashboard:

1. **Actualizar**:
```sh
apt install wazuh-dashboard
```

2. **Reiniciar servicio**:
```sh
systemctl daemon-reload
systemctl enable wazuh-dashboard
systemctl start wazuh-dashboard
```

### 5. Actualizar agentes:
Este proceso actualiza los agentes de forma remota. La API permite hacer todos juntos, con el CLI es uno por uno.

1. **Obtener token**:
Reemplazar \<user\> y \<password\> por tus credenciales de Wazuh-API.
```sh
TOKEN=$(curl -u <user>:<password> -k -X GET "https://localhost:55000/security/user/authenticate?raw=true")
```

2. **Listar agentes desactualizados**:
```sh
curl -k -X GET "https://localhost:55000/agents/outdated?pretty=true" -H  "Authorization: Bearer $TOKEN"
```

3. **Actualizar TODOS los agentes**:
Si se actualizan mas de 3000 agentes a la vez, agregar el parámetro "wait_for_complete=true".
```sh
curl -k -X PUT "https://localhost:55000/agents/upgrade?agents_list=all&pretty=true" -H  "Authorization: Bearer $TOKEN"
```

4. **Ver estado de actualizaciones**:
```sh
curl -k -X GET "https://localhost:55000/agents/upgrade_result?pretty=true" -H  "Authorization: Bearer $TOKEN"
```

5. **Ver versiones de los agentes**:
```sh
curl -k -X GET "https://localhost:55000/agents?pretty=true&select=version&sort=+version" -H  "Authorization: Bearer $TOKEN"
```

## Desinstalar Wazuh:
Ejecutar:
```sh
bash wazuh-install.sh --uninstall -i
```
## Agentes:

### Eliminar:
En la consola:
```sh
/var/ossec/bin/manage_agents
```