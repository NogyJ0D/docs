# Hyprland

- [Hyprland](#hyprland)
  - [Instalación](#instalación)
    - [Instalar hyprland en arch](#instalar-hyprland-en-arch)
  - [Configuración](#configuración)
  - [Extras](#extras)

---

## Instalación

### Instalar hyprland en arch

1. Instalar hyprland:

    ```sh
    pacman -S hyprland kitty wofi waybar hyprpaper
    mkdir ~/.config/hypr
    cp /usr/share/hyprland/hyprland.conf ~/.config/hypr
    ```

2. Configurar waybar:

    ```sh
    mkdir ~/.config/waybar
    touch ~/.config/waybar/config
    touch ~/.config/waybar/style.css
    ```

---

## Configuración

- Copiar la default de ***/usr/share/hyprland/hyprland.conf*** en ***~/.config/hypr/***.
- Si no se aplica solo, ejecutar: "hyprctl reload".

```conf
# Monitor
monitor=nombre,WidthxHeight,auto,auto # sacar nombre de hyprctl monitors all

# My Programs
$terminal = bitty
$fileManager = dolphin/tunar/x
$browser = firefox

# Autostart
exec-once = $terminal
exec-once = nm-applet & # NetworkManager applet
exec-once = waybar & hyprpaper # Barra de tareas

# Look and feel
general {
    col.active_border = rgb(aabbcc) rgb(aabbcc) 45deg # Borde de ventana activa
    col.inactive_border = rgba(595959aa) # Borde de ventana inactiva

    layout = master o dwindle # Master = todas las ventanas abren a la izquierda y las otras se achican. Dwindle = las ventanas se abren en el cuadro donde tengo foco y las que estan en ese cuadro se acomodan
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
bind = $mainMod, R, exec, $menu
bind = $mainMod, B, exec, $browser

#       Mover ventanas con las flechas
bind = $mainMod ALT, code:37, movewindow, l
bind = $mainMod ALT, code:38, movewindow, u
bind = $mainMod ALT, code:39, movewindow, r
bind = $mainMod ALT, code:40, movewindow, d

#       Ajustar tamaño con las fechas
bind = $mainMod SHIFT, left, resizeactive, -100 0
bind = $mainMod SHIFT, up, resizeactive, 0 -100
bind = $mainMod SHIFT, right, resizeactive, 100 0
bind = $mainMod SHIFT, down, resizeactive, 0 100
```

---

## Extras
