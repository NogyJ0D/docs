# dwm

- [dwm](#dwm)
  - [Instalación](#instalación)
  - [Configuración](#configuración)
  - [Extras](#extras)

---

## Instalación

1. Descargar código fuente:

    ```sh
    mkdir $HOME/dwm_all
    cd $HOME/dwm_all
    wget https://dl.suckless.org/dwm/dwm-6.5.tar.gz
    wget https://dl.suckless.org/tools/dmenu-5.3.tar.gz
    wget https://dl.suckless.org/st/st-0.9.2.tar.gz
    tar xvzf dwm-*.tar.gz
    tar xvzf dmenu-*.tar.gz
    tar xvzf st-*.tar.gz
    rm *.tar.gz
    cd dwm-*
    ```

2. Configurar:

    ```sh
    cp config.def.h config.h
    nano config.h
    sudo make clean install
    
    cd ../dmenu-*
    cp config.def.h config.h
    sudo make clean install

    cd ../st-*
    cp config.def.h config.h
    sudo make clean install
    ```

3. Agregar al display manager:

    ```sh
    su -
    nano /usr/share/xsessions/dwm.desktop
    ```

    ```desktop
    [Desktop Entry]
    Encoding=UTF-8
    Name=dwm
    Comment=Dynamic window manager
    Exec=dwm
    Icon=dwm
    Type=XSession
    ```

---

## [Configuración](https://dwm.suckless.org/customisation/)

---

## Extras
