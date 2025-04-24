# MeshCentral

---

## Contenido

- [MeshCentral](#meshcentral)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Meshcentral en Ubuntu 22.04](#instalar-meshcentral-en-ubuntu-2204)
  - [Extras](#extras)
    - [KVM child process has unexpectedly exited](#kvm-child-process-has-unexpectedly-exited)

---

## Documentación

---

## Instalación

### Instalar Meshcentral en Ubuntu 22.04

1. Instalar node y npm:

   ```sh
   apt install nodejs npm -y
   ```

3. [Instalar MongoDB 7](../../database/nosql/mongodb.md#instalar-mongodb-7-en-ubuntu-2204).

4. Dar permisos de puerto a node:

   ```sh
   whereis node
   # node: /root/.nvm/versions/node/v20.11.0/bin/node

   sudo setcap cap_net_bind_service=+ep /root/.nvm/versions/node/v20.11.0/bin/node
   ```

5. Instalar MeshCentral:

   ```sh
   mkdir meshcentral && cd meshcentral && npm i meshcentral
   node node_modules/meshcentral
   ```

   - Ahora entrar a la url del mesh.

6. Configurar MeshCentral:

   - Editar en **_meshcentral-data/config.json_**:

     ```json
     {
         "settings": {
             "MongoDb": "mongodb://127.0.0.1:27017/meshcentral",
             "WANonly": true,
             "_Port": 443,
             "_RedirPort": 80,
             "_AllowLoginToken": true,
             "_AllowFraming": true,
             "_WebRTC": false,
             "_ClickOnce": false,
             "_UserAllowedIP" : "127.0.0.1,::1,192.168.0.100"
         }
     }
     ```

7. Crear servicio:

   ```sh
   nano /etc/systemd/system/meshcentral.service
   ```

   ```conf
   [Unit]
   Description=MeshCentral Server

   [Service]
   Type=simple
   LimitNOFILE=1000000
   ExecStart=<Ubicación de node> <Ubicación del mesh>/node_modules/meshcentral
   Environment=NODE_ENV=production
   Restart=always
   # Restart service after 10 seconds if node service crashes
   RestartSec=10
   # Set port permissions capability
   AmbientCapabilities=cap_net_bind_service

   [Install]
   WantedBy=multi-user.target
   ```

   ```sh
   systemctl enable --now meshcentral.service
   ```

---

## Extras

### [KVM child process has unexpectedly exited](https://github.com/Ylianst/MeshAgent/issues/135#issuecomment-1505193977)

Si al entrar al escritorio de una máquina aparece ese cartel:

1. Descargar xhost:

   - En arch: pacman -S xorg-xhost

2. Agregar el script en **_/etc/X11/xinit/xinitrc.d/60-xhost.sh_**:

   ```sh
   #!/bin/bash
   xhost +local:
   ```

   ```sh
   chmod +x /etc/X11/xinit/xinitrc.d/60-xhost.sh
   chown root:root /etc/X11/xinit/xinitrc.d/60-xhost.sh
   ```
