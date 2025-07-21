# CachyOS

---

## Comandos

---

## Paquetes

---

## Extras

- Generar configuración de snapper y añadir al grub:

  ```sh
  sudo pacman -S cachyos-snapper-support grub-btrfs grub-btrfs-support inotify-tools
  sudo systemctl enable --now grub-btrfsd
  ```

- Si winetricks tiene problema con una ruta:

  ```sh
  sudo winetricks --self-update
  # Si cambia, instalar tambien aur/protontricks-git (reemplazando protontricks)
  ```
