# Hyprland

- [Hyprland](#hyprland)
  - [Instalación](#instalación)
    - [Instalar hyprland en arch](#instalar-hyprland-en-arch)
  - [Configuración](#configuración)
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
    pacman -S sddm hyprland wofi kitty thunar hyprpaper swayidle ttf-cascadia-code
    yay -S swaylock-effects
    mkdir -p ~/.config/hypr
    cp /usr/share/hyprland/hyprland.conf ~/.config/hypr
    ```

    - [Configurar hyprland](#configuración).

2. Configurar wofi:

    ```sh
    mkdir ~/.config/wofi
    nano ~/.config/wofi/style.css
    ```

    ```css
    * {
      border-radius: 5px;
    }

    window {
      font-size: 14px;
      font-family: Cascadia Mono;
      background-color: rgba(50, 50, 50, 0.9);
      color: white;
      #border-color: linear-gradient(to right, #f12711, #f5af19);
      border-bottom: 3px solid white;
    }

    #entry:selected {
      background-color: #bbccdd;
      color: #333333;
      background: linear-gradient(to right, #bbccdd, #dd77ff);
    }

    #text:selected {
      color: #333333;
    }

    #input {
      background-color: rgba(50,50,50,0.5);
      color: white;
      padding: 0.25rem;
      font-weight: 700;
    }

    #entry {
      padding: 0.25rem;
    }

    image {
      margin-left: 0.25rem;
      margin-right: 0.25rem;
    }
    ```

3. Configurar hyprpaper:

    - Agregar en ***~/.config/hypr/hyprpaper.conf***:

    ```conf
    preload = /home/user/imagenes
    wallpaper = monitor,/home/user/imagenes/imagen.png
    ```

4. Configurar mako:

    ```sh
    mkdir ~/.config/mako
    nano ~/.config/mako/config
    ```

    ```conf
    background-color=#222222
    text-color=#ffffff
    border-color=#444444
    border-size=2
    padding=10
    font=Cascadia Mono 12
    ```

---

## Configuración

- Copiar la default de ***/usr/share/hyprland/hyprland.conf*** en ***~/.config/hypr/***.
- Si no se aplica solo, ejecutar: "hyprctl reload".

```conf
# Monitor
monitor=nombre,WidthxHeight,auto,auto # sacar nombre de hyprctl monitors all

# My Programs
$terminal = kitty
$fileManager = dolphin/tunar/x
$menu = wofi --show drun -I
$browser = firefox

# Autostart
# exec-once = nm-applet & # NetworkManager applet
# exec-once = waybar & hyprpaper # Barra de tareas
exec-once = hyprpaper
exec-once = swaidle -w timeout 900 'swaylock --clock --indicator --screenshots --effect-greyscale --effect-pixelate 10 --effect-scale 1.1 --scaling center --indicator-radius 100 --indicator-thickness 10 --ring-color bd93f9 --inside-color 282a36 --line-color 000000 --key-hl-color ff79c6' # 900 segundos, 15 minutos

# Look and feel
general {
    col.active_border = rgb(aabbcc) rgb(aabbcc) 45deg # Borde de ventana activa
    col.inactive_border = rgba(595959aa) # Borde de ventana inactiva

    layout = master o dwindle (mejor) # Master = todas las ventanas abren a la izquierda y las otras se achican. Dwindle = las ventanas se abren en el cuadro donde tengo foco y las que estan en ese cuadro se acomodan
}

misc {
    force_default_wallpaper = 1
    disable_hyprland_logo = true
}

# Input
input {
    kb_layout = es o latam
}

# Keybindings
bind = $mainMod, Q, exec, $terminal
bind = $mainMod, ESC, exit, # Reemplazar M
bind = $mainMod, R, exec, $menu
bind = $mainMod, B, exec, $browser
bind = $mainMod, M, fullscreen, 1 # Maximizar ventana
bind = $mainMod, L, exec, swaylock --clock --indicator --screenshots --effect-greyscale --effect-pixelate 10 --effect-scale 1.1 --scaling center --indicator-radius 100 --indicator-thickness 10 --ring-color bd93f9 --inside-color 282a36 --line-color 000000 --key-hl-color ff79c6

#       Mover ventanas con las flechas
bind = $mainMod ALT, left, movewindow, l
bind = $mainMod ALT, up, movewindow, u
bind = $mainMod ALT, right, movewindow, r
bind = $mainMod ALT, down, movewindow, d

#       Ajustar tamaño con las fechas
bind = $mainMod SHIFT, left, resizeactive, -100 0
bind = $mainMod SHIFT, up, resizeactive, 0 -100
bind = $mainMod SHIFT, right, resizeactive, 100 0
bind = $mainMod SHIFT, down, resizeactive, 0 100
```

---

## Extras
