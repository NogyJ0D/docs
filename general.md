# General

- [General](#general)
  - [Abrir archivos raros](#abrir-archivos-raros)
    - [winmail.dat - TNEF](#winmaildat---tnef)

---

## Abrir archivos raros

### winmail.dat - TNEF

- Archivos codificados con TNEF (Transport Neutral Encapsulation Format).
- TNEF: formato propietario de Microsoft Outlook para encapsular adjuntos en un correo.

- Para decodificar un .dat:
  - Con Windows:
    - [Winmail.dat Reader](https://www.winmail-dat.com/es/)
    - [Winamil Opener](https://www.eolsoft.com/freeware/winmail_opener/)
  - Online:
    - [Winmail.dat Reader](https://www.winmail-dat.com/online.php)
  - Con linux:
    - "libytnef" en PACMAN: "ytnef -F -f . winmail.dat"
    - "tnef" en AUR: "tnef winmail.dat"
    - "tnef" o "ytnef-tools" en APT
