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

### Información de la vm

```sh
qm config <id>
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
