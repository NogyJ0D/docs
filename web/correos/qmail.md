# qmail

---

## Contenido

- [qmail](#qmail)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Componentes](#componentes)
    - [Componentes de qmail](#componentes-de-qmail)
      - [Daemons base](#daemons-base)
      - [Generales](#generales)
  - [Notas](#notas)
  - [Comandos](#comandos)
    - [Listar cuentas y contraseñas](#listar-cuentas-y-contraseñas)
    - [Cambiar contraseña de cuenta](#cambiar-contraseña-de-cuenta)
    - [Agregar usuario a qmail](#agregar-usuario-a-qmail)
  - [Extras](#extras)

---

## Documentación

- [Página oficial: cr.yp.to](http://cr.yp.to/qmail.html)

---

## Componentes

### Componentes de qmail

#### Daemons base

- qmail-send:
  - Administra la cola de mensajes y los despacha.
  - Para los mensajes locales notifica a qmail-lspawn que ejecute qmail-local.
  - Para los mensajes remotos notifica a qmail-rspawn que ejecute qmail-remote. Cada envio remoto usa una sesión diferente de smtp.
  - Al enviarse los mensajes notifica a qmail-clean para limpiarlos de la cola.
- qmail-queue:
  - Encola los mensajes.
  - Copia los mensajes recibidos y los escribe a un archivo en la carpeta de cola, luego llama a qmail-send.
  - Escribe los mensajes en el directorio **_queue/todo_**.
- qmail-lspawn: inicia los envios locales. Es el único que se ejecuta como root.
- qmail-rspawn: inicia los envios remotos.
- qmail-clean: limpia la cola de enviados.
- tcpserver: escucha las conexiones smtp entrantes, ejecuta qmail-smtpd que recibe los mensajes y llama a qmail-queue para encolarlos.

#### Generales

- qmail-smtpd: recibe los mails entrantes por smtp.
- qmail-inject: recibe los mails generados localmente.
- qmail-popup: toma las credenciales del cliente.
- checkpassword: valida las credenciales del cliente.
- qmail-pop3d: corre la sesión POP3.

---

## Notas

- MTA: Mail Transfer Agent => Servidor de correo (qmail).
- MUA: Mail User Agent => Cliente de correo (thunderbird).
- Información de la configuración global: **_/var/qmail/control_**. Archivos:
  - **_me_**: el nombre del host, sirve para usarse en otros archivos.
  - **_defaulthost_**: agrega el contenido a email saliente local que no tiene dominio. EJ: de "pepe" pasa a "<pepe@example.com>".
  - **_defaultdomain_**: es el dominio a agregar en mails salientes locales que no lo incluyen.
  - **_locals_**.
  - **_rcpthosts_**: de que dominios debe recibir qmail los emails por smtp. Siempre debe existir.
- Los grupos y usuarios se compilan en el mismo qmail, no se agregan luego. Se definen en archivos **_conf-groups_** y **_conf-users_**, pero deben ser creados antes.
- La carpeta base de qmail se define en el archivo **_conf-qmail_** del código fuente.
- Existe la carpeta **_/service_** que contiene servicios a correr por el daemon "supervise".
- Los logs de envio se encuentran en **_/var/log/qmail/send/current_**.

---

## Comandos

### Listar cuentas y contraseñas

```sh
cat /home/vpopmail/domains/dominio/vpasswd
```

### Cambiar contraseña de cuenta

```sh
/home/vpopmail/bin/vpasswd correo@dominio contraseña
```

### Agregar usuario a qmail

1. Copiar el archivo _**INSTALL.ids**_ del código fuente a _**/tmp/mu**_.

2. Modificar archivo según sistema.

3. Ejecutar archivo:

   ```sh
   sh /tmp/mu
   ```

---

## Extras
