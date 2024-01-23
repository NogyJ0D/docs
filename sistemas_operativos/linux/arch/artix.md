# Artix

---

## Contenido

- [Artix](#artix)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [¿Qué hacer luego de instalar?](#qué-hacer-luego-de-instalar)
  - [Extras](#extras)

---

## Documentación

---

## ¿Qué hacer luego de instalar?

- Dar color a pacman:

  - Descomentar *"#Color"* en ***/etc/pacman.conf***.

- Actualizar keys:

    ```sh
    sudo pacman-keys -u
    ```

- Instalar básicos:

    ```sh
    sudo pacman -S base-devel git artix-archlinux-support
    ```

- Habilitar repositorios de Arch:
  
  - Descomentar en ***/etc/pacman.conf***:

    ```conf
    # Artix
    [system]
    Include = /etc/pacman.d/mirrorlist

    [world]
    Include = /etc/pacman.d/mirrorlist

    [galaxy]
    Include = /etc/pacman.d/mirrorlist

    [lib32]
    Include = /etc/pacman.d/mirrorlist

    # Arch
    [extra]
    Include = /etc/pacman.d/mirrorlist-arch

    [multilib]
    Include = /etc/pacman.d/mirrorlist-arch
    ```

  - Ejecutar:

      ```sh
      sudo pacman-key --populate archlinux
      ```

  - Opcional: descargar mirrors actualizados:

      ```sh
      wget https://github.com/archlinux/svntogit-packages/raw/packages/pacman-mirrorlist/trunk/mirrorlist -O /etc/pacman.d/mirrorlist-arch
      ```

  - Actualizar paquetes:

      ```sh
      sudo pacman -Syu
      ```

- Instalar yay:

    ```sh
    git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si
    ```

- Instalar drivers Nvidia:

    ```sh
    sudo pacman -S nvidia
    sudo reboot
    ```

---

## Extras
