# Seguridad

- [Seguridad](#seguridad)

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

## Extras
