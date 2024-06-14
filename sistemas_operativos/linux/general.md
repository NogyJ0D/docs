# General

---

## Contenido

- [General](#general)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
    - [Habilitar ssh como root](#habilitar-ssh-como-root)
    - [Transferir archivos entre máquinas](#transferir-archivos-entre-máquinas)
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
    - [SSH](#ssh)
      - [Configuración ideal](#configuración-ideal)
      - [Configuración ssh](#configuración-ssh)
      - [Claves ssh](#claves-ssh)
    - [Crontab](#crontab)
    - [TRIM para SSD](#trim-para-ssd)
    - [Colores para la terminal](#colores-para-la-terminal)

---

## Documentación

---

## Comandos

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
