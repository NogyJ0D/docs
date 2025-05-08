# Bareos

- [Bareos](#bareos)
  - [Documentación](#documentación)

---

## Documentación

- Componentes:
  - Director: encola y supervisa los respaldos y recuperaciones.
  - Console: se comunica con el Director, corre en consola.
  - File Daemon: se instala en cada cliente, envía los archivos a respaldar al Storage Daemon.
  - Storage Daemon: recibe los archivos del File Daemon y los almacena. Envía al File Daemon los archivos a recuperar.
  - Catalog: lista los archivos respaldados y permite recuperarlos.
-
