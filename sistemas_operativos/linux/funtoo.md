# Funtoo

- [Funtoo](#funtoo)
  - [Instalación oficial](#instalación-oficial)
  - [Extras](#extras)

---

## [Instalación oficial](https://www.funtoo.org/Install/Introduction)

- Hecha para:
  - AMD64 x64
  - GPT
  - UEFI
  - Disco sata
  - /home y / junto

1. Identificar el disco:

    ```sh
    lsblk
    ```

2. Particionar disco como GPT:

    ```sh
    gdisk /dev/sda
    ```

   - Borrar particiones

      ```sh
      o
      ```

   - Crear boot

      ```sh
      n
      1
      Enter
      +128M
      EF00
      ```

   - Crear swap

      ```sh
      n
      2
      Enter
      +4G
      8200
      ```

   - Crear root

      ```sh
      n
      3
      Enter
      Enter
      Enter
      ```

   - Guardar

      ```sh
      w
      ```

3. Crear sistemas de archivos:

    ```sh
    mkfs.vfat -F 32 /dev/sda1
    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.ext4 /dev/sda3
    ```

4. Montar archivos:

    ```sh
    mkdir -p /mnt/funtoo
    mount /dev/sda3 /mnt/funtoo
    mkdir /mnt/funtoo/boot
    mount /dev/sda1 /mnt/funtoo/boot
    ```

5. Configurar hora:

    ```sh
    date
    date MMDDhhmmYYYY # mes dia hora minuto año
    hwclock --systohc # Sincronizar con la hora de la mother
    ```

6. Descargar e instalar el stage3:

    ```sh
    cd /mnt/funtoo
    links https://www.funtoo.org/Subarches # Buscar el stage deseado y descargar
    tar --numeric-owner --xattrs --xattrs-include='*' -xpf stage3-xxx.tar.xz
    ```

7. Chroot:

    ```sh
    fchroot /mnt/funtoo
    ping -c 5 google.com # Probar conectividad
    ```

8. Actualizar Portage:

    ```sh
    ego sync
    ```

9. Archivos de configuración:

   - Hora:

      ```sh
      rm -f /etc/localtime
      ln -sf /usr/share/zoneinfo/x /etc/localtime
      ```

   - Idioma sistema:

      ```sh
      echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
      echo "es_AR ISO-8859-1" >> /etc/locale.gen
      locale-gen
      eselect locale list
      eselect locale set [num es_AR]
      eselect locale show
      env-update && source /etc/profile
      ```

   - Idioma paquetes:

      ```sh
      # Buscar soportados en /usr/portage/profiles/desc/l10n.desc y /usr/portage/profiles/desc/linguas.desc
      nano /etc/portage/make.conf
      # Agregar "en_EN es_AR" en L10n="" y LINGUAS=""
      emerge --ask --newuse --deep --with-bdeps=y @world
      emerge media-fonts/noto
      ```

   - Distribución teclado:

      ```sh
      nano -w /etc/conf.d/keymaps
      emerge -av ibus
      ```

10. Instalar kernel:

    ```sh
    emerge -s debian-sources
    emerge -av linux-firmware
    ```

11. Bootloader:

    ```sh
    ls -l /dev/disk/by-uuid/ # Obtener uuids
    nano -w /etc/fstab
    ```

    ```fstab
    UUID=x    /boot   vfat    noauto,noatime    1 2
    UUID=x    none    swap    sw                0 0
    UUID=x    /       ext4    noatime           0 1
    ```

    ```sh
    emerge -av inter-microcode iucode_tool # Solo Intel
    ```

    ```sh
    mount -o remount,rw /sys/firmware/efi/efivars
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Funtoo Linux [GRUB]" --recheck
    ego boot update
    ```

    > In case UEFI NVRAM boot entry is missing in BIOS and grub does not start you can try moving an already installed GRUB EFI executable to the default/fallback path
    > mv -v '/boot/EFI/Funtoo Linux [GRUB]' /boot/EFI/BOOT
    > mv -v /boot/EFI/BOOT/grubx64.efi /boot/EFI/BOOT/BOOTX64.EFI

12. Network:

    - WIFI:

      ```sh
      emerge linux-firmware networkmanager
      rc-update add NetworkManager default
      nmtui # Luego de reiniciar para configurar el wifi
      ```

    - DHCP cableado:

      ```sh
      rc-update add dhcpd default
      ```

    - Hostname:

      ```sh
      nano /etc/conf.d/hostname
      ```

13. Finalizar:

    ```sh
    passwd
    useradd -m [usuario]
    usermod -G wheel,audio,video,plugdev,portage [usuario]
    passwd [usuario]
    emerge haveged
    rc-update add haveged default
    exit
    cd /mnt
    umount -lR funtoo
    reboot
    ```

14. Perfiles:

    ```sh
    epro show
    epro list
    epro flavor [perfil] # Cambiar perfil
    epro mix-in +[mix-in] # Agregar mix-in
    ```

    - Agregar mix-in para video:

      ```sh
      epro mix-in +[gfxcard-intel / gfxcard-amdgpu / gfxcard-nvidia]
      ```

--

## Extras
