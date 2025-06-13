# IPTables

- [IPTables](#iptables)
  - [Documentación](#documentación)
    - [Reglas](#reglas)
      - [Filtrado](#filtrado)
      - [NAT](#nat)
      - [MANGLE](#mangle)
  - [Comandos](#comandos)
  - [Extras](#extras)
    - [IPTables como servicio](#iptables-como-servicio)

---

## Documentación

### Reglas

#### Filtrado

- Para filtrar paquetes locales:
  - INPUT
  - OUTPUT
- Para filtrar paquetes a otras máquinas:
  - FORWARD

#### NAT

Para hacer redirecciones de puertos o cambios en las IPs de origen y destino.

- PREROUTING
- POSTROUTING

#### MANGLE

Modifica los paquetes.

---

## Comandos

---

## Extras

### IPTables como servicio

1. Crear el archivo **_/sbin/iptables-firewall.sh_**
2. Agregar contenido básico:

   ```sh
   #!/bin/bash

   PATH="/sbin:/usr/sbin:/bin:/usr/bin"
   IPT="/usr/sbin/iptables"
    
   firewall_start() {
     $IPT -P INPUT DROP -m comment --comment "Rechazar entradas"
     $IPT -P FORWARD DROP -m comment --comment "Rechazar redirecciones"
     $IPT -P OUTPUT ACCEPT -m comment --comment "Aceptar todo saliente"
    
     $IPT -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Aceptar relacionados"
    
     $IPT -A INPUT -m conntrack --ctstate INVALID -j DROP -m comment --comment "Rechazar inválidos entrantes"
    
     $IPT -A INPUT -i lo -j ACCEPT -m comment --comment "Aceptar loopback in"
     $IPT -A OUTPUT -o lo -j ACCEPT -m comment --comment "Aceptar loopback out"
    
     # --------------------------------------------------
    
     $IPT -A INPUT -p icmp -j ACCEPT -m comment --comment "Aceptar ICMP (ping)"
     $IPT -A INPUT -p tcp --dport 22 -j ACCEPT -m comment --comment "Aceptar ssh"
    
     $IPT -A INPUT -p tcp --dport 80 -j ACCEPT -m comment --comment "Aceptar web 80"
     $IPT -A INPUT -p tcp --dport 443 -j ACCEPT -m comment --comment "Aceptar web 443"
    
   }

   firewall_stop() {
     # Limpiar INPUT OUTPUT y FORWARD para no borrar entradas de Docker o fail2ban
     $IPT -F INPUT
     $IPT -F OUTPUT
     $IPT -F FORWARD
    
     $IPT -X INPUT
     $IPT -X OUTPUT
     $IPT -X FORWARD
    
     $IPT -P INPUT ACCEPT
     $IPT -P FORWARD ACCEPT
     $IPT -P OUTPUT ACCEPT
   }
    
   case "$1" in
     start|restart)
       echo "Iniciando Firewall"
       firewall_stop
       firewall_start
       ;;
     stop)
       echo "Deteniendo Firewall"
       firewall_stop
       ;;
   esac
   ```

3. Ejecutar:

   ```sh
   chown root:root /sbin/iptables-firewall.sh
   chmod 750 /sbin/iptables-firewall.sh
   ```

4. Crear servicio **_/etc/systemd/system/iptables-firewall.sh_**:

   ```sh
   [Unit]
   Description=IPTABLES Firewall
   After=network.target

   [Service]
   Type=oneshot
   ExecStart=/sbin/iptables-firewall.sh start
   RemainAfterExit=true
   ExecStop=/sbin/iptables-firewall.sh stop
   StandardOutput=journal

   [Install]
   WantedBy=multi-user.target
   ```

5. Levantar:

   ```sh
   systemctl daemon-reload
   systemctl enable iptables-firewall
   systemctl start iptables-firewall
   ```
