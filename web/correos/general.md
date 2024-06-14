# General

- [General](#general)
  - [Agentes](#agentes)
    - [MTA (Mail Transport Agent)](#mta-mail-transport-agent)
    - [MDA (Mail Delivery Agent)](#mda-mail-delivery-agent)
    - [MUA (Mail User Agent)](#mua-mail-user-agent)
  - [Protocolos](#protocolos)
    - [POP3 (Post Office Protocol)](#pop3-post-office-protocol)
    - [IMAP (Internet Message Access Protocol)](#imap-internet-message-access-protocol)
    - [SMTP (Simple Mail Transfer Protocol)](#smtp-simple-mail-transfer-protocol)
  - [StartTLS](#starttls)
  - [Dominios](#dominios)
  - [Software](#software)

---

## Agentes

Usuario > MTA > MDA > Usuario

### MTA (Mail Transport Agent)

- Transporta el correo al destinatario. Los MTA se comunican entre sí con SMTP.

### MDA (Mail Delivery Agent)

- Almacena los correos hasta que el usuario los recibe. Utiliza los protocolos [POP3](#pop3-post-office-protocol) e [IMAP](#imap-internet-message-access-protocol).
- Está protegido por usuario y contraseña.

### MUA (Mail User Agent)

- Es el cliente que obtiene los correos del MDA.
- Puede ser local del usuario o web.

---

## Protocolos

### POP3 (Post Office Protocol)

- Descarga el correo del servidor.
- Puertos 110 (sin cifrar) y 995 (cifrado).

### IMAP (Internet Message Access Protocol)

- Sincroniza los correos (y sus estados) entre el cliente y el servidor. El usuario no tiene que descargarlos.
- Puertos 143 (sin cifrar) y 993 (cifrado).

### SMTP (Simple Mail Transfer Protocol)

- Utilizado para enviar y recibir mensajes de correo por internet.
- Puertos 25 (original, sin uso), 587 (en uso, cifrado), 465 (viejo pero en uso, soporta cifrado) y 2525 (alternativa nueva al 587).

---

## StartTLS

- Extensión al protocolo TLS.
- Se emplea para SMTP, IMAP y POP.

---

## Dominios

- Los dominios pueden ser locales o virtuales.
  - Locales: un servidor de correo recibe y envia los correos de la propia maquina a los usuarios de esta.
    - Quienes pueden enviar mails de esta forma son los usuarios de **_/etc/passwd_**.
    - Los mails se almacenan en **_/var/mail/usuario_**.
  - Virtuales: al servidor se le especifica que dominios son válidos.
    - Se pueden tener tambien alias virtuales. El servidor recibe los correos y los envía a otro servidor.

---

## Software

- MTA
  - [qmail](../correos/qmail.md)
  - [Exim](../correos/exim.md)
  - [Postfix](../correos/postfix.md)
- MDA
  - [Dovecot](../correos/dovecot.md)
- MUA
  - Roundcube (web)
  - Thunderbird (local)
- Listas de correo
  - MailMan
