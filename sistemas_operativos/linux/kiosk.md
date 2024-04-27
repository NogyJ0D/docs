# Kiosk

- [Kiosk](#kiosk)
  - [Creación](#creación)

---

## Creación

1. Instalar Debian 12 sin interfaz.

2. Instalar paquetes:

    ```sh
    apt install xorg openbox lightdm firefox-esr
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

    ```sh
    nano /home/usuario/.config/openbox/rc.xml
    ```

    - Reemplazar en el bloque \<mousebind button="Right" action="Press"> "mousebind" por "DISABLED".
    - Reemplazar en el bloque \<keybind key="A-F4"> por "C-A-q".
    - Reemplazar en el bloque \<keybind key="A-space"> "keybind" por "DISABLED".

    ```sh
    nano /root/.config/openbox/autostart
    ```

    ```xorg
    xset s off
    xset -dpms

    firefox --kiosk url &
    ```

5. Reiniciar.
