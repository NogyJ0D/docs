# Kernel

- [Kernel](#kernel)
  - [Compilar kernel](#compilar-kernel)
    - [Debian](#debian)
  - [Configuraciones](#configuraciones)
    - [General-Setup](#general-setup)
      - [Local version](#local-version)
      - [uselib syscall](#uselib-syscall)
    - [Processor type and features](#processor-type-and-features)
      - [Symmetric multi-processing support](#symmetric-multi-processing-support)
      - [Enable MPS table](#enable-mps-table)
      - [Support for extended (non-PC) x86 platforms](#support-for-extended-non-pc-x86-platforms)
      - [Intel Low Power Subsystem Support](#intel-low-power-subsystem-support)
      - [AMD ACPI2Platform devices support](#amd-acpi2platform-devices-support)
      - [Linux Guest Support](#linux-guest-support)
      - [Processor family](#processor-family)
      - [Supported processor vendors](#supported-processor-vendors)
      - [Enable Maximum number of SMP Processors and NUMA Nodes](#enable-maximum-number-of-smp-processors-and-numa-nodes)
      - [Cluster scheduler support | Multi-core scheduler support](#cluster-scheduler-support--multi-core-scheduler-support)
      - [Reroute for broken boot IRQs](#reroute-for-broken-boot-irqs)
      - [Machine Check / overheating reporting](#machine-check--overheating-reporting)
      - [Machine check injector support](#machine-check-injector-support)
      - [IOPERM and IOPL Emulation](#ioperm-and-iopl-emulation)
      - [Enable 5-level page tables support](#enable-5-level-page-tables-support)
      - [NUMA Memory Allocation and Scheduler Support](#numa-memory-allocation-and-scheduler-support)
      - [Old style AMD Opteron NUMA detection](#old-style-amd-opteron-numa-detection)
      - [NUMA emulation](#numa-emulation)
      - [TSX enable mode](#tsx-enable-mode)
      - [Software Guard eXtensions](#software-guard-extensions)
      - [Timer frequency](#timer-frequency)
      - [EFI stub support | Built-in kernel command line](#efi-stub-support--built-in-kernel-command-line)
    - [Mitigations for CPU vulnerabilities](#mitigations-for-cpu-vulnerabilities)
    - [Power management and ACPI options](#power-management-and-acpi-options)
      - [Suspend to RAM and standby](#suspend-to-ram-and-standby)
      - [Hibernation](#hibernation)
      - [Power Management Debug Support](#power-management-debug-support)
      - [ACPI](#acpi)
      - [CPU Frequency scaling](#cpu-frequency-scaling)
      - [Cpuidle Driver for Intel Processors](#cpuidle-driver-for-intel-processors)
    - [Binary Emulations](#binary-emulations)
      - [IA32 Emulation](#ia32-emulation)
      - [x32 ABI for 64-bit mode](#x32-abi-for-64-bit-mode)
    - [Virtualization](#virtualization)
      - [Kernel-based Virtual Machine (KVM) support](#kernel-based-virtual-machine-kvm-support)
      - [KVM for Intel processors support](#kvm-for-intel-processors-support)
      - [Support for Microsoft Hyper-V emulation](#support-for-microsoft-hyper-v-emulation)
      - [Support for Xen hypercall interface](#support-for-xen-hypercall-interface)
      - [Maximum number of vCPUs per KVM guest](#maximum-number-of-vcpus-per-kvm-guest)
    - [General architecture-dependent options](#general-architecture-dependent-options)
      - [Kprobes](#kprobes)
    - [Enable loadable module support](#enable-loadable-module-support)
      - [Forced module loading](#forced-module-loading)
      - [Forced module unloading](#forced-module-unloading)
      - [Module versioning support](#module-versioning-support)
    - [Enable the block layer](#enable-the-block-layer)
      - [Enable support for cost model based cgroup IO controller](#enable-support-for-cost-model-based-cgroup-io-controller)
      - [Partition types](#partition-types)
      - [IO Schedulers](#io-schedulers)
    - [Executable file formats](#executable-file-formats)
      - [Kernel support for MISC binaries](#kernel-support-for-misc-binaries)
    - [Memory Management options](#memory-management-options)
      - [Support for paging of anonymous memory (swap)](#support-for-paging-of-anonymous-memory-swap)
      - [Memory hotplug](#memory-hotplug)
    - [Networking support](#networking-support)
      - [Networking options](#networking-options)
    - [Device Drivers](#device-drivers)
      - [PCI support](#pci-support)
      - [PCCard support](#pccard-support)
      - [Generic Driver Options](#generic-driver-options)
      - [Firmware Drivers](#firmware-drivers)
      - [GNSS receiver support](#gnss-receiver-support)
      - [Memory Technology Device support](#memory-technology-device-support)
      - [Parallel port support](#parallel-port-support)
      - [Block devices](#block-devices)
      - [NVME Support](#nvme-support)
      - [Misc devices](#misc-devices)
      - [SCSI device support](#scsi-device-support)
      - [Serial ATA and Parallel ATA drivers (libata)](#serial-ata-and-parallel-ata-drivers-libata)
      - [Mutliple devices driver support (RAID and LVM)](#mutliple-devices-driver-support-raid-and-lvm)
      - [Generic Target Core Mod](#generic-target-core-mod)
      - [Fusion MPT device support](#fusion-mpt-device-support)
      - [IEEE 1394 (FireWire) support](#ieee-1394-firewire-support)
      - [Machintosh device drivers](#machintosh-device-drivers)
      - [Input device support](#input-device-support)
      - [Character devices](#character-devices)
      - [I2C support](#i2c-support)
      - [SPI support](#spi-support)
      - [PTP clock support](#ptp-clock-support)
      - [Pin controllers](#pin-controllers)
      - [Dalla's 1-wire support](#dallas-1-wire-support)
      - [Resto](#resto)
    - [File systems](#file-systems)
      - [Ext4 POSIX Access Control Lists](#ext4-posix-access-control-lists)
      - [Reiserfs support](#reiserfs-support)
      - [JFS filesystem support](#jfs-filesystem-support)
      - [XFS filesystem support](#xfs-filesystem-support)
      - [GFS2 file system support](#gfs2-file-system-support)
      - [OCFS2 file system support](#ocfs2-file-system-support)
      - [Btrfs filesystem support](#btrfs-filesystem-support)
      - [NILFS2 file system support](#nilfs2-file-system-support)
      - [F2FS filesystem support](#f2fs-filesystem-support)
      - [zonefs filesystem support](#zonefs-filesystem-support)
      - [Quota support](#quota-support)
      - [Caches](#caches)
      - [DOS/FAT/EXTFAT/NT Filesystems](#dosfatextfatnt-filesystems)
      - [Pseudo filesystems](#pseudo-filesystems)
      - [Network File Systems](#network-file-systems)
  - [Extras](#extras)

---

## Compilar kernel

### Debian

1. Instalar básicos:

    ```sh
    apt install build-essential bc python3 bison flex rsync libelf-dev libssl-dev libncurses-dev dwarves
    ```

2. [Descargar kernel](https://kernel.org/):

    ```sh
    wget [link]
    tar xvf [archivo]
    cd [carpeta]
    ```

3. Configurar kernel:

    ```sh
    cp /boot/config-[version] ./.config # Copiar la configuración del kernel en uso para el nuevo
    make .config
    make menuconfig # Menú de configuración
    ```

4. Compilar:

    ```sh
    nproc # Obtener número de nucleos
    time make -j$(nproc)
    time make modules_install -j$(nproc)
    time make install -j$(nproc)
    reboot # Seleccionar el kernel en grub
    ```

  5. Empaquetar (opcional):

---

## [Configuraciones](https://www.odi.ch/prog/kernel-config.php)

> Usé esta configuración en arch con el kernel 6.8.9 y me quedé sin internet.

### General-Setup

#### Local version

String que se agrega al final de la versión del kernel.

#### uselib syscall

Permitir uselib syscall para libc5. Si se tiene glibc, se puede desactivar.

### Processor type and features

#### Symmetric multi-processing support

Sirve para sistemas con mas de un CPU. Si "cpuid" devuelve "x2APIC: extended xAPIC support = true", activar.

#### Enable MPS table

Sirve para sistemas de multiprocesamiento simétrico (+1 CPU usando la misma memoria principal) antiguos sin ACPI. Si se tiene un CPU, desactivar.

#### Support for extended (non-PC) x86 platforms

Sirve para un kernel genérico. Desactivar.

#### Intel Low Power Subsystem Support

Para notebooks con procesador Intel Haswell o mas nuevo.

#### AMD ACPI2Platform devices support

Para procesadores AMD.

#### Linux Guest Support

- Enable Paravirtualization code: Y
- Paravirtualization layer for spinlocks: Y para KVM y XEN.
  - Xen guest support: Y si se va a usar XEN.
  - KVM guest support: Y si se va a usar KVM.

#### Processor family

Para Intel moderno: Core 2/newer Xeon

#### Supported processor vendors

Activar y seleccionar la marca a usar.

#### Enable Maximum number of SMP Processors and NUMA Nodes

Desactivar y en Maximum number of CPUs poner la cantidad de cores del procesador.

#### Cluster scheduler support | Multi-core scheduler support

Activar para procesadores modernos multi nucleo.

#### Reroute for broken boot IRQs

Viejo, desactivar.

#### Machine Check / overheating reporting

Activar.

#### Machine check injector support

Desactivar.

#### IOPERM and IOPL Emulation

Activar.

#### Enable 5-level page tables support

Desactivar.

#### NUMA Memory Allocation and Scheduler Support

Activar para procesaores multi hilo.

#### Old style AMD Opteron NUMA detection

Desactivar.

#### NUMA emulation

Desactivar.

#### TSX enable mode

Auto.

#### Software Guard eXtensions

Desactivar.

#### Timer frequency

100HZ para servidores, 300HZ para escritorios.

#### EFI stub support | Built-in kernel command line

Solo si se ejecuta el kernel como binario y no desde grub. La segunda solo si está activa la primera.

### Mitigations for CPU vulnerabilities

Activarlo.

### Power management and ACPI options

#### Suspend to RAM and standby

Activarlo. Desactivarlo para servidores.

#### Hibernation

A decisión.

#### Power Management Debug Support

Desactivarlo.

#### ACPI

Activarlo.

- ACPI Serial Port Console Redirection Support: no
- ACPI Firmware Performance Data Table support: si
- Dock: si para notebooks
- Allow upgrading ACPI tables via initrd: no
- PCI slot detection driver: no
- Memory Hotplug: si el hardware no habilita agregar/quitar componentes mientras funciona, desactivar
- Smart Battery System: activar para notebooks
- ACPI NVDIMM Firmware Interface Table: desactivar
- PMIC: desactivar

#### CPU Frequency scaling

- Processor Clocking Control interface driver: no
- AMD Processor P-State driver: si para AMD
- AMD Opteron/Athlon64 PowerNow!: si para AMD
- Intel Enhanced SpeedStep: no
- Intel Pentium 4 clock modulation: no

#### Cpuidle Driver for Intel Processors

Si para Intel.

### Binary Emulations

#### IA32 Emulation

Activar, sirve para binarios de 32 bits y Wine.

#### x32 ABI for 64-bit mode

Desactivar, deprecado.

### Virtualization

Activar si se van a usar maquinas virtuales.

#### Kernel-based Virtual Machine (KVM) support

Activar si se va a usar KVM.

#### KVM for Intel processors support

Activar para Intel.

#### Support for Microsoft Hyper-V emulation

Desactivar.

#### Support for Xen hypercall interface

Activar si se va a usar Xen.

#### Maximum number of vCPUs per KVM guest

1024

### General architecture-dependent options

#### Kprobes

Útil para debugging y testing. Desactivar.

### Enable loadable module support

#### Forced module loading

Desactivar.

#### Forced module unloading

Desactivar.

#### Module versioning support

Desactivar si no se van a usar binarios.

### Enable the block layer

#### Enable support for cost model based cgroup IO controller

Desactivar.

#### Partition types

Dejar los siguinetes:

- Advanced partition selection
- Macintosh partition map support
- PC BUIS support (revisar los de abajo)
- Windows Logical Disk Manager support
- EFI GUID Partition support

#### IO Schedulers

- Kyber I/O scheduler: no

### Executable file formats

#### Kernel support for MISC binaries

Desactivar, requiere configuración.

### Memory Management options

#### Support for paging of anonymous memory (swap)

Activar si se va a usar swap.

#### Memory hotplug

Desactivar, es para quitar en ejecución. Activar en VMs.

### Networking support

#### Networking options

- Transformation sub policy support: no
- Transformation statistics: no
- PK_KEY MIGRATE + Transformation migrate database: no
- IP: multicasting: no
- IP: advanced router: activar si se va a usar la maquina para ruteo (ipv4/ip_forward por ej.)
- IP: tunneling: no
- IP: GRE demultiplexer: no
- TCP: advanced congestion control: no
- TCP: MD5 Signature Option support: no, solo para routers BGP
- The IPv6 protocol: dejarlo
  - IPv6: Router Preference support: no
  - IPv6: Enable RFC 4429 Optimistic DAD: no
  - IPv6: Mobility: no
  - Virtual (secure) IPv6: tunneling: no
  - IPv6: multicast routing: no
- NetLabel subsystem support: no
- Timestamping in PHY devices: no
- Network packet filtering framework (Netfilter): SI, usado por iptables.
  - IP set support: no
  - IP virtual server support: no
- The DCCP Protocol: no
- The SCTP Protocol: no
- The Reliable Datagram Sockets Protocol: no
- The TIPC Protocol: no
- Asynchronous Transfer Mode (ATM): no, usado por modems DSL
- Layer Two Tunneling Protocol (L2TP): si si se usa VPN
- 802.1d Ethernet Bridging: si es una VM
- ANSI/IEEE 802.2 LLC type 2 Support: no
- Appletalk protocol support: no
- LAPB Data Link family: no
- Phonet protocols family: no
- IEEE Std 802.15.4: no
- Data Center Bridging support: no
- BATMAN: no

### Device Drivers

#### PCI support

- PCI Express error injection support: no
- PCI Express Downstream Port Containment support: no
- PCI Express Precision Time Measurement support: no
- PCI Stub driver: no
- Support for PCI Hotplug: si

#### PCCard support

Desactivar

#### Generic Driver Options

- Firmware loader
  - Build named firmware blobs into the kernel binary: no

#### Firmware Drivers

- BIOS Enhanced Disk Drive calls determine boot disk: no
- QEMU fw_cfg device support in sysfs: si para VM
- Google Firmware Drivers: no

#### GNSS receiver support

Desactivar

#### Memory Technology Device support

Desactivar

#### Parallel port support

Desactivar

#### Block devices

- Null test block driver: no
- Normal floppy disk support: no
- Block Device Driver for Micron PCIe SSDs: no si no se tiene un sdd de esa marca
- DRBD: no
- Network block device support: no
- RAM block device support: no
- Package writing on CD/DVD media: si si se tiene una lectora de cd
- ATA over Ethernet support: no
- Rados block device: si para ceph

#### NVME Support

- NVM Express block device: si si se tiene un NVME.
- NVMe multipath support: no
- NVM Express over Fabrics RDMA host driver: no
- NVM Express over Fabrics FC host driver: no
- NVM Express over Fabrics TCP host driver: no
- NVMe Target support: no

#### Misc devices

- Device driver for IBM RSA service processor: no
- Sensable PHANToM (PCI): no
- Integrated Circuits ICS932S401: no
- Enclosure Services: no. Es para los gabinetes con bandejas de discos que se sacan
- Channel interface driver for the HP iLO processor: no. Es para servidor HP ProLiant
- Medfield Avago APDS9802 ALS Sensor module: no. Es para sensores de luz ambiente
- Cosas de ambient light sensor, proximity sensor, compass, Dallas: no
- Silicon Labs C2 port support: no
- EEPROM support:
  - I2C EEPROMs / RAMs / ROMs from most vendors: si
  - SPD EEPROMs on DDR4 memory modules: si
  - No a los demás
- STMicroelectronics LIS3LV02Dx three-axis digital accelerometer (I2C): no

#### SCSI device support

- SCSI tape support: no
- SCSI CDROM support: si si se tiene lectora de disco
- SCSI media changer support: no
- SCSI logging facility: no
- SCSI Transports:
  - FiberChannel Transport Attributes: si si se tiene hardware para fibra óptica
- SCSI low-level drivers: dejarlo como está, mucho lio
- SCSI Device Handlers: no

#### Serial ATA and Parallel ATA drivers (libata)

- SATA Port Multipier support: es para la placa de expansión SATA
- Generic ATA support: no

#### Mutliple devices driver support (RAID and LVM)

Activar si se usa RAID o LVM.

#### Generic Target Core Mod

Desactivar.

#### Fusion MPT device support

Activar si "lspci | grep MPT" devuelve algo.

#### IEEE 1394 (FireWire) support

Activar si es una notebook con puerto Firewire.

#### Machintosh device drivers

Desactivar incluso en Mac.

#### Input device support

- Mice:
  - Elantech: si si se tiene touchpad
  - Sentelic: si si se tiene ese touchpad
  - eGalax: si si se tiene ese touchpad
  - Serial mouse: no
  - Revisar los otros
- Joysticks/Gamepads: sí si se va a usar
- Joysticks/Gamepads: sí si se va a usar
- Joysticks/Gamepads: sí si se va a usar

#### Character devices

- Non-standar serial port support: no
- Serial device bus: no
- Virtio console: si para VMs
- IPMI top-level message handler: si para servidores
- /dev/mem virtual device support: no
- /dev/port character device: no

#### I2C support

- Enable compatibility bits for old user-space: no

#### SPI support

Desactivar.

#### PTP clock support

Desactivar.

#### Pin controllers

Desactivar.

#### Dalla's 1-wire support

Desactivar.

#### Resto

No se, ver otro dia

### File systems

#### Ext4 POSIX Access Control Lists

Activar si es para un servidor samba.

#### Reiserfs support

Desactivar.

#### JFS filesystem support

Desactivar.

#### XFS filesystem support

Activar si se va a usar xfs.

#### GFS2 file system support

Desactivar.

#### OCFS2 file system support

Desactivar.

#### Btrfs filesystem support

Desactivar.

#### NILFS2 file system support

Desactivar.

#### F2FS filesystem support

Desactivar.

#### zonefs filesystem support

Desactivar.

#### Quota support

Activar si se van a usar quotas de usuario con ext4.

#### Caches

Desactivar.

#### DOS/FAT/EXTFAT/NT Filesystems

- MSDOS fs support: no
- Default iocharset for FAT: iso8859-1

#### Pseudo filesystems

- /proc/kcore support: no
- Tmpfs POSIX Access Control Lists: sí si se va a usar samba.
- HugeTLB file system support: no

#### Network File Systems

- NFS client support for the NFSv3 ACL protocol extension: no
- Provide swap over NFS support: no
- NFS server support: solo para servidores
- NFS client support for NFSv4.1: no
- NFS server support for the NFSv3 ACL protocol extension: no
- Provide Security Label support for NFSv4 server: no
- Ceph distributed file system: solo con ceph
- Coda file system support: no
- Andrew File System support: no
- Plan 9 Resource Sharing Support: no

---

## Extras
