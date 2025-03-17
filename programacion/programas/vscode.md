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

### Agregar a menú contextual "Abrir con VS Code"

- Crear un archivo ***.reg*** con el siguiente contenido (reemplazar "usuario" por el usuario):

  ```reg
  Windows Registry Editor Version 5.00
  [HKEY_CLASSES_ROOT\*\shell\Open with VS Code]
  @="Editar con VS Code"
  "Icon"="C:\\Users\\usuario\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe,0"
  [HKEY_CLASSES_ROOT\*\shell\Open with VS Code\command]
  @="\"C:\\Users\\usuario\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe\" \"%1\""
  [HKEY_CLASSES_ROOT\Directory\shell\vscode]
  @="Abrir carpeta con VS Code"
  "Icon"="\"C:\\Users\\usuario\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe\",0"
  [HKEY_CLASSES_ROOT\Directory\shell\vscode\command]
  @="\"C:\\Users\\usuario\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe\" \"%1\""
  [HKEY_CLASSES_ROOT\Directory\Background\shell\vscode]
  @="Abrir carpeta con VS Code"
  "Icon"="\"C:\\Users\\usuario\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe\",0"
  [HKEY_CLASSES_ROOT\Directory\Background\shell\vscode\command]
  @="\"C:\\Users\\usuario\\AppData\\Local\\Programs\\Microsoft VS Code\\Code.exe\" \"%V\""
  ```

### Sincronización

- Instalar extensiones teniendo las id en un archivo:

   ```sh
   while read -r line; do code --install-extension $line; done < [archivo]
   ```

### Rutas

- Configuraciones del usuario: **_$HOME/.config/Code/User/settings.json_**
- Extensiones del usuario: **_$HOME/.vscode/extensions_**

### Abrir vscode como entorno web

```sh
code serve-web
```
