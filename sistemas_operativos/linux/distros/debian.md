# Debian

## Unir Debian 12 a Active Directory

1. Instalar paquetes:

   ```sh
   apt install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin oddjob oddjob-mkhomedir packagekit krb5-user libpam-mount cifs-utils vim
   ```

2. Modificar **_/etc/hosts_**:

   ```sh
   127.0.0.1 localhost
   127.0.0.1 hostname.dom.local hostname
   x.x.x.x sa.dom.local sa
   ```

3. Modificar **_/etc/krb5.conf_**:

   ```sh
   [libdefaults]
   default_realm = DOM.LOCAL
           kdc_timesync = 1
           ccache_type = 4
           forwardable = true
           proxiable = true
           rdns = false
           fcc-mit-ticketflags = true
   udp_preference_limit = 0

   [realms]
           DOM.LOCAL = {
                   kdc = sa
                   admin_server = sa
           }

   [domain_realm]
           .dom.local = DOM.LOCAL
           dom.local = DOM.LOCAL
   ```

4. Unirse al dominio:

   ```sh
   realm discover dom.local
   kinit administrator
   realm join -v -U administrator dom.local
   realm permit --all

   id usuario@dom.local
   ```

5. Configurar dominio:

   ```sh
   pam-auth-update --enable mkhomedir
   editor /etc/pam.d/common-session # Modificar pam_mkhomedir.so skel=/etc/skel umask=077
   editor /etc/pam.d/common-password # Modificar password requisite pam_pwquality.so retry=3 dictcheck=0

   chmod 600 /etc/sssd/sssd.conf
   chown root:root /etc/sssd/sssd.conf
   ```

   - Modificar en **_/etc/sssd/sssd.conf_**:

     ```sh
     [sssd]
     domains = dom.local
     config_file_version = 2
     services = nss, pam

     [domain/dom.local]
     default_shell = /bin/bash
     krb5_store_password_if_offline = False
     cache_credentials = True
     krb5_realm = DOM.LOCAL
     realmd_tags = manages-system joined-with-adcli
     id_provider = ad
     fallback_homedir = /home/%u
     ad_domain = dom.local
     use_fully_qualified_names = False
     ldap_id_mapping = True
     access_provider = ad
     ad_gpo_access_control = permissive
     dyndns_update = False
     ad_enable_gc = False
     ```

   - Agregar en **_/etc/security/pam_mount.conf.xml_**:

     ```xml
     <volume
         fstype="cifs"
         server="sa"
         options="nosuid,nodev"
         user="usuario"
         path="nombre"
         mountpoint="/mnt/carpeta"
     />
     ```

   ```sh
   editor /etc/samba/smb.conf # Modificar WORKGROUP = DOM

   systemctl restart sssd
   sssctl domain-status dom.local
   ```

6. Instalar y configurar lightdm

   ```sh
   apt install -y lightdm lightdm-gtk-greeter
   systemctl enable lightdm
   systemctl disable [manager]
   editor /etc/lightdm/lightdm.conf
   ```

   ```conf
   [Seat:*]
   greeter-hide-users=true
   greeter-allow-guest=false
   greeter-show-manual-login=true
   ```

7. Reiniciar y loguearse.

## Obtener versión de controladora RAID Intel Mega con MegaRaid CLI

> Ejemplo: Intel RAID Controller RS3WC080

1. Agregar repositorio a **_/etc/apt/sources.list_**:

   ```sh
   deb http://hwraid.le-vert.net/debian version-de-debian main
   ```

2. Ejecutar:

   ```sh
   wget -O - https://hwraid.le-vert.net/debian/hwraid.le-vert.net.gpg.key | apt-key add -
   apt update
   apt-get install megacli
   megacli -AdpAllInfo -aAll | grep -i "fw"
   ```
