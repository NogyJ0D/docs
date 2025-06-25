# General

- [General](#general)
  - [Documentación](#documentación)
  - [Aplicaciones](#aplicaciones)
    - [⭐ trash-cli](#-trash-cli)
      - [Instalar trash-cli](#instalar-trash-cli)
    - [⭐ bat](#-bat)
      - [Instalar bat](#instalar-bat)
    - [Tmux](#tmux)
      - [Comandos tmux](#comandos-tmux)
      - [Instalar tmux](#instalar-tmux)
    - [Zoxide](#zoxide)
      - [Instalar zoxide](#instalar-zoxide)
    - [Eza](#eza)
      - [Instalar eza](#instalar-eza)
    - [⭐ pipx](#-pipx)
      - [Instalar pipx](#instalar-pipx)
    - [frogmouth](#frogmouth)
      - [Instalar frogmouth](#instalar-frogmouth)
  - [Extras](#extras)
    - [Habilitar ssh como root](#habilitar-ssh-como-root)
    - [Transferir archivos entre máquinas](#transferir-archivos-entre-máquinas)
    - [Agregar VLAN con NetworkManager CLI](#agregar-vlan-con-networkmanager-cli)
    - [SSH](#ssh)
      - [Configuración ideal](#configuración-ideal)
      - [Configuración ssh](#configuración-ssh)
      - [Claves ssh](#claves-ssh)
    - [Crontab](#crontab)
    - [Poner en hora con ntp](#poner-en-hora-con-ntp)
    - [Poner en hora con chrony](#poner-en-hora-con-chrony)
    - [TRIM para SSD](#trim-para-ssd)
    - [Colores para la terminal](#colores-para-la-terminal)
    - [Agregar linux a Samba AD](#agregar-linux-a-samba-ad)
      - [Agregar auto montado de carpetas compartidas](#agregar-auto-montado-de-carpetas-compartidas)

---

## Documentación

---

## Aplicaciones

- [Lista de aplicaciones de todo tipo](https://terminaltrove.com/categories/linux/).

### ⭐ trash-cli

- Permite enviar archivos a una papelera y gestionarla.

#### Instalar trash-cli

```sh
pacman -S trash-cli # Arch
```

### ⭐ bat

- Muestra textos como less pero mejor visualmente y con soporte para git.

#### Instalar bat

```sh
pacman -S bat # Arch
```

### Tmux

- Multiplexor de terminales.
- Permite sesiones persistentes.
- [Cheatsheet](https://tmuxcheatsheet.com/).
- El iniciador de comandos es Ctrl + B.

#### Comandos tmux

```sh
# Nueva sesión
tmux
# Nueva sesión con nombre
tmux new -s nombre
# Listar sesiones
tmux ls
# Entrar a sesión
tmux a -t nombre
# Cerrar sesión con nombre
tmux kill-session -t nombre
# Cerrar todas las sesiones
tmux kill-session -a
# Renombrar sesión
Ctrl+B $
# Salir de sesión sin cerrar
Ctrl+B D
# Crear panel horizontal
Ctrl+B %
# Crear panel vertical
Ctrl+B \" # sin \
# Moverse al siguiente panel
Ctrl+B O
# Moverse entre paneles
Ctrl+B Q N
Ctrl+B Flechas
# Activar mouse
Ctrl+B : set mouse on
```

#### Instalar tmux

```sh
sudo apt install tmux -y
```

### Zoxide

- Reemplazo a comando **_cd_**.
- Comando: **_z_**.

#### Instalar zoxide

```sh
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
echo "eval '$(zoxide init zsh)'" >> ~/.zshrc
```

### Eza

- Reemplazo a comando **_ls_**.
- Comando: **_eza_**.
- Parámetros:
  - -1 : lista sin información.
  - -l : lista.
  - -R : recursivo.
  - -T : en árbol.
  - --icons : muestra íconos.
  - -a : muestra ocultos.
  - -r : orden reverso.
  - -s=field : orden según campo.

#### Instalar eza

```sh
cargo install eza
```

### ⭐ pipx

- Alternativa a pip.
- Útil para instalar aplicaciones de pip.

#### Instalar pipx

```sh
pacman -S python-pipx # Arch
```

### frogmouth

- Lector de markdwon desde la terminal.

#### Instalar frogmouth

```sh
pipx install frogmouth
```

---

## Extras

### Habilitar ssh como root

```sh
sed -i -e 's/#Port 22/Port 22/' -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && service sshd restart && ip a
```

### Transferir archivos entre máquinas

> rsync es mas rápido que scp y permite resumir transferencias.

```sh
rsync --rsh=ssh -vP archivo host@ip:/destino
```

- --rsh=ssh: hacerlo tan seguro como scp.
- -v: verbose.
- -P: resumir transferencias parciales.

### Agregar VLAN con NetworkManager CLI

```sh
nmcli con # Ver conexiones
nmcli con add type vlan con-name [nombre] ifname [nombre] dev [interfaz] id [tag]
# nmcli con add type vlan con-name vlan10 ifname vlan10 dev eth0 id 10
nmcli con modify [nombre] ipv4.addresses [ip/msk] ipv4.method manual # Agregar IP fija
nmcli con up [nombre] # Persistir configuración
nmcli con mod [nombre] connection.autoconnect yes # Que se conecte al iniciar
nmcli con # Ver cambios
```

### SSH

#### Configuración ideal

- En un host la mejor configuración es:

  - **_/etc/ssh/sshd_config_**:

    ```conf
    Port 22
    ChallengeResponseAuthentication no
    PasswordAuthentication no
    UsePAM no
    PermitRootLogin no
    ```

    - **Port**: 22 o alternativo.
    - **ChallengeResponseAuthentication** + **PasswordAuthentication** + **UsePAM**: deshabilitar inicio por contraseña y usar [claves](#claves-ssh).
    - **PermitRootLogin**: desahbilitar usuario root, conectarse como usuario normal y elevar con "su -".

- Esta debe aplicarse luego de generar la clave y agregarla.

#### Configuración ssh

- Se puede crear un archivo para almacenar sesiones.

  - El archivo se encuentra en **_$HOME/.ssh/config_**.
  - Con este archivo, hay que hacer ssh a los hosts agregados.
  - Contenido del archivo:

    ```conf
    Host [nombre]
      HostName [ip]
      User [usuario a usar]
      Port [opcional]

    Host * # configuración para todos
      User root
    ```

  - Útil con el programa [sshclick](https://github.com/karlot/sshclick).

#### Claves ssh

- Se pueden generar claves públicas para agregar al cliente ssh.
- Cuando genero mi par de claves privada y pública, copio la pública a un host remoto para que este acepte mi conexión usando la clave.
- Con esto, puedo desactivar ssh por contraseña y usar solo claves.

- Generar clave:

  ```sh
  ssh-keygen -t ed25519 -C "email@dom.com"
  ```

- Para enviar la clave al host remoto:
  - Ejecutar "ssh-copy-id usuario@host-remoto".
  - Copiar el contenido de la llave pública y pegarlo en **_.ssh/authorized_keys_**.

### Crontab

- [Página para ver las reglas](https://crontab.guru/).

- Formato de regla cron:

  ```text
  m h dom mon dow user command
  ```

  - m: minuto (0-59).
  - h: hora (0-23).
  - dom: día del mes.
  - mon: mes (0-12).
  - dow: día de la semana (0-7).
  - user: usuario que ejecuta el comando.
  - command: comando a ejecutar.

  - Ejemplo:

    ```cron
    15 10 * * * usuario /home/usuario/scripts/actualizar.sh
    ```

    El usuario ejecuta el comando todos los dias a las 10:15 am.

- Modificar el crontab:

  ```sh
  crontab -e # Default root
  crontab -u usuario -e
  ```

  - El archivo está en **_/var/spool/cron/crontabs/usuario_**. Es mejor modificarlo con el comando.

  - Si da error al seleccionar editor:

    ```sh
    export EDITOR=nano
    crontab -e
    ```

### Poner en hora con ntp

1. Desinstalar `systemd-timesyncd` si existe e instalar `ntp`.
2. (Opcional, agregar servidor) Agregar en **_/etc/ntpsec/ntp.conf_** y reiniciar `ntp.service`:

   ```sh
   server [ip] [prefer] # Agregar prefer para que use ese primero
   ```

3. Probar sync con `ntpq -p` y ver hora con `date`.
4. Si no sincroniza:
   - Ejecutar `ntpq -c as` y ver si los servidores salen como _reject_.
   - Ejecutar `hwclock -r` y ver la hora de la bios, poner manualmente la fecha con `date -s "2 OCT 2006 18:00:00"` y sincronizar a la bios con `hwclock --systohc`.
   - Reiniciar y volver a ver `ntpq -c as` si alguno sale como _candidate_.

### Poner en hora con chrony

1. Desinstalar `systemd-timesyncd` si existe e instalar `chrony`.
2. (Opcional, agregar servidor) Agregar en **_/etc/chrony/chrony.conf_**:

   ```sh
   server [ip]
   ```

3. Activar ntp en timedatectl con `timedatectl set-ntp true`.
4. Reiniciar servicio con `systemctl restart chronyd`.
5. Probar fuentes con `chronyc sources [-v]`.
6. Darle unos minutos para que sincronize y revisar con `date`.

### TRIM para SSD

1. Verificar soporte TRRIM:

   ```sh
   lsblk --discard
   # Si  DISC_GRAN y DISC_MAX devuelven distinto a 0, el disco soporta TRIM
   ```

2. Habilitar TRIM periódico:

   ```sh
   systemctl enable --now fstrim.timer
   ```

### Colores para la terminal

- iproute2:

  ```sh
  alias ip='ip -color=auto'
  ```

- less:

  ```sh
  alias less='less -R --use-color -Dd+r -Du+b'
  ```

### Agregar linux a Samba AD

1. Instalar Debian 12 con Gnome o KDE.
2. Instalar paquetes:

   ```sh
   apt install realmd sssd oddjob oddjob-mkhomedir adcli samba-common packagekit sssd-tools
   ```

3. Agregar dominio:

   ```sh
   realm join --user=administrator DOMINIO.LOCAL
   ```

4. Editar **_/etc/sssd/sssd.conf_**:

   ```conf
   [sssd]
   domains = DOMINIO.LOCAL
   config_file_version = 2
   services = nss, pam

   [domain/dominio.local]
   default_shell = /bin/bash
   krb5_store_password_if_offline = False
   cache_credentials = False
   krb5_realm = DOMINIO.LOCAL
   realmd_tags = manages-system joined-with-adcli
   id_provider = ad
   fallback_homedir = /home/%u
   ad_domain = dominio.local
   use_fully_qualified_names = False
   ldap_id_mapping = True
   access_provider = ad
   enumerate = True
   auth_provider = ad
   ad_gpo_access_control = disabled
   ```

5. Editar **_/etc/samba/smb.conf_**:

   ```conf
   [global]
   workgroup = GRUPO # Cambiar grupo si se necesita
   ```

6. Elegir session manager:

   - Con GNOME y GDM:

     1. Editar **_/etc/gdm3/greeter.dconf-defaults_**:

        ```conf
        disable-user-list=true
        sleep-inactive-ac-timeout=0
        sleep-inactive-ac-type='nothing'
        sleep-inactive-battery-timeout=0
        sleep-inactive-battery-type='nothing'
        ```

   - Con KDE y Lightdm:

     1. Instalar ligthdm:

        ```sh
        apt install lightdm lightdm-gtk-greeter
        systemctl disable sddm
        systemctl enable lightdm
        ```

7. Ejecutar:

   ```sh
   rm -f /var/lib/sss/db/cache_DOMINIO.ldb
   pam-auth-update # Activar "Create home directory on login"
   reboot # Entrar como usuario de dominio
   ```

- Borrar usuario por defecto de Debian:

  ```sh
  userdel -r usuario
  ```

#### Agregar auto montado de carpetas compartidas

1. Instalar pam-mount y cifs:

   ```sh
   apt install libpam-mount cifs-utils
   ```

2. Editar **_/etc/security/pam_mount.conf.xml_**:

   ```xml
   <pam_mount>
     <debug enable="0" />

     <volume user="usuario" fstype="cifs" server="servidor" path="carpeta compartida" mountpoint="/mnt/carpeta" />
     <!-- Agregar esta linea por cada usuario y carpeta a mostrar -->

     <mntoptions allow="nosuid,nodev,loop,encryption,fsck,nonempty,allow_root,allow_other" />
     <mntoptions require="nosuid,nodev" />

     <logout wait="0" hup="no" term="no" kill="no" />

     <mkmountpoint enable="1" remove="true" />
   </pam_mount>
   ```
