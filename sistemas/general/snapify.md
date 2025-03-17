# Snapify

- [Snapify](#snapify)

---

## Instalar Snapify

### Instalar Snapify en Alpine

- Habilitar el repositorio community

1. Instalar mariadb:

   ```sh
   apk add mariadb mariadb-client
   rc-update add mariadb default
   /etc/init.d/mariadb setup
   rc-service mariadb start
   mariadb-secure-installation

   editor /etc/my.cnf.d/mariadb-server.cnf # Comentar "skip-networking" y agregar "bind-address=127.0.0.1"

   mysql -u root
   ```

   ```sql
   CREATE USER 'snapify'@'localhost' IDENTIFIED BY 'password';
   CREATE DATABASE snapify;
   GRANT ALL ON *.* TO 'snapify'@'localhost' WITH GRANT OPTION;
   FLUSH PRIVILEGES;
   ```

2. Descargar repo:

   ```sh
   git clone https://github.com/MarconLP/snapify.git
   cd snapify
   ```

3. Configurar .env:

   ```sh
   mv .env.example.env
   openssl rand -base64 32 # Generar contraseña para NEXTAUTH_SECRET
   editor .env
   ```

   ```conf
   DATABASE_URL="mysql://snapify:password@127.0.0.1:3306/snapify"
   NEXTAUTH_URL="https://example.com"
   NEXTAUTH_SECRET="secret 32 base64"
   ```

   ```sh
   npm i
   vim prisma/schema.prisma # Cambiar provider = "postgres" por "mysql"
   npx prisma generate
   npx prisma db push
   ```

4. Compilar y agregar como servicio:

   ```sh
   npm run build
   vim /etc/init.d/snapify
   ```

   ```openrc
   #!/sbin/openrc-run

   name="Snapify"
   desciption="Next app"
   command="/usr/bin/npm"
   command_args="run start"
   directory="/root/snapify"
   user="root"
   pidfile="/run/snapify.pid"
   output_log="/var/log/snapify.log"
   error_log="/var/log/snapify.err"

   depend() {
           need net
   }

   start() {
           ebegin "Starting snapify"
           start-stop-daemon --start --background --make-pidfile --pidfile "$pidfile" --chdir "$directory" --exec "$command" -- $command_args
   }

   stop() {
           ebegin "Stopping snapify"
           start-stop-daemon --stop --pidfile "$pidfile"
           eend $?
   }
   ```
