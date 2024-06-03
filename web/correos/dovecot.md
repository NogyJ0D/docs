# Dovecot

> Servidor IMAP y POP3.

- [Dovecot](#dovecot)

---

## [Documentación](https://doc.dovecot.org/)

- Está compuesto por multiples procesos que se inician bajo demanda.
  - Master (dovecot): es el proceso principal que inicia el a los demás.
  - Log (log)
  - Config (config)
  - Authentication (auth)
  - Login (imap-login, pop3-login)
  - Mail (imap, pop3, lmtp)

### [Autenticación](https://doc.dovecot.org/configuration_manual/authentication/)

- La autenticación se divide en:
  - [Authentication mecanisms](https://doc.dovecot.org/configuration_manual/authentication/authentication_mechanisms/#authentication-sasl-mechanisms):
    - La autenticación suele realizarse por texto plano (y protegido por SSL).
    - Los mecanismos de autenticación se habilitan en **_/etc/dovecot/conf.d/10-auth.conf_** > _auth\_mechanisms_.
    - Hay tambien mecanismos de contraseñas cifradas (que requieren igualmente que las contraseñas sean visibles en su archivo) como cram-md5, scram-sha-256, etc.
  - [Password schemes](https://doc.dovecot.org/configuration_manual/authentication/password_schemes/#authentication-password-schemes):
    - Es el formato en el que se guardan las contraseñas en el passdb.
  - [Password databases (passdb)](https://doc.dovecot.org/configuration_manual/authentication/password_databases_passdb/#password-databases-passdb):
    - Tipos de bases:
      - Success/failure database: devuelve "success" o "failure", no la contraseña.
      - Lookup dtabase: devuelve datos del usuario como la contraseña o el nombre.
  - [User databases (userdb)](https://doc.dovecot.org/configuration_manual/authentication/user_databases_userdb/#user-databases-userdb):
    - Devuelve información del usuario luego de que se autenticó.
- Se puede habilitar la autenticación con [SQL](https://doc.dovecot.org/configuration_manual/authentication/sql/).

---

## Instalación

### Instalar Dovecot en Debian 12

- Paquetes en aptitude:
  - [dovecot-core](https://packages.debian.org/bookworm/dovecot-core): paquete base.
  - [dovecot-imapd](https://packages.debian.org/bookworm/dovecot-imapd): agregado para IMAP.
  - [dovecot-pop3d](https://packages.debian.org/bookworm/dovecot-pop3d): agregado para POP3.
  - [dovecot-antispam](https://packages.debian.org/bookworm/dovecot-antispam): agregado para entrenar al anti-spam.
  - [dovecot-mysql](https://packages.debian.org/bookworm/dovecot-mysql): agregado para usar mysql.
  - [dovecot-pgsql](https://packages.debian.org/bookworm/dovecot-pgsql): agregado para usar postgres.
  - [dovecot-ldap](https://packages.debian.org/bookworm/dovecot-ldap): agregado para soporte LDAP.

```sh
apt install dovecot-core dovecot-imapd
systemctl enable --now dovecot
```

---

## Configuración

- La configuración se divide en: **_/etc/dovecot/dovecot.conf_** (archivo principal) y **_/etc/dovecot/conf.d/\*_** (sub-archivos).
  - **dovecot.conf**:

    ```conf
    # En que IP debe escuchar. Cambiar por listen = x.x.x.x
    listen = *; ::
    ```

  - **conf.d/10-auth.conf**:

    ```conf
    # Por defecto está en yes. Si está habilitado, deshabilita el comando de login y la autenticación por texto plano.
    disable_plaintext_auth = no
    # Mecanismos de autenticación habilitados.
    auth_mechanisms = plain login cram-md5
    ```

  - **conf.d/10-mail.conf**:

    ```conf
    # Donde están guardados los mails.
    mail_location = maildir:~/Maildir
    ```

  - **conf.d/10-ssl.conf**:

    ```sh
    ssl = required

    ssl_cert = </etc/letsencrypt/live/dom/fullchain.pem
    ssl_key = </etc/letsencrypt/live/dom/privkey.pem
    ```

---

## Comandos

---

## Extras

### [Migrar mailboxes desde otro Dovecot](https://doc.dovecot.org/admin_manual/migrating_mailboxes/#migrating-mailboxes-from-another-dovecot)

- La versión de Dovecot del sistema viejo debe ser 2.1.14+.

1. Habilitar doveadm en **_/etc/dovecotd/conf.d/10-doveadm.conf_**:

   1. En el servidor viejo agregar:

      ```conf
      service doveadm {
        inet_listener {
          port = 12345
        }
      }

      doveadm_password = [contraseña]
      ```

   2. En el servidor nuevo:

      ```conf
      doveadm_password = [misma contraseña]
      ```

2. Iniciar migración:

   1. Migrar usuarios (usar uno):

      ```sh
      doveadm backup -Ru username tcp:[host]:[port] # El destino queda exactamente igual al origen.
      doveadm sync -u username tcp:[host]:[port] # Agrega lo del origen al destino sin pisar.
      ```
