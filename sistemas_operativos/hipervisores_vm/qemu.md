# QEMU

- [QEMU](#qemu)
  - [Instalación](#instalación)
    - [Instalar qemu en arch](#instalar-qemu-en-arch)
  - [Comandos](#comandos)
    - [Crear máquina virtual](#crear-máquina-virtual)
    - [Convertir imagen](#convertir-imagen)
    - [Cambiar tamaño de disco virtual](#cambiar-tamaño-de-disco-virtual)
  - [Extras](#extras)

---

## Instalación

### Instalar qemu en arch

```sh
egrep -c "(vmx|svm)" /proc/cpuinfo # Si devuelve > 0, la virtualización está habilitada
pacman -S qemu-full
pacman -S virt-manager # OPCIONAL, GUI para manejar las vms
```

---

## Comandos

### Crear máquina virtual

1. Crear disco virtual

    ```sh
    qemu-img create -f [raw/qcow2] [nombre.qcow2] 4G
    ```

2. Instalar OS:

    <!--```sh
    qemu-system-x86_64 -cdrom [iso] -boot order=d -drive file=[disco virtual],format=[raw/qcow2] -m 2[M/G = RAM]
    ```-->

    ```sh
    qemu-system-x86_64 --enable-kvm -display sdl -m 2G -drive file=disco.qcow2,format=qcow2,media=disk,if=virtio -cdrom [iso]
    ```

    - Parámetros opcionales:
      - name 'nombre_vm'.
      - --enable-kvm: habilitar virtualización KVM. RECOMENDADO.
      - -display: display a usar. Ej: gtk | none | sdl | curses
      - -cpu: tipo de cpu a usar. Ej: host
      - -smp: núcleos a usar. Ej: 4,cores=2,threads=2 (2 cores con 2 threads c/u)
      - -net: red. Ej: user (NAT) | nic,model=virtio (interfaz del host)
      - -boot: orden de booteo. Ej: order= c (primer disco) | d (primer cd) | n (network)
      - -vga: emular GPU. Ej: cirrus | std

### Convertir imagen

```sh
qemu-img convert -f raw -O qcow2 [input.img] [output].qcow2
```

### Cambiar tamaño de disco virtual

- Aumentar tamaño:

  1. Ejecutar:

      ```sh
      qemu-img resize [nombre] +10G
      ```

  2. Administrar el disco desde la VM para que use el espacio libre.

- Reducir tamaño:

 1. Reducir el espacio utilizado dentro de la VM.
 2. Ejecutar:

  ```sh
  qemu-img resize --shrink [nombre] -10G
  ```

---

## Extras
