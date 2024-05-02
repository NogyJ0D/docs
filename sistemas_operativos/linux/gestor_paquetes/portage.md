# Portage

- [Portage](#portage)
  - [Comandos](#comandos)
  - [Configuración](#configuración)
  - [Extras](#extras)

---

## Comandos

- Parámetros:
  - --ask: muestra un resumen de las acciones y pide confirmación.
  - --pretend: muestra que haría emerge pero sin realizar ningun cambio real.

- Actualizar repositorios:

    ```sh
    emerge --sync
    ```

- Actualizar todo el sistema:

    ```sh
    emerge --update --deep --newuse @world
    ```

- Buscar un paquete:

    ```sh
    emerge --search [paquete]
    ```

- Instalar un paquete:

    ```sh
    emerge [paquete]
    ```

- Desinstalar un paquete:

    ```sh
    emerge --deselect [paquete]
    ```

- Limpiar paquetes obsoletos:

    ```sh
    emerge --deepclean
    ```

- Ver información de un paquete:

    ```sh
    equery list [paquete]
    ```

- Listar paquetes instalados:

    ```sh
    qlist -I
    ```

- Reconstruir paquetes:

    ```sh
    emerge --ask --verbose --oneshot @preserved-rebuild
    ```

- Revisar conflictos:

    ```sh
    emerge --ask --verbose --tree --update @world
    ```

---

## Configuración

- Compilación paralela:
  - Modificar 'MAKEOPTS="-j4"' en ___/etc/portage/make.conf___ para ajustar el número de hilos de compilación


---

## Extras
