# General

---

## Contenido

- [General](#general)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
    - [Borrar entrada ssh en known\_hosts](#borrar-entrada-ssh-en-known_hosts)
  - [Scripts utiles](#scripts-utiles)
    - [Massgrave.dev | Activar Windows/Office](#massgravedev--activar-windowsoffice)
    - [ChrisTitusWin | Utilidades para windows](#christituswin--utilidades-para-windows)
  - [Extras](#extras)

---

## Documentación

---

## Comandos

### Borrar entrada ssh en known_hosts

```powershell
ssh-keygen -R x.x.x.x
```

---

## Scripts utiles

### Massgrave.dev | Activar Windows/Office

```powershell
irm https://massgrave.dev/get | iex
```

### ChrisTitusWin | Utilidades para windows

> Nota: instala chocolatey.

```powershell
irm christitus.com/win | iex
```

- Modificaciones a tener en cuenta:
  - Essential Tweaks (hay que ejecutarlas):
    - Run OO Shutup.
    - Disable Telemetry.
    - Disable Wifi-Sense.
  - Customize Preferences:
    - Bing Search in Start Menu > Disable.
    - NumLock on Startup > Enable.
    - Verbose Logon Messages > Enable.
    - Show File Extensions > Enable.

---

## Extras
