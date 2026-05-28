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

1. Instalar [nvm](https://github.com/nvm-sh/nvm?tab=readme-ov-file#installing-and-updating) para node:

   ```sh
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
   source .bashrc # O .zshrc o lo que sea
   nvm install node
   ```

2. Instalar base de datos:
   - Con Postgresql:

     ```sh
     apt install postgresql -y

     su postgres -c psql
     ```

     ```sql
     CREATE USER meshcentral WITH PASSWORD 'contraseña';
     CREATE DATABASE meshcentral OWNER meshcentral;
     exit
     ```

   - [Con MongoDB 7](../../database/nosql/mongodb.md#instalar-mongodb-como-docker).

3. Dar permisos de puerto a node:

   ```sh
   whereis node
   # node: /root/.nvm/versions/node/v20.11.0/bin/node

   setcap cap_net_bind_service=+ep /root/.nvm/versions/node/v25.8.2/bin/node
   ```

4. Instalar MeshCentral:

   ```sh
   mkdir -p /opt/meshcentral/meshcentral-data
   cd /opt/meshcentral
   npm install meshcentral
   npm install pg

   node node_modules/meshcentral --createaccount admin --pass contraseña
   node node_modules/meshcentral --siteadmin admin
   ```

5. Configurar en `/opt/meshcentral/meshcentral-data/config.json`:

   ```json
   {
     "settings": {
       "cert": "soporte.dominio.com",
       "port": 4430,
       "redirPort": 0,
       "mongoDb": null,
       "postgres": {
         "user": "meshcentral",
         "password": "CambiarEstaPassword123",
         "host": "localhost",
         "port": 5432,
         "database": "meshcentral"
       },
       "trustedProxy": "<ip del proxy reverso>",
       "selfUpdate": false,
       "allowLoginToken": true,
       "allowFraming": false,
       "webRtcConfig": {
         "iceServers": []
       }
     },
     "domains": {
       "": {
         "title": "Soporte Remoto",
         "title2": "Acceso remoto seguro",
         "newAccounts": false,
         "certUrl": "https://soporte.dominio.com"
       }
     }
   }
   ```

6. Crear servicio:

   ```sh
   nano /etc/systemd/system/meshcentral.service
   ```

   ```conf
   [Unit]
   Description=MeshCentral Server

   [Service]
   Type=simple
   LimitNOFILE=1000000
   ExecStart=<whereis node> /opt/meshcentral/node_modules/meshcentral
   Environment=NODE_ENV=production
   Restart=always
   RestartSec=10
   AmbientCapabilities=cap_net_bind_service

   [Install]
   WantedBy=multi-user.target
   ```

   ```sh
   systemctl enable --now meshcentral.service
   ```

7. Agregar a nginx:

   ```nginx
   server {
     listen 80;
     listen [::]:80;
     server_name soporte.dominio.com;

     return 301 https://$host$request_uri;
   }

    server {
      listen 443 ssl;
      listen [::]:443 ssl;
      http2 on;
      server_name soporte.dominio.com;

      ssl_certificate /etc/letsencrypt/live/soporte.dominio.com/fullchain.pem;
      ssl_certificate_key /etc/letsencrypt/live/soporte.dominio.com/privkey.pem;

      #ssl_protocols TLSv1.2 TLSv1.3;
      #ssl_prefer_server_ciphers on;

      location / {
        proxy_pass https://192.168.0.x:4430;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_connect_timeout 60s;
        proxy_read_timeout 3600s;
        proxy_send_timeout 3600s;

        proxy_ssl_verify off;

        client_max_body_size 256M;
        proxy_buffering off;
      }
    }
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
