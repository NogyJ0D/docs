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
    - [Tmux](#tmux)
      - [Comandos tmux](#comandos-tmux)
      - [Instalar tmux](#instalar-tmux)
    - [Zoxide](#zoxide)
      - [Instalar zoxide](#instalar-zoxide)
    - [Eza](#eza)
      - [Instalar eza](#instalar-eza)
  - [Extras](#extras)
    - [Crontab](#crontab)

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

---

## Extras

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
