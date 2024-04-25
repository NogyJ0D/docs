# Alpine

---

## Contenido

- [Alpine](#alpine)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Extras](#extras)
    - [Instalar XFCE4](#instalar-xfce4)
      - [Agregar autologin en xfce](#agregar-autologin-en-xfce)
    - [Instalar Openbox](#instalar-openbox)
  - [Instalar meshagent](#instalar-meshagent)

---

## Documentación

---

## Instalación

---

## Extras

### Instalar XFCE4

1. Instalar xorg:

   ```sh
   setup-xorg-base
   ```

2. Instalar XFCE4 y utilidades:

   ```sh
   apk add xfce4 xfce4-terminal xfce4-screensaver lightdm-gtk-greeter dbus adwaita-icon-theme elogind polkit-elogind htop
   ```

3. Agregar servicios:

   ```sh
   rc-update add lightdm
   rc-update add dbus
   ```

4. Reiniciar.

5. Entrar y en "Settings > Keyboard" agregar la distribución a usar.

#### Agregar autologin en xfce

1. Agregar en **_/etc/lightdm/lightdm.conf_**:

   ```conf
   [Seat:*]
   autologin-user=usuario
   autologin-user-timeout=0
   user-session=xfce
   ```

2. Reiniciar.

### Instalar Openbox

1. Instalar paquetes:

   ```sh
   apk add openbox xterm font-terminus
   ```

2. Configurar el xorg-server:

   ```sh
   setup-xorg-base
   cp /etc/X11/xinit/xinitrc ~/.xinitrc
   echo 'exec openbox-session' >> ~/.xinitrc
   ```

3. Agregar usuarios a los grupos:

   ```sh
   addgroup <usuario> input
   addgroup <usuario> video
   ```

4. Configurar openbox:

   ```sh
   mkdir ~/.config
   cp -r /etc/xdg/openbox ~/.config
   ```

5. Iniciar X:

   ```sh
   startx
   ```

## Instalar meshagent

> No funciona con el modo pantalla, solo terminal y archivos.

1. Instalar requisitos (no se si hacen falta):

   ```sh
   apk add wget curl bash sudo
   ```

2. Descargar binario OpenWRT x86-64:

   ```sh
   wget https://mesh-url/meshagents?id=36 -O ./meshagent
   chmod 755 ./meshagent
   ```

3. Descargar msh:

   1. Entrar a <https://mesh-url/?debug=1>.

   2. Entrar al menú de invitación de grupo.

   3. Seleccionar la última opción para descargar el msh y ponerlo en la misma carpeta que el binario.

4. Crear servicio:

   ```sh
   nano /etc/init.d/meshagent
   ```

   ```sh
   #!/sbin/openrc-run

   command="/root/meshagent"
   command_background="yes"
   pidfile="/run/$RC_SVCNAME.pid"
   name="MeshAgent"

   depend() {
       need net
       after firewall
   }

   start_pre() {
       return 0
   }

   start() {
       ebegin "Starting MeshAgent"
       start-stop-daemon --start --exec $command --background --make-pidfile --pidfile $pidfile
       eend $?
   }

   stop() {
       ebegin "Stopping MeshAgent"
       start-stop-daemon --stop --exec $command --pidfile $pidfile
       eend $?
   }
   ```

   ```sh
   chmod +x /etc/init.d/meshagent
   rc-update add meshagent default
   rc-service meshagent start
   ```
