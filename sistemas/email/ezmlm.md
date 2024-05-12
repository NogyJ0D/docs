# ezmlm

- [ezmlm](#ezmlm)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Aplicaciones](#aplicaciones)
    - [ezmlm-make: crear listas](#ezmlm-make-crear-listas)
  - [ezmlm-manage: administrar suscripciones](#ezmlm-manage-administrar-suscripciones)
  - [ezmlm-web](#ezmlm-web)
    - [Notas](#notas)
  - [Extras](#extras)
    - [Comandos](#comandos)

---

## Documentación

---

## Instalación

---

## Aplicaciones

Directorio: **_/usr/bin/ezmlm_**.

### ezmlm-make: crear listas

- Crear lista

  ```sh
  sudo vpopmail
  /usr/bin/ezmlm/ezmlm-make -u {dir}/carpeta {dir}/.qmail nombre dominio
  # /usr/bin/ezmlm/ezmlm-make -u {dir}/_lista {dir}/.qmail-_lista lista ejemplo.com
  ```

## ezmlm-manage: administrar suscripciones

- ezmlm-send:
  Procesa y distribuye los mensajes enviados.

- ezmlm-archive:
  Guarda copias de los mensajes enviados.

- ezmlm-store ezmlm-get:
  Almacenan y recuperan mensajes del archivo de la lista.

- ezmlm-idx:
  Añade soporte a la indexación de archivos.

- ezmlm-sub ezmlm-unsub:
  Suscribe y cancela suscripciones de correos a la lista.

- ezmlm-moderate:
  Controla que mensajes se distribuyen a los suscriptores basandose en los moderadores.

- ezmlm-confirm:
  Gestiona la confirmación de suscripciones y cancelaciones.

---

## ezmlm-web

### Notas

- Crear una lista usa las opciones:

  - Nombre de la lista.
  - Dirección (local@dominio).
  - Lenguaje.
  - Editor web.

- Opciones de la vista general de una lista:

  - p
  - h
  - j
  - k
  - u
  - y
  - m
  - o
  - q
  - w
  - d
  - 4
  - a
  - b
  - g
  - i
  - r
  - l
  - n
  - 3
  - 5
  - 0
  - 7
  - 8
  - f
  - t
  - msgsize_max_state
  - mgsize_min_state
  - mime type filtering
    - mf_remove
    - mf_keep
    - mimefilter
  - mimereject
  - header filtering
    - hf_remove
    - hf_keep
    - head_filter
  - headeradd
  - copylines_enabled
    - copylines
  - list-language
  - list_charset
  - webusers

- msgsize_max_state y msgsize_min_state son parámetros que se encuentran en el archivo {dir}/\_lista/msgsize. El contenido es: "maximo:minimo" en bytes.

---

## Extras

### Comandos

- Ver listas:

  ```sh
  ls {dir} | grep _
  ```

- Ver dueño de lista:

  ```sh
  cat {dir}/.qmail-_lista-owner
  ```

- Ver moderadores de lista:

  ```sh
  cat {dir}/_lista/mod/subscribers/*
  ```

- Eliminar lista:

  ```sh
  rm {dir}/_lista {dir}/.qmail-_lista*
  ```
