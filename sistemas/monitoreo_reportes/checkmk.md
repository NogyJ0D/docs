# Checkmk

---

## Contenido

- [Checkmk](#checkmk)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar checkmk en Debian 12](#instalar-checkmk-en-debian-12)
  - [Extras](#extras)
    - [Añadir un host](#añadir-un-host)
    - [Monitorear Proxmox VE](#monitorear-proxmox-ve)

---

## Documentación

---

## Instalación

### Instalar checkmk en Debian 12

1. Copiar [link de descarga](https://checkmk.com/download?method=cmk&edition=cre&version=2.2.0p22&platform=debian&os=mantic&type=cmk&google_analytics_user_id=) de versión RAW.

    ```sh
    wget https://download.checkmk.com/checkmk/2.2.0p22/check-mk-raw-2.2.0p22_0.bookworm_amd64.deb

    apt install ./check-mk-raw-*
    ```

2. Crear página:

    ```sh
    omd create pagina
    omd start pagina
    omd su pagina
      > cmk-passwd cmkadmin contraseña
    ```

3. [Añadir hosts](#añadir-un-host).

---

## Extras

### Añadir un host

1. En la página ir a Setup > Agent > OS y descargar el agente.

2. Instalación en debian:

    ```sh
    wget http://x/pagina/check-mk-agent-*
    dpkg -i check-mk-agent-*
    ```

3. Ir a Setup > Hosts > Hosts, agregar el host y en Changes activarlo.

4. En una consola activar el host:

   - Linux:

     ```sh
     cmk-agent-ctl register --hostname "host" --server "ip" --site pagina --user cmkadmin --password "x"
     ```

   - Windows:

     ```sh
     "C:\Program Files (x86)\checkmk\service\cmk-agent-ctl.exe" register --hostname "x" --server "x" --site pagina --user cmkadmin --password "x"
     ```

5. En la pagina hacer un connection test y service discovery del host. En el service discovery hay que aceptar los servicios a monitorear.

### Monitorear Proxmox VE

1. Configurar proxmox:

   1. Crear grupo "Read_Only".

   2. Crear usuario "checkmk" en el realm PVE y con el grupo "Read_Only".

   3. Agregar el permiso de grupo en "/" a "Read_Only" con el rol "PVEAuditor".

2. [Instalar el agente](#añadir-un-host) en el pve pero el "Checkmk agent / API integrations" debe ser "Configured API integrations and Checkmk agent".

3. Crear la regla de monitoreo.

   1. En "Setup" buscar "Proxmox" e ir a "Proxmox VE" bajo "VM, Cloud, Container" y agregar regla.

   2. Tildar "Username" y "Password". El usuario Cdebe ser "checkmk@pve".

   3. En "Conditions" tildar "Explicit hosts" y agregar los hosts de los proxmox a monitorear. Guardar, aplicar cambios y escanear servicios del host.
