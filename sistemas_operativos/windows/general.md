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
    - [Habilitar usuario administrador con cmd](#habilitar-usuario-administrador-con-cmd)
    - [Eliminar usuario](#eliminar-usuario)
    - [Borrar entrada ssh en known\_hosts](#borrar-entrada-ssh-en-known_hosts)
  - [Extras](#extras)

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

### [Saltarse inicio de sesión de microsoft](https://christitus.com/install-windows-the-arch-linux-way/)

> Actually you can still setup a local Windows account using the OOBE in all cases even Windows 11 Home. Just type in <no@thankyou.com> for the email and a random password. The installer will then go to a local account creation screen. This works because the Microsoft account <no@thankyou.com> is banned or something so Microsoft doesn't want it to be used for Windows accounts.

---

## Documentación

---

## Comandos

### Habilitar usuario administrador con cmd

```ps
net user [usuario o administrator] [poner contraseña, * para que la pida o no poner nada] /active:[yes o no] /expires:[DD/MM/YYYY o never]
```

### Eliminar usuario

1. Ejecutar "SystemPropertiesAdvanced".
2. Ir a *Advanced* > *User Profiles* y borrar.

### Borrar entrada ssh en known_hosts

```powershell
ssh-keygen -R x.x.x.x
```

---

## Extras
