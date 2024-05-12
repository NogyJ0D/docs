# ArchLinux

- [ArchLinux](#archlinux)
  - [Documentación](#documentación)
  - [Instalación oficial](#instalación-oficial)
  - [Instalación archinstall (con net iso)](#instalación-archinstall-con-net-iso)
  - [Extras](#extras)
    - [Instalar yay](#instalar-yay)
    - [Instalar Pipewire (audio)](#instalar-pipewire-audio)
    - [Instalar libreoffice](#instalar-libreoffice)
    - [Instalar openbox](#instalar-openbox)
    - [Instalar XFCE](#instalar-xfce)
    - [Instalar Mate](#instalar-mate)
    - [Instalar Plasma](#instalar-plasma)
    - [Instalar Steam](#instalar-steam)

---

## Documentación

---

## [Instalación oficial](https://wiki.archlinux.org/title/Installation_guide)

- Pensado para:
  - x86_64
  - GPT
  - UEFI
  - / y /home juntos
  - GRUB

1. Teclado:

    ```sh
    loadkeys es
    ```

2. Verificar modo de booteo:

    ```sh
    cat /sys/firmware/efi/fw_platform_size
    ```

    - Si retorna 64: el boot es UEFI x64.
    - Si retorna 32: el boot es UEFI x86.
    - Si el archivo no existe: el boot es BIOS.

3. Revisar la conexión:

    ```sh
    ip link
    ip a
    ping google.com
    ```

4. Configurar reloj:

    ```sh
    timedatectl
    timedatectl set-timezone America/Argentina/Buenos_Aires
    ```

5. Configurar el disco

   1. Particionar el disco:

      ```sh
      lsblk
      gdisk /dev/sda
      ```

       - Limpiar tabla:

         ```sh
         o
         ```

       - /

         ```sh
         n
         1
         Enter
         +128M
         EF00
         ```

       - swap

         ```sh
         n
         2
         Enter
         +4G
         8200
         ```

       - /home

         ```sh
         n
         3
         Enter
         Enter
         8300
         ```

       ```sh
       w
       ```

   2. Formatear particiones:

      ```sh
      mkfs.vfat -F 32 /dev/sda1
      mkswap /dev/sda2
      swapon /dev/sda2
      mkfs.ext4 /dev/sda3
      ```

   3. Montar las particiones:

      ```sh
      mount /dev/sda3 /mnt
      mkdir -p /mnt/boot/efi
      mount -t vfat /dev/sda1 /mnt/boot/efi
      ```

6. Instalar básicos:

    ```sh
    pacstrap -K /mnt base linux linux-firmware nano
    ```

7. Configurar el sistema:

   1. fstab:

      ```sh
      genfstab -U /mnt >> /mnt/etc/fstab
      ```

   2. chroot:

      ```sh
      arch-chroot /mnt
      ```

   3. NetworkManager:

      ```sh
      pacman -S networkmanager
      systemctl enable --now NetworkManager
      ```

   4. Tiempo y teclado:

      ```sh
      ln -sf /usr/share/zoneinfo/America/Argentina/Buenos_Aires /etc/localtime
      hwclock ---systohc
      echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
      echo "es_AR ISO-8859-1" >> /etc/locale.gen
      locale-gen
      echo "LANG=es_AR.UTF-8" > /etc/locale.conf
      echo "KEYMAP=es" > /etc/vconsole.conf
      ```

   5. Hostname:

      ```sh
      echo "hostname" > /etc/hostname
      ```

   6. Contraseña:

      ```sh
      passwd
      ```

8. GRUB:

    ```sh
    pacman -S grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi/ --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
    efibootmgr --create --disk /dev/sda --part 1 --label "GRUB" --loader /EFI/GRUB/grubx64.efi
    exit
    reboot
    ```

9. Post install:

   1. Usuario con sudo:

      ```sh
      pacman -S base-devel git
      useradd -m [usuario]
      passwd [usuario]
      usermod -aG wheel usuario # Permitir sudo
      nano /etc/sudoers # Descomentar la linea %wheel ALL=(ALL:ALL) ALL
      ```

   2. Actualizar hora:

      ```sh
      pacman -S chrony
      systemctl enable --now chronyd
      hwclock --systohc
      ```

   - Revisar:
     - [SSD](../general.md#soporte-para-ssd)

## Instalación archinstall (con net iso)

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

<!-----

## Qué hacer luego de instalar

### Ordenar mirrors

```sh
sudo pacman -S reflector

sudo systemctl enable --now reflector.timer

reflector --latest 10 --sort rate --protocol https --save /etc/pacman.d/mirrorlist
```-->

---

## Extras

### Instalar yay

```sh
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

### Instalar Pipewire (audio)

```sh
pacman -Rdd pulseaudio
pacman -S pipewire pipewire-{alsa,jack,media-session,pulse}
```

### Instalar libreoffice

```sh
pacman -S libreoffice-fresh libreoffice-fresh-es
```

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

### [Instalar XFCE](https://wiki.archlinux.org/title/xfce)

  ```sh
  pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter

  systemctl enable lightdm
  ```

### [Instalar Mate](https://wiki.archlinux.org/title/MATE)

   ```sh
   pacman -S mate mate-extras lightdm lightdm-gtk-greeter

   systemctl enable lightdm

   nano /etc/lightdm/lightdm.conf # Modificar user-session=mate
   ```

- Modificar la distribución de teclado desde el centro de control.

### Instalar Plasma

```sh
pacman -S plasma sddm
systemctl enable sddm
reboot
```

### [Instalar Steam](https://wiki.archlinux.org/title/steam)

1. Habilitar el repositorio multilib:

   ```sh
   nano /etc/pacman.conf # Descomentar [multilib] al fondo
   pacman -Sy
   ```

2. Descargar steam:

   - Hay que elegir un driver para vulkan:
      - Si se tiene el driver nouveau de nvidia (que viene por defecto en el kernel) usar vulkan-nouveau
      - Si se tiene el driver propietario de nvidia, usar nvidia-utils.

    ```sh
    pacman -S steam
    ```
