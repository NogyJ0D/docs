# Discos

- [Discos](#discos)
  - [Particionado](#particionado)
    - [MBR - Master Boot Record](#mbr---master-boot-record)
    - [GPT - GUID Partition Table](#gpt---guid-partition-table)
  - [Partes](#partes)
  - [Extras](#extras)

---

## Particionado

### MBR - Master Boot Record

- Permite 4 particiones y está limitado a 2TB.

### GPT - GUID Partition Table

- No tiene límite de tamaño y permite hasta 128 particiones.

## [Partes](https://hddscan.com/doc/HDD_from_inside.html)

- PCB - Printed Circuit Board: placa de circuitos.
  - MCU - Micro Controller Unit:
    - Chip controlador.
    - En discos modernos es un CPU.
    - Hace los calculos para lectura y escritura.
    - Convierte señales entre analogicas y digitales.
  - Memoria:
    - Chip DDR SDRAM.
    - Define la capacidad de cache del disco.
    - Divide la memoria entre memoria de cache y memoria de firmware del CPU.
    - VCM - Voice Coil Motor:
      - Chip que controla el motor y los cabezales.
  - Flash chip:
    - Almacena parte del firmware.
    - Si este no está presente, el firmware está en el MCU.
  - Shock sensor:
    - Alerta al VCM de sobrecargas.
  - TVS - Transient Voltage Suppresion diode:
    - Protege a la placa de subidas de tensión de la fuente de energía.
    - Si se activa, se destruye y crea cortocircuito entre energia y tierra.
- HDA - Head and Disk Assembly: la caja negra de aluminio.
  - Breath Hole: normaliza la presión dentro y fuera del HDA.
    - Tiene un filtro de aire del lado de adentro.
  - Platos

---

## Extras

- Cuando el disco recibe energia, el MCU carga en memoria el contenido del Flash chip e inicia el código.
