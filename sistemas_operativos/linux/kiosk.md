# Kiosk

- [Kiosk](#kiosk)
  - [Creación](#creación)
  - [Extras](#extras)
    - [Si falta audio](#si-falta-audio)

---

## Creación

1. Instalar Debian 12 sin interfaz.

2. Instalar paquetes:

   ```sh
   apt install xorg openbox lightdm xdotool chromium
   ```

3. Configurar autologon:

   ```sh
   nano /etc/lightdm/lightdm.conf
   ```

   ```conf
   [Seat:*]
   user-session=openbox
   autologin-user=usuario
   autologin-user-timeout=0
   ```

4. Configurar openbox:

   ```sh
   mkdir -p /home/usuario/.config/openbox

   cp /etc/xdg/openbox/rc.xml /home/usuario/.config/openbox
   touch /home/usuario/.config/openbox/menu.xml
   ```

   - Editar el archivo **_/home/usuario/.config/openbox/rc.xml_**

     - Deshabilitar click derecho en el inicio: reemplazar en el bloque \<mousebind button="Right" action="Press"> "mousebind" por "DISABLED".
     - Deshabilitar alt-f4: reemplazar en el bloque \<keybind key="A-F4"> por "C-A-q".
     - Reemplazar en el bloque \<keybind key="A-space"> "keybind" por "DISABLED".

   - Editar el archivo **_/home/usuario/.config/openbox/autostart_**:

     ```xorg
     xset s off
     xset -dpms

     bash /home/usuario/inicio.sh &
     ```

   - Editar el archivo **_/home/usuario/inicio.sh_**:

     ```sh
     #!/bin/bash

     pgrep chromium | xargs kill

     mkdir -p ~/.config/chromium

     chromium --window-position=0,0 --kiosk --user-data-dir=/tmp/chrome1 --disable-features=Translate \
       "URL" &
       CHROME1_PID=$!

     chromium --window-position=0,0 --kiosk --user-data-dir=/tmp/chrome2 --disable-features=Translate \
       "URL" &
       CHROME2_PID=$!

     # Auto refresco
     while true; do
       sleep 300 # 5 minutos

       WINDOWS=($(xdotool search --class "chromium" 2>/dev/null))

       for window in "${WINDOWS[@]}"; do
         xdotool windowactivate $window
         sleep 0.2
         xdotool key F5
         sleep 0.2
       done
     done

     wait
     ```

   ```sh
   chown -R usuario:usuario /home/usuario/.config
   ```

5. Reiniciar.

## Extras

### Si falta audio

- Instalar pulseaudio, pulseaudio-utils, pavucontrol, alsa-utils y probar
