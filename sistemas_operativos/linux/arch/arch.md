# ArchLinux

---

## Contenido

- [ArchLinux](#archlinux)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación (con net iso)](#instalación-con-net-iso)
  - [Qué hacer luego de instalar](#qué-hacer-luego-de-instalar)
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

4. Tipos de instalación:

   - **Desktop**: entorno de escritorio.
   - **Minimal**: terminal.
   - [**Openbox**](#instalar-openbox): seleccionar el tipo **Minimal** y en los paquetes a instalar agregar "openbox", "ttf-dejavu" y "ttf-liberation".
---

## Qué hacer luego de instalar

---

## Extras

### [Instalar openbox](https://wiki.archlinux.org/title/openbox)

1. Instalar los paquetes:

    ```sh
    pacman -S xorg-xinit openbox
    ```

