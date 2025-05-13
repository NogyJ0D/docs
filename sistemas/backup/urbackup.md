# urbackup

- [urbackup](#urbackup)
  - [Instalación](#instalación)
    - [Instalar urbackup en Debian 12](#instalar-urbackup-en-debian-12)

---

## Instalación

### Instalar urbackup en Debian 12

1. Descargar paquete buscandoló en <https://www.urbackup.org/download.html#server_debian>:

   ```sh
   wget https://hndl.urbackup.org/Server/2.5.33/debian/bookworm/urbackup-server_2.5.33_amd64.deb
   apt install sqlite3 # Instalar dependencias que pida
   dpkg -i urbackup-server_2.5.33_amd64.deb # Pide la ruta donde va a hacer los backups
   ```

2. Ver si funciona entrando a <http://ip:55414>.
3. Agregar clientes:
   1. Crear cliente en la página de Estado.
   2. Configurar cliente en la página de Ajuste.
   3. Modificar contraseña en Internet/Active client.
   4. Descargar cliente en la página de Estado (Descargar cliente para Windows/Linux)
   5. Instalar en la máquina cliente y configurar lo que falte.
