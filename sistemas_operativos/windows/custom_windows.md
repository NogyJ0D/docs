# Custom Windows

- [Custom Windows](#custom-windows)
  - [Generar autounattend.xml](#generar-autounattendxml)
  - [Crear un windows 10 IoT personalizado para oficina](#crear-un-windows-10-iot-personalizado-para-oficina)

---

## Generar autounattend.xml

- [Usar el generador de schneegans](https://schneegans.de/windows/unattend-generator/).

  - Para proxmox descargar como iso.

    - Si hay que modificar algo del archivo, descargar como xml, modificar y generar iso.

      ```sh
      genisoimage -J -joliet-long -r -o unattend.iso autounattend.xml
      ```

## Crear un windows 10 IoT personalizado para oficina

1. Preparar autounattend **(opcional)**:

   - [Generar autounattend.xml para la instalación base](#generar-autounattendxml).
   - Usar [este template](./autounattend.xml):
     - Administrador 12345678

2. Instalar Windows.
3. Actualizar.
4. Cambiar idioma (PS):

   ```powershell
   Install-Language -Language es-AR -CopyToSettings -ExcludeFeatures
   Set-SystemPreferredUILanguage -Language es-AR
   Restart-Computer
   ```

5. Instalar Microsoft Store (CMD):

   ```cmd
   wsreset -i
   ```

6. Instalar Winget desde la Store ("App Installer" / "Instalador de aplicación").
7. Instalar programas básicos con winget.

   ```powershell
   winget install -e Mozilla.Firefox Google.Chrome PDFgear.PDFgear 7zip.7zip AdoptOpenJDK.OpenJDK.8 AdoptOpenJDK.OpenJDK.11 AdoptOpenJDK.OpenJDK17
   ```

8. Crear carpeta C:\Install y ocultar.
9. Activar Windows Fotos:

   - Descargar reg del repositorio "saif71/Enable-Windows-Photo-Viewer-Windows-10", guardar en C:\Install y ejecutar.
   - Registros:

     ```reg
     Windows Registry Editor Version 5.00

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll]

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell]

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open]
     "MuiVerb"="@photoviewer.dll,-3043"

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\command]
     @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
     00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
     6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
     00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
     25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
     00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
     6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
     00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
     5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
     00,31,00,00,00

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\open\DropTarget]
     "Clsid"="{FFE2A43C-56B9-4bf5-9A79-CC6D4285608A}"

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print]

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\command]
     @=hex(2):25,00,53,00,79,00,73,00,74,00,65,00,6d,00,52,00,6f,00,6f,00,74,00,25,\
     00,5c,00,53,00,79,00,73,00,74,00,65,00,6d,00,33,00,32,00,5c,00,72,00,75,00,\
     6e,00,64,00,6c,00,6c,00,33,00,32,00,2e,00,65,00,78,00,65,00,20,00,22,00,25,\
     00,50,00,72,00,6f,00,67,00,72,00,61,00,6d,00,46,00,69,00,6c,00,65,00,73,00,\
     25,00,5c,00,57,00,69,00,6e,00,64,00,6f,00,77,00,73,00,20,00,50,00,68,00,6f,\
     00,74,00,6f,00,20,00,56,00,69,00,65,00,77,00,65,00,72,00,5c,00,50,00,68,00,\
     6f,00,74,00,6f,00,56,00,69,00,65,00,77,00,65,00,72,00,2e,00,64,00,6c,00,6c,\
     00,22,00,2c,00,20,00,49,00,6d,00,61,00,67,00,65,00,56,00,69,00,65,00,77,00,\
     5f,00,46,00,75,00,6c,00,6c,00,73,00,63,00,72,00,65,00,65,00,6e,00,20,00,25,\
     00,31,00,00,00

     [HKEY_CLASSES_ROOT\Applications\photoviewer.dll\shell\print\DropTarget]
     "Clsid"="{60fd46de-f830-4894-a628-6fa81bc0190d}"
     ```

10. Instalar Office.
11. Activar Windows y Office.

- Retoques generales:
  - Configuración:
    - Actualizaciones y seguridad:
      - Optimización de contenido:
        - Permitir descargas desde otras PC: desactivar.
  - Windows defender:
    - Protección contra virus y amenazas:
      - Configuración de Protección contra virus y amenazas:
        - Envío automático de muestras: desactivar.
        - Exclusiones:
          - Agregar carpeta C:\Install.
