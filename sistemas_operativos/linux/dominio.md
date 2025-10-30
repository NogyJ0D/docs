# Dominio

- [Dominio](#dominio)
  - [Conceptos](#conceptos)
    - [Dominio](#dominio-1)
    - [Kerberos](#kerberos)
    - [SSSD](#sssd)
  - [Agregar distro a dominio](#agregar-distro-a-dominio)
    - [Ubuntu y flavors](#ubuntu-y-flavors)
  - [Extras](#extras)
    - [Problemas](#problemas)
    - [Deshabilitar complejidad de contraseña](#deshabilitar-complejidad-de-contraseña)
    - [Agregar auto montado de carpetas compartidas](#agregar-auto-montado-de-carpetas-compartidas)

---

## Conceptos

### Dominio

- Grupo lógico de computadoras y usuarios en una red. Centraliza la administración de recursos, seguridad y cuentas.
- Un controlador de dominio (DC) almacena las cuentas de usuarios, políticas de grupo y otra información relacionada.

### Kerberos

- Protocolo de autenticación basado en tickets. Un usuario que quiere acceder a un recurso solicita un ticket al _Kerberos Key Distribution Center (KDC)_ unido al dominio.
- Cuando un usuario quiere acceder a un recurso, Kerberos le pide que demuestre su autenticidad solicitando su contraseña. Si es correcta, le devuelve un TGT y una clave de sesión.
- Tickets:
  - TGT (Ticket Granting Ticket): ticket maestro para obtener otros tickets.
  - Service Tickets: tickets específicos para servicios (LDAP, SMB, etc).
- Comandos:

  ```sh
  # Con krb5-user
  kinit usuario@DOMINIO
  klist
  klist -f
  kdestroy
  ```

### SSSD

- _System Security Services Daemon (SSSD)_ es un servicio que provee una interfaz común para obtener información de usuarios y grupos de distintos lugares, incluyendo _Active Directory (AD)_.
- Cachea la información localmente para permitir acceso offline.

## Agregar distro a dominio

### Ubuntu y flavors

1. Requisitos:

   ```sh
   sudo apt update
   sudo apt install realmd sssd sssd-tools krb5-user libnss-sss libpam-sss adcli samba-common-bin packagekit libpam-krb5
   ```

   - `/etc/hosts`:

     ```txt
     x.x.x.x sa.dom.local dom.local sa
     ```

2. Editar `/etc/krb5.conf` dejando el servidor deseado:

   ```conf
   [libdefaults]
     default_realm = DOM.LOCAL
     ticket_lifetime = 8h
     renew_lifetime = 0s

   [realms]
     DOM.LOCAL = {
       kdc = sa
       admin_server = sa
     }

   [domain_realm]
     .dom.local = DOM.LOCAL
     dom.local = DOM.LOCAL
   ```

3. Unirse a dominio:

   ```sh
   kinit administrator
   klist # Ver si está el ticket creado
   kdestroy # Destruir el ticket
   sudo realm join -v -U administrator
   sudo realm permit --all
   ```

4. Configurar SSSD:

   - Editar `/etc/sssd/sssd.conf` si hace falta, mirar los comentarios:

     ```conf
     [sssd]
     config_file_version = 2
     services = nss, pam
     domains = dominio.local

     [domain/dominio.local]
     ad_server = dominio.local # O sa.dom.com, ver como lo crea
     ad_domain = dominio.local
     krb5_realm = DOMINIO.LOCAL
     realmd_tags = manages-system joined-with-adcli
     krb5_store_password_if_offline = False # No loguearse offline
     cache_credentials = False # No loguearse offline
     id_provider = ad
     default_shell = /bin/bash
     ldap_id_mapping = True
     use_fully_qualified_names = False # No incluir dominio en el nombre
     fallback_homedir = /home/%u # No incluir dominio en el nombre
     access_provider = ad
     enumerate = False # No cargar todos los usuarios
     ad_gpo_access_control = permissive # Agregar solo si falla el login de usuarios. Es un parche, no una solución
     ```

   - Aplicar los permisos correctos:

     ```sh
     sudo chmod 600 /etc/sssd/sssd.conf
     ```

5. Crear carpeta home automáticamente:

   ```sh
   sudo pam-auth-update --enable mkhomedir
   ```

6. Editar `/etc/samba/smb.conf`:

   ```conf
   [global]
   workgroup = GRUPO # Cambiar grupo si se necesita
   ```

7. Configurar gdm3:

   - Editar `/etc/gdm3/custom.conf`:

     ```conf
     WaylandEnable=false
     DefaultSession=gnome-xorg.desktop
     ```

   - Editar `_/etc/gdm3/greeter.dconf-defaults_`:

     ```conf
     disable-user-list=true
     sleep-inactive-ac-timeout=0
     sleep-inactive-ac-type='nothing'
     sleep-inactive-battery-timeout=0
     sleep-inactive-battery-type='nothing'
     ```

## Extras

### Problemas

- Kerberos da error al iniciar sesión (luego de iniciar con gdm):

  - Revisar con `klist` si se genera el ticket. Si no se genera, revisar si está `libpam-krb5` instalado y si está incluido en `/etc/pam.d/common-auth`, ej:

    ```conf
    # here are the per-package modules (the "Primary" block)
    auth    [success=3 default=ignore]      pam_krb5.so minimum_uid=1000
    auth    [success=2 default=ignore]      pam_unix.so nullok try_first_pass
    auth    [success=1 default=ignore]      pam_sss.so use_first_pass
    # here's the fallback if no module succeeds
    auth    requisite                       pam_deny.so
    # prime the stack with a positive return value if there isn't one already;
    # this avoids us returning an error just because nothing sets a success code
    # since the modules above will each just jump around
    auth    required                        pam_permit.so
    # and here are more per-package modules (the "Additional" block)
    auth    optional                        pam_cap.so
    # end of pam-auth-update config
    ```

### Deshabilitar complejidad de contraseña

- Permitir que se usen palabras comunes en las contraseñas.
- Editar `/etc/pam.d/common-password`:

  ```ini
  # Agregar dictcheck=0
  password    requisite    pam_pwquality.so dictcheck=0 retry=3
  ```

### Agregar auto montado de carpetas compartidas

1. Instalar utilidades

   ```sh
   apt install cifs-utils
   ```

2. Agregar scripts

   - `/usr/local/bin/dominio/pam-mount-trigger.sh`:

     ```sh
     #!/bin/bash

     USUARIO="$PAM_USER"
     ACCION="$1" # open | close

     if groups "$USUARIO" 2>/dev/null | grep -q "domain users"; then
       case "$ACCION" in
         "open")
           systemctl start "montaje-fapyd@$USUARIO.service"
           ;;
         "close")
           systemctl stop "montaje-fapyd@$USUARIO.service"
           ;;
       esac
     fi
     ```

   - `/usr/local/bin/dominio/montaje-red.sh`:

     ```sh
     #!/bin/bash

     SMB_SERVER="sa"
     DOMINIO="dominio.local"
     USUARIO="$1"
     RUTA_BASE="/home/$USUARIO"

     log_message() {
       echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "/var/log/montaje-red-$USUARIO.log"
       echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
     }

     montar() {
       local grupo="$1"
       local montaje="$2"

       log_message "Intentando montar $grupo en $montaje"

       mkdir -p "$montaje"
       chown "$USUARIO:domain users" "$montaje" 2>/dev/null

       if mountpoint -q "$montaje"; then
         log_message "$montaje ya está montado"
         return 0
       fi

       # Buscar el ticket del usuario
       export KRB5CCNAME="$(ls -Art /tmp/krb5cc_$(id -u "$USUARIO")* | tail -n 1)"
       log_message "Clave encontrada: $KRB5CCNAME |"
       if mount -t cifs "//$SMB_SERVER/$grupo" "$montaje" \
         -o sec=krb5,multiuser,cruid=$(id -u "$USUARIO"),cache=strict,file_mode=0755,dir_mode=0755,uid=$(id -u),gid=$(id -g),iocharset=utf8 2>> "/var/log/montaje-red-$USUARIO.log"; then
         log_message "Montado exitosamente: //$SMB_SERVER/$grupo -> $montaje"

         export KRB5CCNAME=""

         local desktop_link="$HOME/Escritorio/$grupo"
         if [[ ! -e "$desktop_link" ]]; then
           ln -s "$montaje" "$desktop_link" 2>/dev/null || true
           log_message "Creado enlace en escritorio: $desktop_link"
         fi

         return 0
       else
         export KRB5CCNAME=""
         log_message "ERROR: Falló el montaje de //$SMB_SERVER/$grupo"
         return 1
       fi
     }

     if [ -z "$USUARIO" ]; then
       log_message "No hay usuario por defecto, cambiando a $USER"
       USUARIO="$USER"
     fi

     if ! id "$USUARIO" &>/dev/null; then
       log_message "Usuario $USUARIO no encontrado"
       exit 1
     fi

     log_message "Iniciando montaje para usuario $USUARIO"

     # Por cada grupo, montar
     groups "$USUARIO" | tr ' ' '\n' | grep -v "^$USUARIO$" | while read -r grupo; do
       limpio=$(echo "$grupo" | sed 's/domain users//g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

       if [ -n "$limpio" ] && [ "$limpio" != "domain" ] && [ "$limpio" != "users" ] && [ "$limpio" != ":" ] && [ "$limpio" != "sudo" ]; then
         montar "$limpio" "$RUTA_BASE/$limpio"
       fi
     done

     log_message "Montaje completado para usuario $USUARIO"
     ```

   - `/usr/local/bin/dominio/desmontaje-red.sh`:

     ```sh
     #!/bin/bash

     USUARIO="$1"
     if [ -z "$USUARIO" ]; then
         USUARIO="$USER"
     fi

     MOUNT_BASE="/home/$USUARIO"

     log_message() {
         echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "/var/log/montaje-red-$USUARIO.log"
         echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
     }

     log_message "Iniciando desmontaje para usuario $USUARIO"

     # Desmontar todas las carpetas del usuario
     find "$MOUNT_BASE" -maxdepth 1 -type d 2>/dev/null | while read -r mountpoint; do
         if mountpoint -q "$mountpoint" 2>/dev/null; then
             log_message "Desmontando $mountpoint"
             timeout 60 umount -l "$mountpoint" 2>/dev/null || true
             umount -l "$mountpoint" 2>/dev/null || true
             if [ $? -eq 0 ]; then
                 log_message "Desmontaje exitoso: $mountpoint"
                 # Eliminar directorio vacío
                 rmdir "$mountpoint" 2>/dev/null
             else
                 log_message "Error al desmontar $mountpoint"
             fi
         fi
     done

     log_message "Desmontaje completado para usuario $USUARIO"
     ```

   - `/etc/systemd/system/montaje-dominio@.service`:

     ```sh
     [Unit]
     Description=Montaje de red para el usuario %i
     After=network-online.target sssd.service
     Wants=network-online.target
     BindsTo=user@%i.service

     [Service]
     Type=oneshot
     RemainAfterExit=yes
     User=root
     ExecStart=/usr/local/bin/dominio/montaje-red.sh %i
     ExecStop=/usr/local/bin/dominio/desmontaje-red.sh %i
     TimeoutStartSec=30
     TimeoutStopSec=90
     KillMode=mixed

     [Install]
     WantedBy=multi-user.target
     ```

   - Agregar al final de `/etc/pam.d/common-session`:

     ```sh
     session optional pam_exec.so type=open_session /usr/local/bin/dominio/pam-mount-trigger.sh open
     session optional pam_exec.so type=close_session /usr/local/bin/dominio/pam-mount-trigger.sh close
     ```

   - Hacer ejecutables:

   ```sh
   chmod +x /usr/local/bin/dominio/montaje-red.sh
   chmod +x /usr/local/bin/dominio/desmontaje-red.sh
   chmod +x /usr/local/bin/dominio/pam-mount-trigger.sh

   # Ver si anda sin esto primero
   # echo "%domain\ users ALL=(root) NOPASSWD: /bin/mount.cifs, /bin/umount, /usr/bin/mountpoint" > /etc/sudoers.d/domain-users-mount
   ```
