# NetBox

- [NetBox](#netbox)

---

## Instalación

### Instalar NetBox en Debian 12

1. Instalar postgres:

   ```sh
   apt install postgresql -y
   su postgres -c "psql"
   psql --username netbox --password --host localhost netbox # Probar después la conexión
   ```

   ```sql
   CREATE DATABASE netbox;
   \l -- Asegurarse que el encoding es UTF8
   CREATE USER netbox WITH PASSWORD 'netbox';
   ALTER DATABASE netbox OWNER TO netbox;
   \c netbox;
   GRANT CREATE ON SCHEMA public TO netbox;
   \q
   ```

2. Instalar redis:

   ```sh
   apt install redis-server -y
   redis-server -v
   redis-cli ping
   ```

3. Instalar NetBox:

   - Buscar última release en <https://github.com/netbox-community/netbox/tags>.

   ```sh
   apt install python3 python3-pip python3-venv python3-dev build-essential libxml2-dev libxslt1-dev libffi-dev libpq-dev libssl-dev zlib1g-dev -y

   wget https://github.com/netbox-community/netbox/archive/refs/tags/vX.Y.Z.tar.gz
   tar -xzf vX.Y.Z.tar.gz -C /opt
   ln -s /opt/netbox-X.Y.Z/ /opt/netbox

   adduser --system --group netbox
   chown -R netbox /opt/netbox/netbox/media
   chown -R netbox /opt/netbox/netbox/reports
   chown -R netbox /opt/netbox/netbox/scripts

   cd /opt/netbox/netbox/netbox
   cp configuration_example.py configuration.py
   vim configuration.py
   ```

   - Configurar:
     - ALLOWED_HOSTS: ["dominio.com"], ["*"] o ["192.168.1.2"]
     - DATABASES
     - REDIS
     - SECRET_KEY: generar secret key ejecutando "python3 ../generate_secret_key.py"

   ```sh
   cd /opt/netbox
   ./upgrade.sh
   source /opt/netbox/venv/bin/activate
   cd /opt/netbox/netbox
   python3 manage.py createsuperuser
   python3 manage.py runserver 0.0.0.0:8000 --insecure # Probar servidor
   ```

4. Gunicorn:

   ```sh
   cd /opt/netbox
   cp contrib/gunicorn.py . # Editar si hace falta
   cp -v /opt/netbox/contrib/*.service /etc/systemd/system/
   systemctl daemon-reload
   systemctl enable --now netbox netbox-rq
   ```

5. Instalar nginx:

   ```sh
   apt install nginx -y
   cp /opt/netbox/contrib/nginx.conf /etc/nginx/sites-enabled/netbox.conf # Configurar a gusto, cambiar server_name para coincidir con configuration.py ALLOWED_HOSTS
   rm /etc/nginx/sites-enabled/default
   nginx -s reload
   ```
