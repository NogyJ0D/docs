# Motherboard

- [Motherboard](#motherboard)
  - [BIOS/UEFI](#biosuefi)
  - [Conectores](#conectores)
    - [Panel frontal](#panel-frontal)
    - [Placa](#placa)
      - [PCIe - Peripheral Component Interconnect express](#pcie---peripheral-component-interconnect-express)
      - [SATA - Serial Advanced Technology Attachment](#sata---serial-advanced-technology-attachment)
    - [M.2](#m2)

---

## BIOS/UEFI

- Es el firmware que controla la motherboard.
- UEFI - Unified Extensible Firmware Interface.
  - Es requerido para conectar discos mayores a 2TB.

## Conectores

### Panel frontal

- USB - Universal Serial Bus:
  - Versiones:
    - USB 3.2, 3.1, 3.0: 5 Gb/s
    - USB 2.0: 480 Mb/s
- VGA - Video Graphics Array:
  - 15 pins.
  - Transmite video analógico.
- DVI - Digital Video Interface:
  - Hay tres tipos
  - Transmite video digital o analógico.
- HDMI - High-Definition Multimedia Interface:
  - Transmite video digital y audio.
- DisplayPort:
  - Transmite video digital y audio.
- Thunderbolt 3:
  - Transmite video, datos y energia y es usado en dispositivos Apple.
  - Es compatible con USB C.
- eSATA - external SATA:
  - Puerto rojo para discos externos.
- PS/2:
  - Puerto analógico para teclado y mouse.
  - Violeta es para teclado.
  - Verde es para mouse.
- Puerto ethernet:
  - Puerto RJ-45 para conectarse a la red.

### Placa

#### PCIe - Peripheral Component Interconnect express

- Versiones:
  - PCIe 5.0: 63 GB/s
  - PCIe 4.0: 32 GB/s
  - PCIe 3.0: 16 GB/s
  - PCIe 2.0: 8 GB/s
  - PCI: 500 MB/s

&nbsp;

- Tamaños (por cantidad de líneas):
  - x1
  - x4
  - x8
  - x16
- Si se conecta una placa PCIe mas pequeña que el slot, se usan solo las líneas en contacto.

&nbsp;

- Si un dispositivo PCIe como una tarjeta gráfica necesita mas energía que la que provee el slot, se le conecta al primero un cable de energia PCIe.
- Tipos de cable PCIe:
  - 6-pin: 75 watts
  - 8-pin: 150 watts

#### SATA - Serial Advanced Technology Attachment

- Versiones:
  - SATA Express (SATAe): más rápido que SATA3 pero poco usado.
  - SATA3 o SATA 6.0: 6 Gb/s
  - SATA2 o SATA 3.0: 3 Gb/s

### M.2

- Más rápido que los puertos SATA.
- El disco M.2 puede ser SATA o PCIe.
- El socket puede ser M.2 SATA y/o M.2 PCIe.
- Si se usa el puerto M.2, es posible que se deshabilite un puerto PCIe o SATA.
