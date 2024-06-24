# Exim

- [Exim](#exim)
  - [Documentación](#documentación)
    - [Proceso de vida del mensaje](#proceso-de-vida-del-mensaje)
    - [Archivo de configuración](#archivo-de-configuración)
  - [Instalación](#instalación)
    - [Instalar Exim4 en Debian 12](#instalar-exim4-en-debian-12)
  - [Comandos](#comandos)
    - [Listar configuración](#listar-configuración)
    - [Listar cola de mails](#listar-cola-de-mails)
  - [Extras](#extras)
    - [Configurar dominios virtuales](#configurar-dominios-virtuales)

---

## Documentación

- Exim es un MTA (Mail Transfer Agent).
  - Maneja dominios en formato RFC 2822.
  - Los mecanismos de transporte implementados son SMTP y LMTP.
  - El archivo de configuración usa el estilo de Smile 3.
  - Usa la interfaz de comandos de Sendmail.
- Exim 4 implementa politicas de control de mails entrantes como _Access Control Lists_ (ACLs). Controla quien puede enviar mails al servidor.
- Cada mensaje que maneja recibe un id de 23 caracteres.

### Proceso de vida del mensaje

- Cuando Exim acepta un mensaje escribe dos archivos en el directorio de cola.
  - El primero (ID-H) contiene la cabecera del mensaje y su estado.
  - El segundo (ID-D) contiene el cuerpo del mensaje.
  - Estos archivos se encuentran en el directorio **_input_** dentro del directorio de cola.
  - Se puede tambien dividir esta carpeta input en 62 subdirectorios.
- Por cada mensaje Exim loggea en el log principal y en otro para cada mensaje.
- Para los mensajes se utilizan _"routers"_ y _"transports"_ llamados _"drivers"_.
  - Cada driver especificado en la configuración es una instancia de ese driver, se pueden tener varias instancias de un driver con distintas configuraciones.
  - Un **router** opera en una dirección, determinando su transport o convirtiendolá en otras direcciones. Tambien puede rechazar direcciones. Ej: se puede tener un router que maneje las direcciones internas y otro para las externas.
    - Una dirección es enviada a cada router hasta que alguno la acepte o la rechace.
    - Cuando todos los ruteos se finalizan, las direcciones aceptadas son asignadas a sus transports.
    - Para que una dirección pase por un router, tienen que cumplirse las condiciones especificadas. Cuando esto sucede, pasa una de las siguientes:
      - _accept_: se acepta la dirección y se envía a un transport.
      - _pass_: el router la reconoce pero no puede manejarla por si mismo y la envía al siguiente router.
      - _decline_: el router no reconoce la dirección y lo declina, pasandoló al siguiente router.
      - _fail_: se genera un mensaje de rebote.
      - _defer_: no se puede procesar la dirección en ese momento, asi que se intenta nuevamente luego.
      - _error_: hay un error en el router.
  - Un **transport** transmite una copia del mensaje desde la cola de Exim a un destino.
    - Cuando un router acepta una dirección, se la asignará a un transport agregandolá a la lista del mismo y será ejecutado luego.

### Archivo de configuración

- Las secciones en este comienzan como "begin [seccion]".
- Se puede dividir la configuración en:
  - Monolítico: un solo archivo.
  - Segmentado: varios archivos pequeños.

---

## Instalación

### Instalar Exim4 en Debian 12

```sh
apt install exim4-daemon-heavy ssl-cert
touch /etc/exim4/conf.d/main/00_exim4-config_custom
```

- Modificar en **_/etc/exim4/update-exim4.conf.conf_**:

  ```conf
  dc_local_interfaces='0.0.0.0.25 : 0.0.0.0.587 : 0.0.0.0.465'
  dc_use_split_config='true'
  dc_localdelivery='maildir_home'
  ```

- Crear certificado:

  ```sh
  openssl req -new -x509 -days 365 -nodes -newkey rsa:2048 -out /etc/ssl/certs/localhost.crt -keyout /etc/ssl/private/localhost.key
  openssl dhparam -out /root/dh.pem 2048
  chmod 640 /etc/ssl/private/localhost.key
  chown root:Debian-exim /etc/ssl/private/localhost.key

  #chown -R root:ssl-cert /etc/letsencrypt
  #find /etc/letsencrypt -type d -exec chmod g+s {} \;
  #chmod -R g+r /etc/letsencrypt
  #adduser Debian-exim ssl-cert
  ```

- Agregar en **_/etc/exim4/main/00_exim4-config_custom_**:

  ```conf
  MAIN_TLS_ENABLE = yes
  tls_on_connect_ports = 465
  daemon_smtp_ports = 25 : 465 : 587

  MAIN_TLS_CERTIFICATE = /etc/ssl/certs/localhost.crt
  MAIN_TLS_PRIVATEKEY = /etc/ssl/private/localhost.key
  ```

- Reiniciar y probar:

  ```sh
  systemctl restart exim4
  tail -f /var/log/exim4/mainlog
  openssl s_client -starttls smtp -connect localhost:25
  ```

---

## Comandos

### Listar configuración

```sh
exim -bP
exim -bP [valor]
```

### Listar cola de mails

```sh
exim -bp
exim -bp [id]
```

---

## Extras

### Configurar dominios virtuales

- Crear usuario vmail:

  ```sh
  mkdir -p /home/vhosts/example.com
  mkdir -p /home/vhosts/example.org
  groupadd -g 5000 vmail
  useradd -g vmail -u 5000 vmail -d /home/vhosts/
  chown -R vmail:vmail /home/vhosts/
  ```

- Agregar usuario virtual:

  - Generar contraseña:

    ```sh
    openssl passwd -1 [contraseña] # Generar contraseña encriptada
    ```

  - Agregar usuario en **_/etc/exim4/virtual-users_**:

    ```passwd
    usuario@example.com:contraseña:,,,:/home/vhosts/example.com/usuario
    ```

- Agregar dominios virtuales en **_/etc/exim4/virtual-domains_**:

  ```conf
  example.com
  example.org
  ```

- Configurar correo entrante:

  - Agregar "MAIN\*LOCAL_DOMAINS = partial-lsearch;CONFDIR/virtual-domains" en \*\**/etc/exim4/conf.d/main/00*exim4-config_custom\*\*\*.
  - Agregar router en **_/etc/exim4/conf.d/router/275_exim4-config_virtual_local_user_**:

    ```conf
    virtual_local_user:
      debug_print = "R: virtual_user for $local_part@$domain"
      driver = accept
      domains = +local_domains
      condition = ${lookup{$local_part@$domain}lsearch*@{CONFDIR/virtual-users}}
      transport = virtual_local
    ```

  - Agregar transport en **_/etc/exim4/conf.d/transport/30_exim4-config_virtual_**:

    ```conf
    virtual_local:
      debug_print = "T: virtual_local for $local_part@$domain"
      driver = appendfile
      # directory= ${extract{5}{:}{${lookup{$local_part@$domain}\
      #                lsearch{CONFDIR/virtual-users}{$value}}}}/\
      #            ${if eq {$h_X-Spam-Flag:}{YES} {.Junk/}}

      directory = ${extract{5}{:}{${lookup{$local_part@$domain}\
                      lsearch{CONFDIR/virtual-users}{$value}}}}
      delivery_date_add
      envelope_to_add
      return_path_add
      maildir_format
      mode = 0660
      mode_fail_narrower = false
      user=vmail
      group=vmail
    ```

  - Probar:

    ```sh
    tail -f /var/log/exim4/mainlog
    echo "Hola" | mail usuario@example.com -s "Prueba"
    ls /home/vhosts/example.com/usuario
    ```

- Configurar correo saliente:

  - Desactivar auth default:

    ```sh
    cd /etc/exim4/conf.d/auth
    mv 30_exim4-config_examples 30_exim4-config_examples.disabled
    ```

  - Agregar configuración en **_/etc/exim4/conf.d/auth/30_exim4-auth_vmail_**:

    ```conf
    login_server:
      driver = plaintext
      public_name = LOGIN
      server_prompts = "Username:: : Password::"
      server_condition = "${if crypteq{$auth2}{${extract{1}{:}{${lookup{$auth1}lsearch{CONFDIR/virtual-users}{$value}{*:*}}}}}{1}{0}}"
      server_set_id = $auth1
      .ifndef AUTH_SERVER_ALLOW_NOTLS_PASSWORDS
      server_advertise_condition = ${if eq{$tls_in_cipher}{}{}{*}}
      .endif
    ```

  - Probar auth:

    ```sh
    systemctl restart exim4

    echo -ne "usuario@example.com" | base64 # Copiar resultado
    echo -ne "contraseña" | base64          # Copiar resultado

    openssl s_client -starttls smtp -connect localhost:25
    EHLO prueba.com
    AUTH LOGIN
    # Pegar email
    # Pegar contraseña
    # Tiene que responder 235 Authentication succeeded
    QUIT
    ```

- Agregar Dovecot.
