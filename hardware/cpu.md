# CPU

- [CPU](#cpu)
  - [Características](#características)
    - [Frecuencia](#frecuencia)
    - [Litografía](#litografía)
    - [Socket y chipset](#socket-y-chipset)
    - [Multiprocesamiento](#multiprocesamiento)
    - [Procesamiento multicore](#procesamiento-multicore)
    - [Dual processor](#dual-processor)
    - [Memoria Caché](#memoria-caché)
    - [Memoria soportada](#memoria-soportada)
    - [Virtualización](#virtualización)
    - [Gráficos integrados](#gráficos-integrados)
    - [Overclocking](#overclocking)
    - [Arquitectura](#arquitectura)
  - [Intel](#intel)
    - [Familias Intel](#familias-intel)
    - [Generaciones Intel](#generaciones-intel)
    - [Sockets Intel](#sockets-intel)
  - [AMD](#amd)
    - [Familias AMD](#familias-amd)
    - [Chipset y sockets AMD](#chipset-y-sockets-amd)

---

## Características

### Frecuencia

- Es la velocidad a la que opera el procesador internamente.
- Se mite en gigahertz (GHz).

### Litografía

- Es el espacio entre los transistores impresos en la placa de silicio.
- Los transistores se miden en nanómetros (nm).

### Socket y chipset

- [Intel](#sockets-intel)
- [AMD](#chipset-y-sockets-amd)

### Multiprocesamiento

- La capacidad de hacer tareas en simultáneo.
- Multiprocessing: usar dos o mas unidades de procesamiento (ALUs) instaladas en un núcleo.
- Multithreading: cada core procesa dos hilos (threads) a la vez.

### Procesamiento multicore

- Los núcleos pueden estar agrupados. Usar uno solo de este grupo es _single-core processing_, usar varios a la vez es _multicore processing_.
- Con multithreading, cada core maneja dos hilos a la vez.
- Un procesador con 4 cores y 2 threads en cada uno puede manejar hasta 8 hilos a la vez.

### Dual processor

- Una motherboard para servidor puede tener dos o mas sockets para procesadores y usarlos en conjunto.
- El procesador debe poseer esta característica.

### Memoria Caché

- Los procesadores tienen módulos de caché de distintos niveles.
- L1 (level 1)
- L2 (level 2)
- L3 (level 3)

### Memoria soportada

- El procesador debe soportar DDR2, DDR3, DDR4, DDR5, etc.
- Debe soportar tambien la cantidad, la velocidad, etc.

### Virtualización

- El procesador puede soportar el manejo de máquinas virtuales.

### Gráficos integrados

- Un procesador puede incluir una GPU.

### Overclocking

- La capacidad de aumentar la frecuencia y voltaje para obtener mayor rendimiento.

### Arquitectura

- Si es de 32 o 64 bits o híbrido.

## Intel

### Familias Intel

- Intel Core:
  - i9, i7: gama alta.
  - i5: gama media.
  - i3: gama baja.
- Pentium: gama mas baja que intel core i3.
- Atom y Celeron: gama mas baja que pentium.

### Generaciones Intel

- Los procesadores intel tienen una generación ademas de ser Ix.
- Intel i5-7500 es un procesador de septima generación.
- Generaciones:
  - Coffee Lake (8va)
  - Kaby Lake (7ma)
  - Skylake (6ta)
  - Broadwell (5ta)
  - Haswell (4ta)

### Sockets Intel

- El nombre del socker incluye la cantidad de pins de este.
- Intel usa "Land Grid Array" (LGA) para los sockets.
- Sockets:
  - LGA1366: 1ra, 2da, 3ra y 4ta generación.
  - LGA1155: 3ra y 2da generación.
  - LGA1150: 5ta y 4ta generación.
  - LGA1151:
    - Primer lanzamiento funciona con 7ma y 6ta generación.
    - Segundo lanzamiento funciona con 8va generación.
  - LGA2066: 6ta, 7ma y 8va generación.
  - LGA2011: 2da, 3ra, 4ta y 5ta generación.

## AMD

### Familias AMD

- Ryzen Threadripper.
- Ryzen Pro.
- Ryzen.
- A-Series Pro.
- A-Series.
- FX.

### Chipset y sockets AMD

- TR4: LGA con soporte para Threadripper con el chipset AMD x399.
- AM4: familia para Ryzen y Athlon. Chipsets:
  - A300, B300, X300.
  - Tiene 1331 pins en un "Pin Grid Array" (PGA).
- AM3+ y AM3: sockets PGA para procesadores Piledriver y Bulldozer y chipsets de serie 9.
- FM2+: socket PGA viejo para procesadores Athlon, Steamroller y Excavator y chipsets de serie A.
