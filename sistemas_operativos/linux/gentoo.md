# Gentoo

- [Gentoo](#gentoo)

---

## [Instalación](https://github.com/tuxtor/manual-instalacion-gentoo/blob/master/manual.md)

1. Descargar la ISO __install-amd65-minimal__ <https://www.gentoo.org/downloads/mirrors/> ubicado en ___/gentoo/releases/amd64/autobuilds/ultima___.

2. Verificar la interfaz de red:

    ```sh
    ifconfig
    ```

3. [Preparar el disco](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Disks#Partitioning_the_disk_with_GPT_for_UEFI):

   1. Crear particiones:

      ```sh
      fdisk /dev/sda
      ```

      - p: mostrar particiones.
      - g: borrar todas las particiones y arrancar en GPT.
      - d: borrar una partición.
      - n: crear particion EFI.
      - w: guardar cambios.

      1. Seleccionar gpt = g

      2. /dev/sda1 - /boot - 100MB - ext2:

          ```sh
          n
          1
          Enter
          +100M
          t
          1
          ```

      3. /dev/sda2 - /swap - 4G o doble de la ram:

          ```sh
          n
          2
          Enter
          +4G
          t
          2
          19
          ```

      4. /dev/sda3 - / - Resto - ext4:

          ```sh
          n
          3
          Enter
          Enter
          t
          3
          23
          w
          ```

   2. Formatear particiones:

        ```sh
        mkfs.ext2 /dev/sda1
        mkswap /dev/sda2
        mkfs.ext4 /dev/sda3
        swapon /dev/sda2
        ```

   3. Montar particiones:

      ```sh
      mount /dev/sda3 /mnt/gentoo
      mkdir /mnt/gentoo/boot
      mount /dev/sda1 /mnt/gentoo/boot
      ```

4. Descargar el stage

   - Buscar el estage /gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc en los mirrors.

    ```sh
    cd /mnt/gentoo
    wget https://gentoo.zero.com.ar/gentoo/releases/amd64/autobuilds/current-stage3-amd64-desktop-openrc/stage3-amd64-desktop-openrc-ultimo.tar.xz
    tar xvJf stage3-amd...tar.xz
    ```

5. Configurar portage:

   1. Obtener CPU del archivo ___/proc/cpuinfo___.

   2. Buscar las Safe CFLAGS para el procesador en: <https://wiki.gentoo.org/wiki/Safe_CFLAGS>.

   3. Agregar CFLAGS en ./etc/portage/make.conf

      - Ryzen 3000, 4000, 5000, 7xx2: "-O2 -march=znver2 -pipe"

   4. Agregar mirrors:

      ```sh
      mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
      mirrorselect -i -r -o >> /mnt/gentoo/etc/portage/make.conf
      cp -L /etc/resolv.conf /mnt/gentoo/etc/resolv.conf
      ```

6. chroot:

    ```sh
    mount -t proc none /mnt/gentoo/proc
    mount --rbind /sys /mnt/gentoo/sys
    mount --rbind /dev /mnt/gentoo/dev
    chroot /mnt/gentoo /bin/bash
    export PS1="chroot $ "
    mkdir /usr/portage
    emerge-webrsync
    ```

7. Seleccionar un perfil:

   - Para usar xfce openrc: (23) default/linux/amd64/23.0/desktop

    ```sh
    eselect profile list
    eselect profile set x
    ```

8. Agregar kernel:

    ```sh
    echo 'ACCEPT_LICENSE="*"' >> /etc/portage/make.conf
    emerge gentoo-sources
    emerge genkernel
    ln -s /usr/src/linux-xxx /usr/src/linux
    genkernel all
    ```

9. Configurar fstab en el archivo ___/etc/fstab___:

    ```fstab
    /dev/sda1   /boot   ext2    noauto,noatime    1 2
    /dev/sda3   /       ext4    noatime           0 1
    /dev/sda2   none    swap    sw                0 0

    /dev/cdroom   /mnt/cdroom   auto    noauto,ro   0 0
    /dev/fd0      /mnt/floppy   auto    noauto      0 0
    ```

10. Extras

    - Agregar el hostname en el archivo ___/etc/conf.d/hostname___.

    - Levantar dhcp:

        ```sh
        echo 'config_\<nombre interfaz\>=("dhcp")' >> /etc/conf.d/net
        cd /etc/init.d
        ln -s net.lo net.\<nombre interfaz\>
        rc-update add net.\<nombre interfaz\> default
        ```

    - Agregar contraseña a root con "passwd".

    - Agregar el keymap "es" en ___/etc/conf.d/keymaps___.

    - Descomentar "clock_systohc" en ___/etc/conf.d/hwclock___.

    ```sh
    echo "es_AR.UTF-8 UTF-8" >> /etc/locale.gen
    echo "es_AR ISO-8859-1" >> /etc/locale.gen
    locale-gen
    ```

    - Agregar en ___/etc/env.d/02locale___:

        ```ini
        LANG="es_AR.UTF-8"
        LANGUAGE="es_AR.UTF-8"
        LC_COLLATE="C"
        ```

        ```sh
        env-update && source /etc/profile
        ```

11. Instalar herramientas del sistema

    ```sh
    cd
    emerge syslog-ng && rc-update add syslog-ng default
    emerge dcron && rc-update add dcron default
    emerge mlocate
    emerge net-misc/dhcpcd
    ```

12. Instalar grub

    ```sh
    emerge grub
    ls /boot/kernel* /boot/initramfs* # Obtener la versión del kernel
    nano /boot/grub/grub.conf
    ```

    ```conf
    default 0
    timeout 5
    title Gentoo
    root (hd0,0)
    kernel /boot/kernel-genkernel-x86_64-xxx real_root=/dev/sda3
    initrd /boot/initramfs-genkernel-x86_64-xxx
    ```

    ```sh
    grep -v rootfs /proc/mounts > /etc/mtab
    grub-install --no-floppy /dev/sda
    ```

    ```sh
    exit
    cd
    umount -l /mnt/gentoo/dev{/shm,/pts,}
    umount -l /mnt/gentoo{/boot,/proc,}
    reboot
    ```

13. Agregar usuarios básicos:

    ```sh
    useradd -m -G users,wheel,audio,cdrom,usb,video -s /bin/bash usuario
    passwd usuario
    ```

    ```sh
    rm /stage3-*.tar.xz*
    ```

14. Gentoo instalado, instalar paquetes básicos:

    - [ALSA](http://www.gentoo.org/doc/es/alsa-guide.xml) (sonido)
    - Gnome
    - KDE
    - XFCE

---

## Comandos

---

## Paquetes

---

## Extras