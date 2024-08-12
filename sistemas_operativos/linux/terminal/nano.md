# nano

- [nano](#nano)
  - [Configuración](#configuración)
  - [Extras](#extras)

---

## Configuración

- Agregar nano-syntax-highlighting:

    ```sh
    pacman -S nano-syntax-highlighting # En arch

    sed -i 's/icolor brightnormal/icolor normal/g' /usr/share/nano-syntax-highlighting/nanorc.nanorc # Arreglar un error en los colores
    ```

```ini
# UI
set indicator
set linenumbers
set minibar

# Word wrap
set softwrap

# Tab e identación
set autoindent
set tabsize 2
set tabstospaces

# Color
include "/usr/share/nano/*.nanorc"
include "/usr/share/nano/extra/*.nanorc"
include "/usr/share/nano-syntax-highlighting/*.nanorc"
```

---

## Extras