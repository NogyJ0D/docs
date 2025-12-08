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
   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
   ```

2. [Instalar MongoDB 7](../../database/nosql/mongodb.md#instalar-mongodb-como-docker).

3. Dar permisos de puerto a node:

   ```sh
   whereis node
   # node: /root/.nvm/versions/node/v20.11.0/bin/node

   sudo setcap cap_net_bind_service=+ep /root/.nvm/versions/node/v20.11.0/bin/node
   ```

4. Instalar MeshCentral:

   ```sh
   mkdir meshcentral && cd meshcentral && npm i meshcentral
   node node_modules/meshcentral
   # Cuando cargue, cancelar
   ```

5. Configurar MeshCentral:

   - Editar en **_meshcentral-data/config.json_** (revisar las que sean 0.0.0.0 o 127.0.0.1 porque yo tengo en la misma vm):

     ```json
     {
       "settings": {
         "cert": "soporte.dominio.com",
         "mongoDb": "mongodb://meshcentral:meshcentral@127.0.0.1:27017/meshcentral?authSource=admin",
         "mongoDbName": "meshcentral",
         "port": 8443,
         "portBind": "127.0.0.1",
         "aliasport": 443,
         "redirPort": 81,
         "redirPortBind": "127.0.0.1",
         "mpsPort": 4433,
         "mpsPortBind": "0.0.0.0",
         "tlsOffload": "127.0.0.1",
         "trustedProxy": "127.0.0.1,<ip del proxy>",
         "sessionTime": 60,
         "compression": true,
         "wsCompression": true,
         "agentWsCompression": true,
         "allowHighQualityDesktop": true,
         "desktopMultiplex": false,
         "agentPing": 35,
         "agentPong": 35,
         "browserPing": 60,
         "agentIdleTimeout": 150,
         "webPageLengthRandomization": true,
         "exactPorts": false,
         "allowLoginToken": false,
         "allowFraming": false,
         "cookieIpCheck": "lax",
         "cookieEncoding": "base64",
         "StrictTransportSecurity": null,
         "autoBackup": false,
         "agentUpdateSystem": 1,
         "agentCoreDump": false,
         "agentLogDump": false,
         "maxInvalidLogin": {
           "time": 10,
           "count": 10,
           "coolofftime": 30
         }
       },
       "domains": {
         "": {
           "title": "Soporte",
           "title2": "Meshcentral",
           "minify": true,
           "newAccounts": false,
           "userNameIsEmail": false,
           "certUrl": "https://soporte.dominio.com",
           "guestDeviceSharing": true,
           "agentSelfGuestSharing": false,
           "allowSavingDeviceCredentials": true,
           "userQuota": 1048576,
           "meshQuota": 10485760,
           "maxDeviceView": 1000,
           "sessionRecording": {
             "protocols": [1, 2, 5],
             "onlySelectedDeviceGroups": true
           },
           "clipboardGet": true,
           "clipboardSet": true,
           "localSessionRecording": true,
           "userSessionIdleTimeout": 30,
           "logoutOnIdleSessionTimeout": true,
           "agentInviteCodes": true,
           "showNotesPanel": true,
           "urlSwitching": true,
           "ipkvm": false,
           "novnc": true,
           "mstsc": true,
           "ssh": true,
           "showPasswordLogin": true,
           "passwordRequirements": {
             "min": 8,
             "max": 128,
             "upper": 1,
             "lower": 1,
             "numeric": 1,
             "nonalpha": 1,
             "email2factor": true,
             "push2factor": true,
             "otp2factor": true,
             "backupcode2factor": true,
             "force2factor": false,
             "banCommonPasswords": true,
             "twoFactorTimeout": 300
           },
           "twoFactorCookieDurationDays": 30,
           "userConsentFlags": {
             "desktopnotify": false,
             "terminalnotify": false,
             "filenotify": false,
             "desktopprompt": false,
             "terminalprompt": false,
             "fileprompt": false,
             "desktopprivacybar": false
           },
           "myServer": {
             "Backup": true,
             "Restore": true,
             "Upgrade": true,
             "ErrorLog": true,
             "Console": true,
             "Trace": true
           },
           "amtManager": {
             "TlsConnections": true
           },
           "agentConfig": ["displayName=Agente de Gestión Remota", "description=Servicio de administración remota"],
           "limits": {
             "MaxDevices": null,
             "MaxUserAccounts": null,
             "MaxUserSessions": null,
             "MaxAgentSessions": null
           }
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

7. Agregar a nginx:

   ```nginx
   # Mapeo para WebSocket
   map $http_upgrade $connection_upgrade {
     default upgrade;
     '' close;
   }

   server {
     listen 80;
     listen [::]:80;
     server_name soporte.dominio.com;

     return 301 https://$host$request_uri;
   }

   server {
     listen 443;
     listen [::]:443;
     server_name soporte.dominio.com;

     #http2 on;

     # Certificado
     ssl_certificate /etc/letsencrypt/live/soporte.dominio.com/fullchain.pem;
     ssl_certificate_key /etc/letsencrypt/live/soporte.dominio.com/privkey.pem;

     # SSL/TLS
     ssl_protocols TLSv1.2 TLSv1.3;

     # Cifrados seguros
     ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

     # Preferir cifrados del servidor
     ssl_prefer_server_ciphers off;

     # Sesiones
     ssl_session_cache shared:le_nginx_SSL:10m;
     ssl_session_timeout 1440m;
     ssl_session_tickets off;

     # Denegar acceso a archivos de configuración
     location ~ /\. {
         deny all;
         access_log off;
         log_not_found off;
     }

     # Denegar acceso a archivos de backup
     location ~ ~$ {
         deny all;
         access_log off;
         log_not_found off;
     }

     # Denegar acceso a archivos sensibles
     location ~* \.(conf|bak|log|sql|sh|old|orig|tmp|swp|swo)$ {
         deny all;
         access_log off;
         log_not_found off;
     }

     # Denegar acceso a directorios de control de versiones
     location ~ /\.(git|svn|hg|bzr) {
         deny all;
         access_log off;
         log_not_found off;
     }

     # Denegar acceso a archivos de Node.js
     location ~ /(package\.json|package-lock\.json|yarn\.lock) {
         deny all;
         access_log off;
         log_not_found off;
     }

     # Denegar acceso a archivos de configuración comunes
     location ~ /(composer\.(json|lock)|\.env|\.htaccess|\.htpasswd|wp-config\.php) {
         deny all;
         access_log off;
         log_not_found off;
     }

     # Favicon - evitar logs de 404
     location = /favicon.ico {
         log_not_found off;
         access_log off;
     }

     # Robots.txt
     location = /robots.txt {
         log_not_found off;
         access_log off;
     }

     client_max_body_size 2G;

     proxy_connect_timeout 600s;
     proxy_send_timeout 600s;
     proxy_read_timeout 600s;
     send_timeout 600s;

     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
     add_header X-Frame-Options "SAMEORIGIN" always;
     add_header X-Content-Type-Options "nosniff" always;

     access_log /var/log/nginx/soporte.dominio.com.access.log;
     error_log /var/log/nginx/soporte.dominio.com.error.log;

     location / {
       proxy_pass http://127.0.0.1:8443;

       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       proxy_set_header X-Forwarded-Proto $scheme;
       proxy_set_header X-Forwarded-Host $host;
       proxy_set_header X-Forwarded-Port $server_port;

       proxy_http_version 1.1;
       proxy_set_header Upgrade $http_upgrade;
       proxy_set_header Connection $connection_upgrade;

       proxy_buffering off;
       proxy_cache off;
       proxy_request_buffering off;

       proxy_ssl_verify off;
       proxy_ssl_session_reuse on;
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
