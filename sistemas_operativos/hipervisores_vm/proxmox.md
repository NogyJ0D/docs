# Proxmox

---

## Contenido

- [Proxmox](#proxmox)
  - [Contenido](#contenido)

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