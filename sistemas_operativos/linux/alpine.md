# Alpine

---

## Contenido

- [Alpine](#alpine)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

---

## Extras

### Instalar XFCE4

1. Instalar xorg ejecutando "setup-xorg-base".

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