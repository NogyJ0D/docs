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
   IPTABLES="/usr/sbin/iptables"

   firewall_start() {
    # Rechazar paquetes inválidos
    $IPTABLES -A INPUT -m conntrack --ctstate INVALID -J DROP

    # Aceptar todo en loopback
    $IPTABLES -A INPUT -i lo -j ACCEPT
    $IPTABLES -A OUTPUT -o lo -J ACCEPT

    # ----------------------------------------------
    # Aceptar entrada de relacionados y establecidos
    $IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Aceptar entrada ICMP y SSH
    $IPTABLES -A INPUT -p icmp -j ACCEPT
    $IPTABLES -A INPUT -p tcp --dport 22 -j ACCEPT

    # ---------------------------------------------
    # Aceptar salida de relacionados y establecidos
    $IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Aceptar salida HTTP/S
    $IPTABLES -A OUTPUT -p tcp --dport 80 -j ACCEPT
    $IPTABLES -A OUTPUT -p tcp --dport 443 -j ACCEPT

    # Aceptar salida DNS
    $IPTABLES -A OUTPUT -p tcp --dport 53 -j ACCEPT
    $IPTABLES -A OUTPUT -p udp --dport 53 -j ACCEPT

    # Aceptar salida NTP
    $IPTABLES -A OUTPUT -p tcp --dport 123 -j ACCEPT
    $IPTABLES -A OUTPUT -p udp --dport 123 -j ACCEPT

    # Aceptar salida ICMP y SSH
    $IPTABLES -A OUTPUT -p icmp -j ACCEPT
    $IPTABLES -A OUTPUT -p tcp --dport 22 -j ACCEPT

    $IPTABLES -A OUTPUT -p tcp --sport 3000 -j ACCEPT

    # Rechazar todo el resto
    $IPTABLES -P INPUT DROP
    $IPTABLES -P FORWARD DROP
    $IPTABLES -P OUTPUT DROP
   }

   firewall_stop() {
     $IPTABLES -F
     $IPTABLES -X
     $IPTABLES -P INPUT    ACCEPT
     $IPTABLES -P FORWARD  ACCEPT
     $IPTABLES -P OUTPUT   ACCEPT
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
