# XEN

- [XEN](#xen)
  - [Instalación](#instalación)
    - [Instalar xen en arch](#instalar-xen-en-arch)
  - [Comandos](#comandos)
  - [Extras](#extras)

---

## Instalación

### Instalar xen en arch

**WIP | NO USAR**

1. Verificar soporte para virtualización

    ```sh
    grep -E "(vmx|svm)" --color=always /proc/cpuinfo
    # Si devuelven algo, la virtualización está activada
    ```

2. Instalar usando [yay](../linux/arch/arch.md#instalar-yay):

    ```sh
    yay -S xen xen-qemu
    yay -S seabios # Soporte BIOS en vms
    yay -S edk2-ovmf # Soporte UEFI en vms
    ```

---

## Comandos

---

## Extras
