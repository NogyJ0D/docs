# Kernel

- [Kernel](#kernel)
  - [Compilar kernel](#compilar-kernel)
    - [Debian](#debian)
  - [Extras](#extras)

---

## Compilar kernel

### Debian

1. Instalar básicos:

    ```sh
    apt install build-essential bc python3 bison flex rsync libelf-dev libssl-dev libncurses-dev dwarves
    ```

2. [Descargar kernel](https://kernel.org/):

    ```sh
    wget [link]
    tar xvf [archivo]
    cd [carpeta]
    ```

3. Configurar kernel:

    ```sh
    cp /boot/config-[version] ./.config # Copiar la configuración del kernel en uso para el nuevo
    make .config
    make menuconfig # Menú de configuración
    ```

4. Compilar:

    ```sh
    nproc # Obtener número de nucleos
    time make -j[nucleos]
    time make modules_install -j[nucleos]
    time make install -j[nucleos]
    reboot # Seleccionar el kernel en grub
    ```

---

## Extras
