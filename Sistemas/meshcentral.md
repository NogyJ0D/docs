# MeshCentral

## Instalar en Ubuntu 22.04
1. Instalar Node LTS
```sh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash && source ~/.bashrc

nvm install --lts
```

2. Instalar MongoDB 7:
```sh
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

sudo apt-get update

sudo apt-get install -y mongodb-org

sudo systemctl daemon-reload
# o reboot
```

3. Dar permisos de puerto:
```sh
whereis node
# node: /root/.nvm/versions/node/v20.11.0/bin/node

sudo setcap cap_net_bind_service=+ep /root/.nvm/versions/node/v20.11.0/bin/node
```

4. Instalar MeshCentral:
```sh
mkdir meshcentral && cd meshcentral && npm i meshcentral

node ./node_modules/meshcentral

```
- Ahora entrar a la url del mesh

5. Configurar MeshCentral:
```sh
nano meshcentral-data/config.json
```

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
    },
…
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
systemctl start meshcentral.service
systemctl enable meshcentral.service
```