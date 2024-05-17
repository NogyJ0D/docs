# Hyprland

- [Hyprland](#hyprland)
  - [Instalación](#instalación)
    - [Instalar hyprland en arch](#instalar-hyprland-en-arch)
  - [Extras](#extras)

---

## Instalación

### Instalar hyprland en arch

- Componentes:
  - hyprland.
  - kitty: terminal.
  - wofi: menú de aplicaciones.
  - swaylock-effects: menú de sesión.
  - thunar: gestor de archivos.
  - hyprpaper: gestor de wallpapers.
  - mako: gestor de notificaciones.
  - swayidle: daemon de inactividad.

1. Instalar grupo:

    ```sh
    pacman -S sddm hyprland wofi kitty thunar hyprpaper swayidle ttf-cascadia-code-nerd gvfs ttf-joypixels thunar-volman pavucontrol nm-connection-editor otf-font-awesome
    yay -S swaylock-effects hyprshot pxplus-ibm-vga8
    mkdir ~/.config/
    #cp /usr/share/hyprland/hyprland.conf ~/.config/hypr
    
    ```

2. Aplicar configuración de respositorio como link simbólico:

      ```sh
      ln -s docs/sistemas_operativos/linux/estilo/.config/hypr $HOME/.config/
      ln -s docs/sistemas_operativos/linux/estilo/.config/wofi $HOME/.config/
      ln -s docs/sistemas_operativos/linux/estilo/.config/kitty $HOME/.config/
      ln -s docs/sistemas_operativos/linux/estilo/.config/mako $HOME/.config/
      ln -s docs/sistemas_operativos/linux/estilo/.config/waybar $HOME/.config/
      ```

3. Configurar monitores en $HOME/.config/hypr_monitors.conf:

    ```conf
    monitor=monitor,res,pos,auto
    monitor=monitor2,res,pos,auto
    ```

4. Configurar hyprpaper:

    - Agregar en ***~/.config/hypr/hyprpaper.conf***:

    ```conf
    preload = /home/user/imagenes
    wallpaper = monitor,/home/user/imagenes/imagen.png
    ```

---

## Extras
