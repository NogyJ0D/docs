# horilla

## Instalación

### Instalar horilla en Debian 12

1. Instalar requerimientos:

   ```sh
   apt install python3 postgresql vim git postgresql-contrib python3-venv gettext

   su postgres -c "psql"
   ```

   ```sql
   CREATE ROLE horilla LOGIN PASSWORD 'horilla';
   CREATE DATABASE horilla_main OWNER horilla;
   \q
   ```

2. Descargar horilla:

   ```sh
   git clone https://github.com/horilla-opensource/horilla.git
   cd horilla

   python3 -m venv horillavenv
   source horillavenv/bin/activate

   pip install -r requirements.txt
   mv .env.dist .env
   vim .env

   python3 manage.py makemigrations
   python3 manage.py migrate
   python3 manage.py compilemessages
   ```

3. Crear servicio:

   ```sh
   vim /etc/systemd/system/horilla.service
   ```

   ```ini
   [Unit]
   Description=horilla HRMS
   After=network.target

   [Service]
   User=root
   Group=root
   WorkingDirectory=/root/horilla
   ExecStart=/root/horilla/horillavenv/bin/gunicorn --workers 3 --bind 0.0.0.0:8000 horilla.wsgi:application
   Restart=always
   Environment="DJANGO_SETTINGS_MODULE=horilla.settings"
   Environment="PYTHONPATH=/root/horilla"

   [Install]
   WantedBy=multi-user.target
   ```

   ```sh
   systemd daemon-reload
   systemd enable --now horilla
   ```
