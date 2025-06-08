# Pacman

---

## Contenido

- [Pacman](#pacman)
  - [Contenido](#contenido)
  - [Comandos](#comandos)
  - [Extras](#extras)

---

## Comandos

- Actualizar repositorios:

    ```sh
    sudo pacman -Syy
    ```

- Actualizar paquetes:

    ```sh
    sudo pacman -Syu
    ```

- Instalar paquete:

    ```sh
    sudo pacman -S <paquete>
    ```

- Buscar paquete:

    ```sh
    sudo pacman -Ss <paquete>
    ```

- Eliminar paquete:

    ```sh
    sudo pacman -R <paquete>
    ```

- Eliminar paquete y dependencias no usadas:

    ```sh
    sudo pacman -Rs <paquete>
    ```

---

## Extras

### yay

- Configuración:

    ```sh
    yay --save
    vim ~/.config/yay/config.json
    # Poner sudoloop en true
    ```
