# General

- [General](#general)
  - [Documentación](#documentación)
    - [Dominios](#dominios)

---

## Documentación

### Dominios

- Los dominios pueden ser locales o virtuales.
  - Locales: un servidor de correo recibe y envia los correos de la propia maquina a los usuarios de esta.
    - Quienes pueden enviar mails de esta forma son los usuarios de **_/etc/passwd_**.
    - Los mails se almacenan en **_/var/mail/usuario_**.
  - Virtuales: al servidor se le especifica que dominios son válidos.
    - Se pueden tener tambien alias virtuales. El servidor recibe los correos y los envía a otro servidor.