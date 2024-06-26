# VSCode

- [VSCode](#vscode)
  - [Instalación](#instalación)
    - [Instalar tar.gz](#instalar-targz)
  - [Comandos](#comandos)
  - [Extras](#extras)
    - [Rutas](#rutas)
    - [Abrir vscode como entorno web](#abrir-vscode-como-entorno-web)

---

## Instalación

### Instalar tar.gz

1. [Descargar comprimido](https://code.visualstudio.com/Download).
2. Ejecutar:

   ```sh
   tar xvzf code-x.x.x.tar.gz # Extraer
   sudo mv VSCode-linux-x64 /usr/share/code # Mover
   sudo ln -s /usr/share/code/bin/code /usr/bin/code # Agregar ejecutable al path
   ```

---

## Comandos

```sh
# Listar extensiones
code --list-extensions

# Instalar extensiones
code --install-extension [id]
```

---

## Extras

### Rutas

- Configuraciones del usuario: **_$HOME/.config/Code/User/settings.json_**
- Extensiones del usuario: **_$HOME/.vscode/extensions_**

### Abrir vscode como entorno web

```sh
code serve-web
```
