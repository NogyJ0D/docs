# QEMU Libvirt

- [QEMU Libvirt](#qemu-libvirt)
  - [Instalación](#instalación)
    - [Instalar qemu-base + libvirt + virt-manager en arch](#instalar-qemu-base--libvirt--virt-manager-en-arch)
  - [Comandos](#comandos)
    - [Listar](#listar)
    - [Pools](#pools)
    - [Ver información del host](#ver-información-del-host)
    - [Crear disco virtual](#crear-disco-virtual)
    - [Crear máquina virtual](#crear-máquina-virtual)
    - [Convertir imagen](#convertir-imagen)
    - [Cambiar tamaño de disco virtual](#cambiar-tamaño-de-disco-virtual)
    - [CDROM](#cdrom)
    - [Snapshots](#snapshots)
  - [Extras](#extras)
    - [Si osinfo-query no encuentra la distro que quiero](#si-osinfo-query-no-encuentra-la-distro-que-quiero)
    - [Descargar drivers virtio para windows](#descargar-drivers-virtio-para-windows)
    - [Si Windows no tiene internet](#si-windows-no-tiene-internet)

---

## Instalación

- Para usar libvirt como root, modificar en el archivo **_/etc/libvirt/qemu.conf_** y reiniciar **libvirtd**:

    ```sh
    user = "root"
    group = "root"
    ```

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

### Pools

- Crear pool:

  - Uno para isos y otro para discos.

    ```sh
    virsh pool-define-as [pool] dir - - - - "[ruta]"
    virsh pool-build [pool]
    virsh pool-start [pool]
    virsh pool-autostart [pool]
    ```

- Borrar pool:

    ```sh
    virsh pool-destroy [pool]
    virsh pool-delete [pool]
    virsh pool-undefine [pool]
    ```

### Ver información del host

```sh
virsh sysinfo
virsh hostname
```

### Crear disco virtual

- En pool de discos:

    ```sh
    virsh vol-create-as [nombre pool] [disco].qcow2 [tamaño GB]G --format qcow2
    virsh vol-list [nombre pool]
    ```

- Con qemu:

    ```sh
    qemu-img create -f qcow2 [ruta].qcow2 [tamaño]G
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
      --disk [ruta disco].qcow2 \
      --cdrom [ruta iso].iso \
      --os-variant [tipo de OS ó "generic"] \
      --network [network=default,model=virtio para NAT] \
      --graphics vnc,listen=0.0.0.0 \
      --noautoconsole
      --noreboot
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

### CDROM

- Agregar media:

    ```sh
    virsh dumpxml [vm] # Buscar el target del media. EJ: sdb
    virsh change-media [vm] [target] --insert [ruta disco]
    ```

- Quitar media:

    ```sh
    virsh dumpxml [vm] # Buscar el target del media. EJ: sdb
    virsh change-media [vm] [target] --eject
    ```

### Snapshots

- Crear snapshot:

    ```sh
    virsh snapshot-create-as --domain [vm] --name [nombre snapshot] --description "[descripción]"
    ```

- Información:

    ```sh
    virsh snapshot-list [vm]
    virsh snapshot-info [vm] [snapshot]
    qemu-img info /var/lib/libvirt/images/[imagen]
    ```

- Revertir a snapshot:

    ```sh
    virsh snapshot-revert [vm] [snapshot]
    ```

- Borrar snapshot:

    ```sh
    virsh snapshot-delete [vm] [snapshot]
    ```

---

## Extras

### Si osinfo-query no encuentra la distro que quiero

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

- [Iso](https://github.com/virtio-win/virtio-win-pkg-scripts/blob/master/README.md)
- En arch:

    ```sh
    yay -S virtio-win
    # La iso se guarda en /var/lib/libvirt/images
    ```

### Si Windows no tiene internet

1. Descargar [driver virtio](#descargar-drivers-virtio-para-windows).
2. [Agregar el disco a la VM](#cdrom).
3. En la vm ir a "Administración de Dispositivos" y buscar el desconocido llamado "Ethernet Controller", buscar actualización y seleccionar la carpeta "NetKVM" del disco del driver.