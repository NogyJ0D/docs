# General

---

## Contenido

- [General](#general)
  - [Contenido](#contenido)
  - [Instalación](#instalación)
    - [Instalar windows manualmente](#instalar-windows-manualmente)
    - [Saltarse inicio de sesión de microsoft](#saltarse-inicio-de-sesión-de-microsoft)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
    - [Descargar idioma](#descargar-idioma)
    - [Habilitar usuario administrador con cmd](#habilitar-usuario-administrador-con-cmd)
    - [Eliminar usuario](#eliminar-usuario)
    - [Borrar entrada ssh en known_hosts](#borrar-entrada-ssh-en-known_hosts)
    - [Desinstalar Edge](#desinstalar-edge)
    - [Habilitar autologon](#habilitar-autologon)
    - [Instalar Microsoft Store](#instalar-microsoft-store)
    - [Deshabilitar Sticky Keys](#deshabilitar-sticky-keys)
  - [Extras](#extras)
    - [Actualizar windows con powershell](#actualizar-windows-con-powershell)

---

## Instalación

### Instalar windows manualmente

1. Completar el cuadro regional.

2. Antes de particionar abrir el cmd con Shift + 10.

3. Particionar disco:

   ```cmd
   DISKPART
   LIST DISK
   SEL DISK [disco a usar]
   CLEAN
   ```

   - Para BIOS:

     ```cmd
     CONVERT MBR
     CREATE PARTITION PRIMARY SIZE=100
     FORMAT FS=ntfs QUICK LABEL="System"
     ASSIGN LETTER=G
     ACTIVE
     CREATE PARTITION PRIMARY
     FORMAT FS=ntfs QUICK LABEL="Windows"
     ASSIGN LETTER=W
     EXIT
     ```

   - Para UEFI:

     ```cmd
     CONVERT GPT
     CREATE PARTITION EFI SIZE=100
     FORMAT FS=FAT32 QUICK
     ASSIGN LETTER=G
     CREATE PARTITION PRIMARY
     FORMAT FS=ntfs QUICK
     ASSIGN LETTER=W
     EXIT
     ```

4. Seleccionar el windows a instalar:

   ```cmd
   DISM /Get-ImageInfo /imagefile:[x/e/f]:\sources\install.wim
   ```

   - Si no es el disco x el que contiene windows, probar con el que funcione.

5. Instalar windows:

   ```cmd
   DISM /apply-image /imagefile:[x/e/f]:\sources\install.wim /index:2 /applydir:w:
   ```

6. Copiar archivos de boot:

   ```cmd
   bcdboot w:\Windows /s G: /f ALL
   ```

   - Se puede reemplazar ALL por BIOS o UEFI si se quiere.

7. Esperar a que reinicie y completar instalación.

### Saltarse inicio de sesión de microsoft

- Cuando aparezca la vista para conectarse a una red, apretar `Shift + F10` y en la terminal poner `start ms-cxh:localonly`.

---

## Documentación

---

## Comandos

### Descargar idioma

> Si los comandos no se encuentran en un Windows recién instalado, actualizar este primero.

```ps
Get-InstalledLanguage
Install-Language -Language es-AR -CopyToSettings -ExcludeFeatures
Set-SystemPreferredUILanguage -Language es-AR
Restart-Computer
```

### Habilitar usuario administrador con cmd

```ps
net user [usuario o administrator] [poner contraseña, * para que la pida o no poner nada] /active:[yes o no] /expires:[DD/MM/YYYY o never]
```

### Eliminar usuario

1. Ejecutar "SystemPropertiesAdvanced".
2. Ir a _Advanced_ > _User Profiles_ y borrar.

### Borrar entrada ssh en known_hosts

```powershell
ssh-keygen -R x.x.x.x
```

### Desinstalar Edge

```ps
cd 'C:\Program Files (x86)\Microsoft\Edge\Application\x\Installer\'
setup --uninstall --force-uninstall --system-level
```

### Habilitar autologon

1. Modificar clave de registro **HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device\DevicePasswordLessBuildVersion** y poner valor en "**0**".

2. Abrir **netplwiz**, seleccionar el usuario a habilitar el autologon y desmarcar la casilla de arriba.

### Instalar Microsoft Store

- Útil para Windows LTSC
- Ejecutar en CMD:

  ```cmd
  wsreset -i
  ```

### Deshabilitar Sticky Keys

1. Abrir powershell y ejecutar:

   ```ps
   # Deshabilitar Sticky Keys completamente
   $path = "HKCU:\Control Panel\Accessibility\StickyKeys"
   Set-ItemProperty -Path $path -Name "Flags" -Value "506"

   # Deshabilitar el atajo de teclado (el que se activa con Shift x5)
   $path2 = "HKCU:\Control Panel\Accessibility\Keyboard Response"
   Set-ItemProperty -Path $path2 -Name "Flags" -Value "122"

   $path3 = "HKCU:\Control Panel\Accessibility\ToggleKeys"
   Set-ItemProperty -Path $path3 -Name "Flags" -Value "58"
   ```

2. Reiniciar sesión.

---

## Extras

### Actualizar windows con powershell

- No recomendado, no descarga todas las actualizaciones como el menú.

```ps
Install-Module PSWindowsUpdate
Set-ExecutionPolicy Unrestricted
Import-Module PSWindowsUpdate
Get-WindowsUpdate
Install-WindowsUpdate -AcceptAll -AutoReboot
```
