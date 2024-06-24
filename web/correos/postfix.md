# Postfix

- [Postfix](#postfix)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Compilación](#compilación)
    - [Instalar Postfix en Debian 12](#instalar-postfix-en-debian-12)
  - [Comandos](#comandos)
  - [Extra](#extra)
    - [Cambiar mbox por maildir](#cambiar-mbox-por-maildir)
    - [Agregar dominios virtuales](#agregar-dominios-virtuales)
    - [Conectar Dovecot](#conectar-dovecot)
    - [Habilitar loggeo](#habilitar-loggeo)

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
```

---

## Comandos

---

## Extra

### Cambiar mbox por maildir

- Agregar en **_/etc/postfix/main.cf_**:

  ```cf
  home_mailbox = Maildir/
  ```

```sh
systemctl restart postfix
```

### Agregar dominios virtuales

1. Agregar **_/etc/postfix/main.cf_**:

   ```conf
   virtual_mailbox_domains = example.com example.org
   virtual_mailbox_base = /home/vhosts
   virtual_mailbox_maps = hash:/etc/postfix/vmailbox
   virtual_alias_maps = hash:/etc/postfix/virtual
   virtual_minimum_uid = 100
   virtual_uid_maps = static:5000
   virtual_gid_maps = static:5000
   ```

2. Agregar en **_/etc/postfix/vmailbox_**:

   ```conf
   user1@example.com   example.com/user1/
   ```

3. Agregar en **_/etc/postfix/virtual_**:

   ```conf
   user1@example.org   user1@example.com
   ```

4. Crear usuario virtual:

   ```sh
   mkdir -p /home/vhosts/example.com
   mkdir -p /home/vhosts/example.org
   groupadd -g 5000 vmail
   useradd -g vmail -u 5000 vmail -d /home/vhosts/
   chown -R vmail:vmail /home/vhosts/
   ```

5. Compilar archivos nuevos:

   ```sh
   postmap /etc/postfix/vmailbox
   postmap /etc/postfix/virtual
   systemctl restart postfix
   ```

6. Probar email:

   ```sh
   apt install mailutils
   echo "Prueba" | mail -s "Prueba" user1@example.com
   tail /var/log/mail.log
   ls /home/vhosts/example.com/user1/new
   ```

### Conectar Dovecot

1. Instalar Dovecot:

   ```sh
   apt install dovecot-imapd
   ```

2. Modificar **_/etc/postfix/master.cf_**:

   ```conf
   dovecot   unix  -       n       n       -       -       pipe
     flags=DRhu user=vmail:vmail argv=/usr/lib/dovecot/deliver -d ${recipient}
   ```

3. Agregar en **_/etc/dovecot/conf.d/10-mail.conf_**:

   ```conf
   mail_location = maildir:/home/vhosts/%d/%n
   mail_privileged_group = vmail
   ```

4. Agregar en **_/etc/dovecot/conf.d/10-auth.conf_**:

   ```conf
   userdb {
     driver = passwd-file
     args = username_format=%n /home/vhosts/%d/passwd
   }

   passdb {
     driver = passwd-file
     args = username_format=%n /home/vhosts/%d/shadow
   }
   ```

5. Editar y agregar en **_/etc/dovecot/conf.d/10-master.conf_**:

   ```conf
   service auth {
     unix_listener /var/spool/postfix/private/auth {
       mode = 0660
       user = postfix
       group = postfix
     }
   }
   ```

6. Agregar usuarios virtuales en **_/etc/dovecot/users_**:

   ```conf
   user1@example.com:{PLAIN}password
   ```

7. Reiniciar servicios:

   ```sh
   systemctl restart postfix
   systemctl restart dovecot
   ```

8. Probar servicio:

```sh
telnet localhost 25
ehlo localhost
mail from: <test@localhost>
rcpt to: <user1@example.com>
data
Subject: Test Email

This is a test email.
.
quit
```

### Habilitar loggeo

- Debian:

  ```sh
  apt install rsyslog
  tail /var/log/mail.log
  ```
