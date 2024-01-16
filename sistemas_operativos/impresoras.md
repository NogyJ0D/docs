# Impresoras

## Microsoft Print to PDF

### Si imprime archivos dañados / 0 bytes
- [Solución 1](https://community.spiceworks.com/topic/2025656-ms-print-to-pdf-files-corrupted-or-damaged)
```powershell
Remove-Printer -Name "Microsoft Print to PDF"
Disable-WindowsOptionalFeature -FeatureName "Printing-PrintToPDFServices-Features" -Online
Restart-Computer
Enable-WindowsOptionalFeature -online -FeatureName "Printing-PrintToPDFServices-Features" -All
```

- [Solución 2]()
1. Abrir ***printmanagement.msc***:
   1. Eliminar la impresora "Microsoft Print To PDF".
2. Abrir ***optionalfeatures.exe***:
   1. Deshabilitar la característica "Microsoft Print To PDF".
3. Reiniciar PC.
4. Abrir ***printmanagement.msc***:
   1. Quitar el paquete de controladores "Microsoft Print To PDF".
5. Abrir ***optionalfeatures.exe***:
   1. Habilitar la característica "Microsoft Print To PDF".

1
3
4

agregar imp puerto PORTPROMPT
instalar nuevo controlador
windows update, esperar
Microsoft > microsoft print to pdf
No compartir
Crear

printmanagement.msc
    eliminar impresora
    eliminar controlador (no paquete)
printui.exe /im
    agregar impresora local
    portprompt
    si no está driver, windows update
    microsoft > print to pdf
reiniciar

dism deshabilitar feature
dism habilitar feature
reiniciar
liberar espacio en disco