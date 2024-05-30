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
  - Monolítico: un solo archivo. Mejor.
  - Segmentado: varios archivos pequeños.


---

## Instalación

### Instalar Exim4 en Debian 12

```sh
apt install exim4
exim -bV
dpkg-reconfigure exim4-config # Genera archivo de configuración
```

- Colas: /var/spool/exim4/

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
