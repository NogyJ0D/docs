# OpenVPN

## Instalar OpenVPN en Debian 13

- Caso:
  - Mikrotik con DDNS
  - Script [openvpn-install](https://github.com/angristan/openvpn-install)

1. Descargar el script de instalación:

   ```sh
   curl -O https://raw.githubusercontent.com/angristan/openvpn-install/master/openvpn-install.sh
   chmod +x openvpn-install.sh
   ```

2. Ejecutar el script con `./openvpn-install.sh interactive`

3. Va a hacer preguntas:
   - IPv4 o IPv6: IPv4
   - IPv4 address: la ip de la vm
   - Public IPv4 address or hostname: el DDNS del router Mikrotik
   - IPv4 only, IPv6 only o ambos: IPv4 only
   - IPv4 VPN subnet: la que da por defecto o cambiarla
   - Puerto: 1194
   - UDP o TCP: UDP
   - DNS: google, cloudflare o cualquiera
   - Permitir múltiples conexiones por cliente: no
   - MTU: default (1500)
   - Authentication mode: PKI
   - Customize encryption settings: no

4. Por último va a pedir crear un cliente. Va a dejar el archivo `.ovpn`, pasarselo al usuario.

5. Agregar al archivo `/etc/openvpn/server/server.conf`:

   ```conf
   # Comentar los push de dns e ipv6
   #push "dhcp-option DNS 8.8.8.8"
   #push "dhcp-option DNS 8.8.4.4"
   #push "redirect-gateway def1 bypass-dhcp" # Esto hace que el cliente salga a internet con su ip pública, no por la oficina
   #push "block-ipv6"
   push "route 192.168.1.0 255.255.255.0" # Subred de la oficina, dónde esten los archivos compartidos
   client-to-client
   ```

6. Habilitar el forwarding:

   ```sh
   systemctl restart openvpn-server@server # Aplicar configuración

   sysctl net.ipv4.ip_forward # Si da 1, está activado

   echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf # Si el anterior dio 0
   sysctl -p
   ```

7. Crear la ruta en el router:
   - IP > Routes > +
   - Dst: 10.8.0.0/24
   - Gateway: IP de la vm
   - **Recordar asignar IP fija a la vm también en el mikrotik**

8. Hacer el Port Forwarding en el router **(por cada interfaz de proveedor)**:
   - IP > Firewall > NAT > +
   - chain: dsnat
   - protocol: udp
   - ds-port: 1194
   - in-interface: wan1
   - action: dst-nat
   - to-address: 192.168.1.x (IP de la vm)
   - to-ports: 1194

9. Masquerade en el router:
   - IP > Firewall > NAT > +
   - chain: srcnat
   - src-address: 10.8.0.0/24
   - dst-address: 192.168.1.0/24 (subred de la oficina)
   - action: masquerade

## Comandos

### Agregar Cliente

- Con **openvpn-install.sh**:

  ```sh
  ./openvpn-install.sh client add [nombre]
  ```
