# [pass](https://www.passwordstore.org/)

Gestor de contraseñas

- [pass](#pass)

---

## Instalación

```sh
pacman -S pass gnupg vi xclip # Arch
apt install pass # Debian
```

- Iniciar pass en el usuario:

  ```sh
  gpg --full-gen-key
  gpg -K # Copiar ID de la clave generada
  pass init [id]
  ```

---

## Comandos

- Listar contraseñas:

  ```sh
  pass
  ```

- Agregar contraseña:

  ```sh
  pass insert [cat1/cat2/nombre]
  ```

- Ver contraseña:

  ```sh
  pass [ruta]
  pass -c [ruta] # Copiar al portapapeles si se tiene xclip
  ```

- Generar contraseña:

  ```sh
  pass generate [ruta] [cant. caract.]
  ```

- Editar contraseña:

  ```sh
  pass edit [ruta]
  ```

---

## Extras

### Agregar información

- Editar contraseña.
- Campos:
  - URL: _.example.com/_
  - Username: pepe
  - Secret Question 1: ¿Pregunta? Respuesta
  - Phone Support Pin #: 12345

### Agregar OTP

- Instalar pass-otp:

  ```sh
  pacman -S pass-otp # Arch
  apt install pass-extension-otp # Debian
  ```

- Comandos:
  - Agregar otp: pass otp insert [ruta]
  - Agregar otp a contraseña existente: pass otp append [ruta]
  - Ver url de la clave: pass otp uri [-q ver qr] [ruta]
