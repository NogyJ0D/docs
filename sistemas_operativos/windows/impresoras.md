# Impresoras

---

## Contenido

- [Impresoras](#impresoras)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Microsoft Print to PDF](#microsoft-print-to-pdf)
    - [Si imprime archivos dañados / 0 bytes](#si-imprime-archivos-dañados--0-bytes)
  - [Extras](#extras)

---

## Documentación

---

## Microsoft Print to PDF

### Si imprime archivos dañados / 0 bytes

- [Solución 1](https://community.spiceworks.com/topic/2025656-ms-print-to-pdf-files-corrupted-or-damaged)

    ```powershell
    Remove-Printer -Name "Microsoft Print to PDF"
    Disable-WindowsOptionalFeature -FeatureName "Printing-PrintToPDFServices-Features" -Online
    Restart-Computer
    Enable-WindowsOptionalFeature -online -FeatureName "Printing-PrintToPDFServices-Features" -All
    ```

- Solución 2

  1. Abrir ***printmanagement.msc***:

     1. Eliminar la impresora "Microsoft Print To PDF".

  2. Abrir ***optionalfeatures.exe***:

     1. Deshabilitar la característica "Microsoft Print To PDF".

  3. Reiniciar PC.

  4. Abrir ***printmanagement.msc***:

     1. Quitar el paquete de controladores "Microsoft Print To PDF".

  5. Abrir ***optionalfeatures.exe***:

     1. Habilitar la característica "Microsoft Print To PDF".

---

## Extras