# Proxmox

- [Proxmox](#proxmox)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Comandos](#comandos)
    - [Listar vms](#listar-vms)
    - [Información de la vm](#información-de-la-vm)
    - [Listar discos en los storages](#listar-discos-en-los-storages)
    - [Información de los discos virtuales](#información-de-los-discos-virtuales)
    - [Crear vm vacía](#crear-vm-vacía)
  - [Extras](#extras)
    - [Agregar disco como btrfs para vms](#agregar-disco-como-btrfs-para-vms)
    - [Modificar tamaño de un disco](#modificar-tamaño-de-un-disco)
    - [Cambiar VMID](#cambiar-vmid)
    - [Crear vm debian template](#crear-vm-debian-template)
    - [Migrar VM de un proxmox a otro](#migrar-vm-de-un-proxmox-a-otro)
    - [Crear VM usando configuración de una existente](#crear-vm-usando-configuración-de-una-existente)
    - [Borrar partición LVM](#borrar-partición-lvm)

---

## Documentación

---

## Instalación

---

## Comandos

### Listar vms

```sh
qm list
```

### Información de la vm

```sh
qm config <id>
```

### Listar discos en los storages

```sh
pvesm list <storage>
# pvesm list local
```

### Información de los discos virtuales

```sh
lvdisplay | grep vm-<id>
# O
pvesm path <storage>:<disco>
# EJ: pvesm path local-lvm-vms:vm-107-disk-0
```

### Crear vm vacía

```sh
qemu create <id>
qemu create <id> --name <nombre>
```

---

## Extras

### Agregar disco como btrfs para vms

1. Identificar el disco con `fdisk -l`.
2. Formatearlo como btrfs: `mkfs.btrfs /dev/sdx -L vm-storage`.
3. Crear punto de montaje con `mkdir /mnt/vm-storage` y montar `mount /dev/sdx /mnt/vm-storage`.
4. Copiar el UUID con `blkid /dev/sdx` y agregar a `/etc/fstab`:

   ```text
   UUID=XXXX-XXXX /mnt/vm-storage btrfs defaults,noatime 0 0
   ```

5. Agregar como storage en proxmox:

   ```sh
   pvesm add btrfs vm-storage \
     --path /mnt/vm-storage
     --content images,rootdir
   ```

### Modificar tamaño de un disco

> Creo que solo funciona con disco virtio, no estoy seguro.

```sh
lvm lvreduce -L <-30g / +30g> <storage>/<disco>
qm rescan
```

- Reducir disco lvm:

  > ⚠️ Falta algo y falla, mejor no usar ⚠️
  1. Bootear en la vm con systemrescue.
  2. Hacer un checkeo con `2fsck -f /dev/debian-vg/root`.
  3. Reducir el tamaño dejando 500M reservados (si quiero 11G pongo 10.5G): `resize2fs /dev/debian-vg/root 10500M`.
  4. Reducir el LV: `lvreduce -L 11G /dev/debian-vg/root`.
  5. Ajustar el filesystem al LV: `resize2fs /dev/debian-vg/root`.
  6. Reducir las particiones:

     ```sh
     pvresize --setphysicalvolumesize 12.5G /dev/sda5

     parted /dev/sda

     resizepart 5 13.5GB # boot ~1GB + LVM ~12GB + margen
     resizepart 2 13.5GB
     quit
     ```

  7. Actualizar el kernel: `partprobe /dev/sda`.
  8. Apagar con `poweroff` y ajustar en proxmox:

     ```sh
     qm stop VMID
     qemu-img resize --shrink /var/lib/vz/images/VMID/vm-VMID-disk-0.qcow2 13.5G
     ```

  9. Prender y revisar con `lsblk`, `pvs` o `df -h`.

### Cambiar VMID

```sh
qm stop VMID_VIEJO
vzdump VMID_VIEJO --storage local --mode stop
qmrestore /var/lib/pve/local/dump/vzdump-qemu-VMID_VIEJO-*.vma VMID_NUEVO
qm destroy VMID_VIEJO
```

### Crear vm debian template

- Al instalar la vm base:
  - Disco: 10-12 GB.
  - CPU/RAM: mínimo, se ajusta al clonar.
  - Habilitar QEMU Guest Agent
  - Tipo de disco: VirtIO SCSI
  - Recordar instalar como **LVM** para hacer fácil el resize.
- Comandos para la vm template:

  ```sh
  # Actualizar
  apt update && apt upgrade -y

  # QEMU Guest Agent
  apt install -y qemu-guest-agent
  systemctl enable --now qemu-guest-agent

  # Herramientas básicas
  apt install -y curl wget vim htop git net-tools

  # Limpiar antes de convertir
  apt clean
  ```

- Comandos antes de convertir la vm a template:

  ```sh
  # Limpiar machine-id
  truncate -s 0 /etc/machine-id
  rm /var/lib/dbus/machine-id
  ln -s /etc/machine-id /var/lib/dbus/machine-id

  # Limpiar historial y logs
  history -c
  truncate -s 0 /var/log/*.log

  # Limpiar llaves ssh
  rm /etc/ssh/ssh_host_*
  ```

- Comandos para cada vm una vez clonada:

  ```sh
  systemd-machine-id-setup
  dpkg-reconfigure openssh-server

  hostnamectl set-hostname nuevo-nombre
  sed -i "s/viejo-nombre/nuevo-nombre/g" /etc/hosts

  vgrename viejo-nombre-vg nuevo-nombre-vg
  sed -i "s/viejo--nombre/nuevo--nombre/g" /etc/fstab
  sed -i "s/viejo--nombre/nuevo--nombre/g" /boot/grub/grub.cfg
  sed -i "s/viejo--nombre/nuevo--nombre/g" /etc/initramfs-tools/conf.d/resume
  update-initramfs -c -k all

  reboot -f
  update-grub
  reboot
  ```

### Migrar VM de un proxmox a otro

- [Obtener locación del disco de la vm](#información-de-los-discos-virtuales).

1. Exportar disco a qcow2:

   ```sh
   qemu-img convert -O qcow2 -p -f raw <ruta disco> <destino>.qcow2
   ```

2. Pasar qcow2 al otro servidor (con scp o usb).

3. Crear la nueva vm [vacía](#crear-vm-vacía) o con la interfaz.

4. Importar qcow2 a la vm:

   ```sh
   qm disk import <id> <.qcow2> <storage>
   # EJ: qm disk import 104 vm-ej-disk-0.qcow2 local-lvm
   ```

5. Ir al panel de la vm y agregar el disco:
   1. En Hardware agregar disco.

   2. En Options modificar el orden de boot.

6. En el panel de la vm modificar las opciones para que quede como el original.

7. Borrar qcow2 residual en origen y destino.

### Crear VM usando configuración de una existente

Guardar el siguiente script en el pve, agregar permiso de ejecución y ejecutar como "**./clone_vm.sh ID**":

```sh
#!/bin/bash

# Comprueba si se proporcionó un ID de VM
if [ -z "$1" ]; then
  echo "Uso: $0 <VMID>"
  exit 1
fi

VMID=$1

# Obtiene la configuración de la VM
CONFIG=$(qm config $VMID)

# Extrae la información relevante
NAME=$(echo "$CONFIG" | grep '^name:' | cut -d ' ' -f 2)
MEMORY=$(echo "$CONFIG" | grep '^memory:' | cut -d ' ' -f 2)
CORES=$(echo "$CONFIG" | grep '^cores:' | cut -d ' ' -f 2)
SOCKETS=$(echo "$CONFIG" | grep '^sockets:' | cut -d ' ' -f 2)
CPU=$(echo "$CONFIG" | grep '^cpu:' | cut -d ' ' -f 2)
NET=$(echo "$CONFIG" | grep '^net0:' | cut -d ' ' -f 2-)
SCSI0=$(echo "$CONFIG" | grep '^scsi0:' | cut -d ' ' -f 2-)
OSTYPE=$(echo "$CONFIG" | grep '^ostype:' | cut -d ' ' -f 2)
BOOT=$(echo "$CONFIG" | grep '^boot:' | cut -d ' ' -f 2-)
AGENT=$(echo "$CONFIG" | grep '^agent:' | cut -d ' ' -f 2)

# Construye el comando de creación de VM
CREATE_CMD="qm create \$NEW_VMID --name $NAME-clone --memory $MEMORY --cores $CORES --sockets $SOCKETS --cpu $CPU --net0 $NET --ostype $OSTYPE --boot $BOOT"

if [ "$AGENT" == "1" ]; then
  CREATE_CMD+=" --agent 1"
fi

if [[ "$SCSI0" =~ local-lvm ]]; then
  DISK_SIZE=$(echo "$SCSI0" | sed -n 's/.*size=\([0-9]*[G|M]\).*/\1/p')
  CREATE_CMD+=" --scsi0 local-lvm:\$NEW_VMID-disk-0,size=$DISK_SIZE"
fi

echo "Para clonar la VM, ejecuta el siguiente comando cambiando \$NEW_VMID por el ID de la nueva VM:"
echo "$CREATE_CMD"

```

Resultado ejemplo:

```sh
qm create $NEW_VMID --name myvm-clone --memory 1024 --cores 1 --sockets 1 --cpu host --net0 virtio=AA:AA:AA:AA:AA:AA,bridge=vmbr0,firewall=1 --ostype l26 --boot order=scsi0;ide2 --agent 1 --scsi0 local-lvm:$NEW_VMID-disk-0,size=50G
```

### Borrar partición LVM

- EJ: borrar la partición por defecto para almacenar discos e isos y alargar la principal.

```sh
lvremove /dev/pve/data
lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/pve/root
```
