# Mikrotik

## Extras

### Exponer proxy reverso a internet

- Mikrotik con wan en el ether 1
- Nginx como vm en la 192.168.0.15

```routeros
# DST-NAT (port forwarding solo desde WAN)
/ip firewall nat add chain=dstnat in-interface=ether1 dst-port=80 protocol=tcp action=dst-nat to-addresses=192.168.0.15 to-ports=80
/ip firewall nat add chain=dstnat in-interface=ether1 dst-port=443 protocol=tcp action=dst-nat to-addresses=192.168.0.15 to-ports=443

# Firewall forward
/ip firewall filter add chain=forward dst-address=192.168.0.15 dst-port=80,443 protocol=tcp action=accept place-before=0

# DNS: habilitar resolución local y upstream
/ip dns set servers=8.8.8.8,8.8.4.4 allow-remote-requests=yes

# DNS estático wildcard para subdominios internos o cada subdominio fijo
/ip dns static add name="*.dominio.com" address=192.168.0.15
/ip dns static add name="subdominio.dominio.com" address=192.168.0.15

# DHCP: forzar el router como DNS en los clientes
/ip dhcp-server network set [find] dns-server=192.168.0.1
```
