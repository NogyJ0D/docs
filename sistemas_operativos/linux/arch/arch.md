# ArchLinux

---

## Contenido

- [ArchLinux](#archlinux)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación (con net iso)](#instalación-con-net-iso)
  - [Qué hacer luego de instalar](#qué-hacer-luego-de-instalar)
    - [Instalar yay](#instalar-yay)
  - [Extras](#extras)
    - [Instalar openbox](#instalar-openbox)

---

## Documentación

---

## Instalación (con net iso)

1. Actualizar:

    ```sh
    pacman -Sy archinstall archlinux-keyring
    ```

2. Mirrors a elegir:

     - Australia
     - Brasil
     - Chile
     - Estados Unidos

3. Agregar paquetes:

   - nano
   - curl
   - git
   - wget

4. Tipos de instalación:

   - **Desktop**: entorno de escritorio.
   - **Minimal**: terminal.
   - [**Openbox**](#instalar-openbox).

---

## Qué hacer luego de instalar

### Instalar yay

```sh
pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

---

## Extras

### [Instalar openbox](https://wiki.archlinux.org/title/openbox)

1. Instalar los paquetes:

    ```sh
    pacman -S xorg-xinit xorg-server openbox xorg-fonts-misc xdg-utils obconf
    ```

2. Configurar Openbox:

   1. Copiar archivo conf:

      ```sh
      cp /etc/X11/xinit/xinitrc ~/.xinitrc
      ```

   2. Editar el archivo copiado, comentando las aplicaciones de xterm y agregando "exec openbox-session" al final.

   3. Ejecutar "startx" para abrir el entorno y salir.

   4. Configurar menú:

      ```sh
      mkdir -p ~/.config/openbox
      cp -a /etc/xdg/openbox/ ~/.config/
      nano ~/.config/openbox/menu.xml # Editar las entradas a gusto
      ```

   5. Persistir configuración:

      ```sh
      export XDG_CONFIG_HOME=$HOME/.config/
      ```

3. Agregar paquetes a gusto:

    ```sh
    pacman -S xterm firefox thunar
    ```

    - Con yay:

        ```sh
        yay -S obmenu
        ```