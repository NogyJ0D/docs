# Postfix

- [Postfix](#postfix)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Compilación](#compilación)
    - [Instalar Postfix en Debian 12](#instalar-postfix-en-debian-12)
  - [Comandos](#comandos)
  - [Extra](#extra)

---

## Documentación

- Los archivos de configuración están en **_/etc/postfix_**.
  - Los mas importantes son **_main.cf_** y **_master.cf_**. Luego de modificarlos, ejecutar "postfix reload".
    - main.cf:
      - Se especifica en la clave "myorigin" con que dominio enviar los mails. El valor es "$myhostname" y se puede cambiar a "mydomain" (preferible).
      - Se especifica en la clave "mydestination" de quien va a recibir los mails. Por defecto es sí mismo. Se recomienda dejar "\$myhostname localhost.$mydomain localhost" para evitar loops, y se agregan los dominios que se necesiten.
    - master.cf:

---

## Instalación

### [Compilación](https://www.postfix.org/INSTALL.html)

### Instalar Postfix en Debian 12

```sh
apt install postfix
apt install dovecot-imapd dovecot-pop3d
apt install mailman3-full
```

---

## Comandos

---

## Extra
