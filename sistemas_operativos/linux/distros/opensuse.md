# OpenSuse

## Contenido

- [OpenSuse](#opensuse)
  - [Contenido](#contenido)
  - [Comandos](#comandos)
  - [Instalación](#instalación)
    - [Primeros pasos](#primeros-pasos)
    - [Instalar KDE en modo servidor](#instalar-kde-en-modo-servidor)
  - [Extras](#extras)

---

## Comandos

1. Paquetes:

   ```sh
   zypper up # upgrade - Actualizar paquetes
   zypper dup # Dist-Upgrade - Actualizar distro
   zypper in [paquete] # install - Instalar paquete
   zypper se [paquete] # search - Buscar paquete
   zypper info [paquete] # Info del paquete
   ```

---

## Instalación

### Primeros pasos

1. Editar en **_/etc/zypp/zypper.conf_**:

   ```conf
   [solver]
   installRecommends = no

   [color]
   # Descomentar todo
   ```

   ```sh
   sudo zypper up
   ```

### Instalar KDE en modo servidor

```sh
# Entorno gráfico
zypper in plasma6-workspace plasma6-session plasma6-desktop sddm xorg-x11-server xinit xorg-x11-driver-input xorg-x11-driver-video
# Eso usa wayland, para tener xorg agregar: kwin6-x11 plasma6-session-x11

# Programas
zypper in konsole yakuake dolphin dolphin-plugins MozillaFirefox-branding-upstream udisks2 zsh yast2-control-center-qt spectacle gwenview

# Audio
zypper in plasma6-pa pipewire-pulseaudio pipewire-libjack-0_3 pipewire-alsa wireplumber-audio

systemctl disable display-manager-legacy.service
systemctl enable sddm
systemctl set-default graphical.target

reboot
```

---

## Extras

- Instalar básicos:

  - codecs non-free

    ```sh
    sudo zypper in opi
    sudo opi codecs
    ```

  - [Drivers propietarios NVIDIA](https://en.opensuse.org/SDB:NVIDIA_drivers):

    ```sh
    sudo zypper install openSUSE-repos-Tumbleweed-NVIDIA
    ```

  - Fuentes Microsoft:

    ```sh
    sudo zypper in fetchmsttfonts
    ```

- Programas:

  - [VSCode](https://code.visualstudio.com/docs/setup/linux#_opensuse-and-slebased-distributions)
  - [Docker](https://en.opensuse.org/Docker):

    ```sh
    sudo zypper in docker docker-compose docker-compose-switch
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    newgrp docker
    sudo systemctl restart docker
    docker version
    docker run --rm hello-world
    ```

  - Libreoffice:

    ```sh
    sudo zypper in libreoffice libreoffice-qt6 libreoffice-writer libreoffice-calc libreoffice-impress
    # libreoffice-draw libreoffice-base libreoffice-math
    ```
