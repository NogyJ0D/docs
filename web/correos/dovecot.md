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
apt install dovecot-imapd
systemctl enable --now dovecot
```

---

## Configuración

- La configuración se divide en: **_/etc/dovecot/dovecot.conf_** (archivo principal) y **_/etc/dovecot/conf.d/\*_** (sub-archivos). Lo que hay en **_dovecot.conf_** sobreescribe al resto.

### Habilitar logs

- Descomentar "log_path" en **_/etc/dovecot/conf.d/10-logging.conf_** y agregar ruta.
- Reiniciar servicio.
- Comprobar ejecutando "doveadm log find".

### Configurar para [Postfix](../correos/postfix.md)

- **dovecot.conf**:

    ```conf
    disable_plaintext_auth = no
    auth_mechanisms = plain login cram-md5

    mail_privileged_group = vmail
    mail_location = maildir:/home/vhosts/%d/%n
    mail_uid = vmail
    mail_gid = vmail

    userdb {
            driver = passwd-file
            args = username_format=%n /home/vhosts/%d/users
            default_fields = uid=vmail gid=vmail home=/home/vhosts/%d/%n
    }
    passdb {
            driver = passwd-file
            args = scheme=cram-md5 username_format=%n /home/vhosts/%d/users
    }

    service auth {
            unix_listener /var/spool/postfix/private/auth {
                    mode = 0660
                    user = postfix
                    group = postfix
            }
    }

    protocols = "imap"

    ssl = required
    ssl_cert = </etc/ssl/private/localhost.crt
    ssl_key = </etc/ssl/private/localhost.key
    ssl_min_protocol = TLSv1
    ssl_cipher_list = ALL:!kRSA:!SRP:!kDHd:!DSS:!aNULL:!eNULL:!EXPORT:!DES:!3DE>
    ```

### Configurar para [Exim4 con dominios virtuales](../correos/exim.md#configurar-dominios-virtuales)

- Modificar en **_/etc/dovecot/conf.d/10-auth.conf_**:

    ```conf
    #!include auth-system.conf.ext
    !include auth-vmail.conf.ext
    ```

- Agregar en **_/etc/dovecot/conf.d/auth-vmail.conf.ext_**:

    ```conf
    passdb {
      driver = passwd-file
      args = scheme=CRYPT username_format=%u /etc/exim4/virtual-users
    }

    userdb {
      driver = passwd-file
      args = username_format=%u /etc/exim4/virtual-users
      override_fields = uid=vmail gid=vmail
    }
    ```

- Agregar en **_/etc/dovecot/dovecot.conf_**:

    ```conf
    # Comentar inclusión de protocolos
    disable_plaintext_auth = no
    auth_mechanisms = plain login cram-md5

    mail_privileged_group = vmail
    mail_location = maildir:/home/vhosts/%d/%u
    mail_uid = vmail
    mail_gid = vmail

    protocols = "imap"

    ssl = required
    ssl_cert = </root/localhost.crt
    ssl_key = </root/localhost.key
    ssl_dh = </root/dh.pem
    ssl_min_protocol = TLSv1
    ssl_cipher_list = ALL:!kRSA:!SRP:!kDHd:!DSS:!aNULL:!eNULL:!EXPORT:!DES:!3DE>

    default_process_limit = 500
    default_client_limit = 5000
    default_vsz_limit = 512M
    ```

- Ajuste de seguridad:

    ```sh
    chown dovecot:vmail /etc/exim4/virtual-users
    adduser Debian-exim vmail
    chmod 0660 /etc/exim4/virtual-users
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

### Exportar certificado para Thunderbird

```sh
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12
```

- Puede ser que el test de Thunderbird diga que hay error, pero si funciona al conectarse agregando la cuenta.
