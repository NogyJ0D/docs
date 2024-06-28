# QEMU Libvirt

- [QEMU Libvirt](#qemu-libvirt)
  - [Instalación](#instalación)
    - [Instalar qemu-base + libvirt + virt-manager en arch](#instalar-qemu-base--libvirt--virt-manager-en-arch)
  - [Comandos](#comandos)
    - [Listar](#listar)
    - [Crear pools](#crear-pools)
    - [Crear disco virtual](#crear-disco-virtual)
    - [Crear máquina virtual](#crear-máquina-virtual)
    - [Convertir imagen](#convertir-imagen)
    - [Cambiar tamaño de disco virtual](#cambiar-tamaño-de-disco-virtual)
  - [Extras](#extras)
    - [Si osinfo-query no encuentra la distro que quiero:](#si-osinfo-query-no-encuentra-la-distro-que-quiero)
    - [Descargar drivers virtio para windows](#descargar-drivers-virtio-para-windows)

---

## Instalación

### Instalar qemu-base + libvirt + virt-manager en arch

<!--```sh
egrep -c "(vmx|svm)" /proc/cpuinfo # Si devuelve > 0, la virtualización está habilitada
pacman -S qemu-full
pacman -S virt-manager # OPCIONAL, GUI para manejar las vms
```-->

```sh
pacman -S qemu-base libvirt virt-viewer virt-manager
systemctl enable --now libvirtd
usermod -aG libvirt $(whoami)
virsh list --all
```

---

## Comandos

### Listar

- VMs: "virsh list --all"
- Pools: "virsh pool-list --all"

### Crear pools

- Uno para isos y otro para discos.

```sh
virsh pool-define-as --name [nombre] --type dir --target [ruta]
virsh pool-start [nombre]
virsh pool-autostart [nombre]
```

### Crear disco virtual

- En pool de discos:

    ```sh
    virsh vol-create-as [nombre pool] [disco].qcow2 [tamaño GB]G --format qcow2
    virsh vol-list [nombre pool]
    ```

### Crear máquina virtual

1. [Tener el disco creado](#crear-disco-virtual).

2. Tener la iso en el pool:

    ```sh
    cp [ruta iso] [ruta pool isos]
    virsh pool-refresh [pool isos]
    virsh vol-list [pool isos]
    ```

3. Instalar OS:

    <!--```sh
    qemu-system-x86_64 -cdrom [iso] -boot order=d -drive file=[disco virtual],format=[raw/qcow2] -m 2[M/G = RAM]
    ```-->

    <!-- ```sh
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
      - -vga: emular GPU. Ej: cirrus | std -->

    ```sh
    virt-install \
      --name [nombre vm] \
      --vcpus $(nproc) \
      --memory [ram MB] \
      --disk vol=[pool discos]/[disco].qcow2 \
      --cdrom vol=[pool isos]/[iso].iso \
      --os-variant [tipo de OS] \
      --network [network=default,model=virtio para NAT] \
      --graphics vnc,listen=0.0.0.0 \
      --noautoconsole
    ```

    - Para buscar la variante del OS: "osinfo-query os"

4. Iniciar vm:

    ```sh
    virsh start [nombre vm]
    ```

5. Conectarse a la vm:

    ```sh
    # Usando virt-viewer
    virt-viewer --connect qemu:///system [nombre vm]
    ```

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

### Si osinfo-query no encuentra la distro que quiero:

- Usar "generic".
- Actualizar base de datos:

   1. Descargar "**osinfo-db-tools**".
   2. [Descargar última base de datos](https://releases.pagure.org/libosinfo/):

      ```sh
      wget -O /tmp/osinfo-db.tar.xz [url]
      ```

   3. Importar base de datos:

      ```sh
      osinfo-db-import --local /tmp/osinfo-db.tar.xz
      ```

### Descargar drivers virtio para windows

- Iso:

    ```sh
    wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso
    ```

- En arch:

    ```sh
    yay -S virtio-win
    # La iso se guarda en /var/lib/libvirt/images
    ```
