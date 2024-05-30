# Seguridad

- [Seguridad](#seguridad)
  - [openssl](#openssl)
    - [Instalar openssl](#instalar-openssl)
    - [Generar/Renovar certificado](#generarrenovar-certificado)
  - [gpg](#gpg)
  - [Recuperar archivo](#recuperar-archivo)
    - [Analizar archivos](#analizar-archivos)
  - [Extras](#extras)

---

## openssl

### Instalar openssl

```sh
apt install openssl
```

### Generar/Renovar certificado

> Renovar el certificado es el mismo proceso.

1. Generar clave privada:
     - Genera una clave privada RSA de 2048 bits.

    ```sh
    openssl genrsa -out clave_privada.pem 2048
    ```

2. Generar solicitud de firma:

    ```sh
    openssl req -new -key clave_privada.pem -out solicitud.csr
    ```

3. Generar certificado:

   - Autofirmado:

      ```sh
      openssl x509 -req -days 365 -in solicitud.csr -signkey clave_privada.pem -out certificado.crt
      ```

   - Firmado por una autoridad:

      ```sh
      openssl x509 -req -days 365 -in solicitud.csr -CA ca_cert.pem -CAkey ca_clave.pem -CAcreateserial -out certificado.crt
      ```

4. Verificar certificado:

    ```sh
    openssl x509 -in certificado.crt -text -noout
    ```

---

## gpg

---

## Recuperar archivo

- Evento: se formateó una PC y no se respaldó x archivo.

1. Instalar testdisct y escanear disco con photorec

    ```sh
    pacman -S testdisct
    mkdir respaldo
    cd respaldo
    photorec
    ```

2. Mientras se recuperan los archivos buscar el deseado:

    > photorec genera archivos con nombres que no son los originales, ademas de que modifica extensiones. Ej: .js pasa a ser .java.

    ```sh
    find . -type f -name "*.7z" # Buscar archivos recursivamente por nombre con la extensión 7z
    grep -r "palabra" # Buscar archivos recursivamente que contengan la cadena "palabra"
    ```

    - Aplicaciones útiles para ir viendo:
      - p7zip-gui: abrir archivos 7z sin extraer.
      - gedit: editor de texto.
      - thunar: explorador de archivos.

---

### Analizar archivos

- Comando "strings": analiza un archivo y devuelve cadenas de texto "entendibles". En lugar de mostrar basura en un binario, busca lo que puede entender una persona.
  - Se usa como "strings [archivo]".
- Comando "file": devuelve el tipo de archivo del argumento ingresado.
  - Se usa como "file [archivo]".
- Comando "xxd": genera un dump hexadecimal de un archivo y viceversa.
  - Hay que descargarlo. En arch usar "tinyxxd".
  - Se usa como "xxd [archivo]".
  - Si se usa "-b" devuelve en binario en lugar de hexa.
  - Si se usa "-r" transforma hexa al contenido original.
- Comando "objdump": desensambla un binario y muestra el contenido en assembly.
  - Se usa como "objdump -D [archivo]".
- Comando "nm": devuelve los simbolos de un binario.
  - Se usa como "nm [archivo]".

---

## Extras
