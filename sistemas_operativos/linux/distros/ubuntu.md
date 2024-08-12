# Ubuntu

---

## Contenido

- [Ubuntu](#ubuntu)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Qué hacer luego de instalar](#qué-hacer-luego-de-instalar)
  - [Extras](#extras)
    - [Configurar interfaces](#configurar-interfaces)

---

## Documentación

---

## Instalación

---

## Qué hacer luego de instalar

---

## Extras

---

### Configurar interfaces

- Archivo de interfaces: ***/etc/netplan/00-installer-config.yaml***.

- Asignar IP fija:

    ```yaml
    network:
      ethernets:
        eth0:
          addresses:
            - x.x.x.x/24
          nameservers:
            addresses:
              - 8.8.8.8
          routes:
            - to: default
              via: x.x.x.x
      version: 2
    ```

- Asignar IP por DHCP:

    ```yaml
    network:
      version: 2
      ethernets:
        eth0:
          dhcp4: yes
    ```

- Guardar cambios:

    ```sh
    sudo netplan apply
    ```