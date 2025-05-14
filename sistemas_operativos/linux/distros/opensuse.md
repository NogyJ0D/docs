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
zypper in plasma6-workspace plasma6-session plasma6-desktop konsole sddm xorg-x11-server xinit xorg-x11-driver-input xorg-x11-driver-video

systemctl disable display-manager-legacy.service
systemctl enable sddm
systemctl set-default graphical.target

reboot

# Programas
zypper install dolphin dolphin-plugins MozillaFirefox-branding-upstream
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
    sudo zypper addrepo --refresh https://download.nvidia.com/opensuse/tumbleweed NVIDIA
    sudo zypper install-new-recommends --repo NVIDIA
    ```

  - Fuentes Microsoft:

    ```sh
    sudo zypper in fetchmsttfonts
    ```

- Programas:
  - [VSCode](https://code.visualstudio.com/docs/setup/linux#_opensuse-and-slebased-distributions)
