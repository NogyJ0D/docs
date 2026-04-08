# OpenVPN

## Instalar OpenVPN en Debian 13

1. Instalar paquetes:

   ```sh
   apt install openvpn easy-rsa iptables
   ```

2. Crear carpeta de certificados:

   ```sh
   make-cadir /etc/openvpn/easy-rsa
   cd /etc/openvpn/easy-rsa
   ```

3. Editar el archivo `/etc/openvpn/easy-rsa/vars` y agregar al final:

   ```conf
   set_var EASYRSA_REQ_COUNTRY    "AR" # País
   set_var EASYRSA_REQ_PROVINCE   "Provincia" # Poner provincia
   set_var EASYRSA_REQ_CITY       "Ciudad" # Poner ciudad
   set_var EASYRSA_REQ_ORG        "MiOrganizacion" # Cambiar
   set_var EASYRSA_REQ_EMAIL      "admin@ejemplo.com" # Cambiar
   set_var EASYRSA_REQ_OU         "IT"
   set_var EASYRSA_KEY_SIZE       2048
   set_var EASYRSA_ALGO           rsa
   set_var EASYRSA_CA_EXPIRE      # 3650 para 10 años o 36500 para 100 años
   set_var EASYRSA_CERT_EXPIRE    # 3650 para 10 años o 36500 para 100 años
   set_var EASYRSA_CRL_DAYS       # 180 por defecto, 3650 para 10 años o 36500 para 100 años
   ```

4. Crear CA y certificado del servidor:

   ```sh
   ./easyrsa init-pki
   ./easyrsa build-ca nopass # Poner un nombre como "MiCA" cuando pida

   ./easyrsa gen-req servidor nopass
   ./easyrsa sign-req server servidor

   ./easyrsa gen-crl
   cp pki/crl.pem /etc/openvpn/server/
   ```

5. Crear Diffie-Hellman y clave TLS:

   ```sh
   ./easyrsa gen-dh
   openvpn --genkey secret /etc/openvpn/easy-rsa/pki/ta.key
   ```

6. Copiar archivos:

   ```sh
   cd pki
   cp ca.crt issued/servidor.crt private/servidor.key dh.pem ta.key /etc/openvpn/server
   ```

7. Crear el archivo de configuración del servidor `/etc/openvpn/server/server.conf` y agregar:

   ```conf
   port 1194
   proto udp
   dev tun

   ca   /etc/openvpn/server/ca.crt
   cert /etc/openvpn/server/servidor.crt
   key  /etc/openvpn/server/servidor.key
   dh   /etc/openvpn/server/dh.pem

   tls-auth /etc/openvpn/server/ta.key 0
   tls-version-min 1.2
   cipher AES-256-GCM
   auth SHA256

   server 10.8.0.0 255.255.255.0
   ifconfig-pool-persist /var/log/openvpn/ipp.txt

   push "route 192.168.1.0 255.255.255.0" # Subred de la oficina
   route 10.8.0.0 255.255.255.0

   keepalive 10 120
   persist-key
   persist-tun
   topology subnet

   status /var/log/openvpn/openvpn-status.log
   log-append /var/log/openvpn/openvpn.log
   verb 3

   user nobody
   group nogroup
   ```

8. Crear directorio `/var/log/openvpn` para logs.
9. Habilitar IP Forwarding:

   ```sh
   echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
   sysctl -p
   ```

10. Crear reglas de iptables:

    ```sh
    # Ver interfaz con "ip l"
    iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
    iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
    iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT

    apt install -y iptables-persistent # No guardar reglas
    netfilter-persistent save
    ```

11. Iniciar servicio:

    ```sh
    systemctl enable --now openvpn-server@server
    systemctl status openvpn-server@server
    ```

12. [Agregar script para clientes](#script-para-agregar-clientes).
    - Crear cliente con `/etc/openvpn/easy-rsa/gen-cliente.sh usuario correo_del_usuario`

13. Configurar el router (mikrotik en este caso):
    1. Obtener la ip del openvpn (y asegurarse de fijarla): `ip a`.
    2. Crear forwarding:
       - IP > Firewall > NAT > [+]
       - Chain: dstnat
       - Protocol: udp
       - Dst. Port: 1194
       - In. Interface: ether1 (o bridge, la WAN)
       - Action tab:
         - Action: dst-nat
         - To Address: 192.168.1.50 (IP de la VM)
         - To Ports: 1194
    3. Crear ruta estática:
       - IP > Routes > [+]
       - Dst. Address: 10.8.0.0/24
       - Gateway: 192.168.1.50

## Comandos

### Ver Expiraciones

```sh
echo "=== CA ===" && \
openssl x509 -in /etc/openvpn/server/ca.crt -noout -enddate

echo "=== Servidor ===" && \
openssl x509 -in /etc/openvpn/server/servidor.crt -noout -enddate

echo "=== CRL ===" && \
openssl crl -in /etc/openvpn/server/crl.pem -noout -nextupdate

echo "=== Clientes ===" && \
for crt in /etc/openvpn/easy-rsa/pki/issued/*.crt; do
    echo "  $(basename $crt .crt): $(openssl x509 -in $crt -noout -enddate | cut -d= -f2)"
done
```

## Extras

### Script para agregar clientes

- Envía el certificado por correo. Si no se quiere esto, no hacer esos pasos.

1. Instalar msmtp para el correo:

   ```sh
   apt install -y msmtp msmtp-mta mailutils zip
   ```

2. Crear archivo `/etc/msmtprc` y agregar:

   ```conf
   defaults
   auth            on
   tls             on
   #tls_starttls    off # Agregar si se usa el puerto 465 sin STARTTLS
   tls_trust_file  /etc/ssl/certs/ca-certificates.crt
   logfile         /var/log/msmtp.log

   account         default
   host            smtp.gmail.com # o smtp.office365.com, o el tuyo
   port            587 # o 465
   from            tu@gmail.com
   user            tu@gmail.com
   password        tu_app_password_aqui
   ```

   ```sh
   chmod 600 /etc/msmtprc
   ```

3. Crear script en `/etc/openvpn/easy-rsa/gen-cliente.sh`:

   ```bash
   #!/bin/bash
   # =============================================================
   #  gen-cliente.sh — Genera certificado + .ovpn y lo envía por mail
   #  Uso: ./gen-cliente.sh <nombre_cliente> <email1> [email2] [email3] ...
   # =============================================================

   set -e

   # ── Configuración ─────────────────────────────────────────────
   EASYRSA_DIR="/etc/openvpn/easy-rsa"
   OUTPUT_DIR="/etc/openvpn/clientes"
   SERVER_IP="HOST"
   SERVER_PORT="1194"
   PROTO="udp"
   MAIL_FROM="MAIL"
   MAIL_SUBJECT="Tu certificado VPN"
   ZIP_PASSWORD="CLAVE ZIP"
   # ──────────────────────────────────────────────────────────────

   RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
   info()  { echo -e "${GREEN}[+]${NC} $1"; }
   warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
   error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

   # ── Validaciones ──────────────────────────────────────────────
   [[ $EUID -ne 0 ]] && error "Ejecutá el script como root."
   [[ -z "$1" ]]     && error "Uso: $0 <nombre_cliente> <email1> [email2] ..."
   [[ -z "$2" ]]     && error "Uso: $0 <nombre_cliente> <email1> [email2] ..."

   CLIENT="$1"
   shift   # descarta $1, ahora $@ contiene solo los emails

   [[ ! "$CLIENT" =~ ^[a-zA-Z0-9_-]+$ ]] && \
       error "Nombre inválido. Usá solo letras, números, _ o -"

   # Validar y acumular emails
   MAIL_LIST=()
   for ADDR in "$@"; do
       [[ ! "$ADDR" =~ ^[^@]+@[^@]+\.[^@]+$ ]] && error "Email inválido: $ADDR"
       MAIL_LIST+=("$ADDR")
   done

   command -v zip >/dev/null 2>&1 || error "zip no está instalado. Ejecutá: apt install -y zip"

   cd "$EASYRSA_DIR"

   [[ -f "pki/issued/${CLIENT}.crt" ]] && \
       error "Ya existe un certificado para '${CLIENT}'."

   mkdir -p "$OUTPUT_DIR"

   # ── Generar y firmar ───────────────────────────────────────────
   info "Generando clave y request para '${CLIENT}'..."
   warn "Se te pedirá la passphrase para la clave del cliente."
   echo ""
   ./easyrsa gen-req "$CLIENT"

   echo ""
   info "Firmando certificado con el CA..."
   ./easyrsa sign-req client "$CLIENT"

   # ── Armar el .ovpn ────────────────────────────────────────────
   OVPN_FILE="${OUTPUT_DIR}/${CLIENT}.ovpn"
   info "Generando ${CLIENT}.ovpn ..."

   cat > "$OVPN_FILE" <<EOF
   client
   dev tun
   proto ${PROTO}
   remote ${SERVER_IP} ${SERVER_PORT}
   nobind

   cipher AES-256-GCM
   auth SHA256
   tls-version-min 1.2
   key-direction 1
   verb 3

   <ca>
   $(cat pki/ca.crt)
   </ca>
   <cert>
   $(openssl x509 -in "pki/issued/${CLIENT}.crt")
   </cert>
   <key>
   $(cat "pki/private/${CLIENT}.key")
   </key>
   <tls-auth>
   $(cat pki/ta.key)
   </tls-auth>
   EOF

   chmod 600 "$OVPN_FILE"

   # ── Empaquetar en .zip con contraseña ─────────────────────────
   ZIP_FILE="${OUTPUT_DIR}/${CLIENT}.zip"
   info "Empaquetando en ZIP con contraseña..."

   zip -j -P "$ZIP_PASSWORD" "$ZIP_FILE" "$OVPN_FILE"
   chmod 600 "$ZIP_FILE"

   info "ZIP generado: ${ZIP_FILE}"

   # ── Enviar por correo ─────────────────────────────────────────
   EXPIRY=$(openssl x509 -in "pki/issued/${CLIENT}.crt" -noout -enddate | cut -d= -f2)

   MAIL_BODY="Hola ${CLIENT},

   Adjunto encontrás tu certificado VPN empaquetado en un archivo .zip.

   Instrucciones:
     1. Descomprimí el .zip con la contraseña que te fue comunicada
     2. Importá el archivo .ovpn en tu cliente OpenVPN
     3. Al conectarte se te pedirá la passphrase que definiste durante la generación
     4. El certificado expira el: ${EXPIRY}

   Por seguridad, eliminá este correo una vez que hayas importado el archivo.

   -- Soporte IT"

   BOUNDARY="boundary_$(date +%s)"
   ENCODED=$(base64 "$ZIP_FILE")

   # Header To: con todos los destinatarios
   TO_HEADER=$(IFS=", "; echo "${MAIL_LIST[*]}")

   MAIL_OK=()
   MAIL_FAIL=()

   for ADDR in "${MAIL_LIST[@]}"; do
       info "Enviando a ${ADDR}..."
       {
         echo "From: ${MAIL_FROM}"
         echo "To: ${TO_HEADER}"
         echo "Subject: ${MAIL_SUBJECT} - ${CLIENT}"
         echo "MIME-Version: 1.0"
         echo "Content-Type: multipart/mixed; boundary=\"${BOUNDARY}\""
         echo ""
         echo "--${BOUNDARY}"
         echo "Content-Type: text/plain; charset=UTF-8"
         echo ""
         echo "$MAIL_BODY"
         echo ""
         echo "--${BOUNDARY}"
         echo "Content-Type: application/zip"
         echo "Content-Transfer-Encoding: base64"
         echo "Content-Disposition: attachment; filename=\"${CLIENT}.zip\""
         echo ""
         echo "$ENCODED"
         echo "--${BOUNDARY}--"
       } | msmtp "$ADDR" && MAIL_OK+=("$ADDR") || MAIL_FAIL+=("$ADDR")
   done

   # ── Resumen ───────────────────────────────────────────────────
   echo ""
   echo -e "${GREEN}══════════════════════════════════════════${NC}"
   info "Listo."
   echo -e "  Cliente  : ${YELLOW}${CLIENT}${NC}"
   echo -e "  ZIP      : ${YELLOW}${ZIP_FILE}${NC}"
   echo -e "  Expira   : ${EXPIRY}"

   if [[ ${#MAIL_OK[@]} -gt 0 ]]; then
       echo -e "  Enviado a:"
       for ADDR in "${MAIL_OK[@]}"; do
           echo -e "    ${GREEN}✓${NC} ${ADDR}"
       done
   fi

   if [[ ${#MAIL_FAIL[@]} -gt 0 ]]; then
       echo -e "  Falló:"
       for ADDR in "${MAIL_FAIL[@]}"; do
           echo -e "    ${RED}✗${NC} ${ADDR}"
       done
       warn "Los envíos fallidos pueden reenviarse con el ZIP en: ${ZIP_FILE}"
   fi

   echo -e "${GREEN}══════════════════════════════════════════${NC}"
   echo ""
   warn "Recordá comunicar la contraseña del ZIP por un canal separado (no por mail)."
   ```

   ```sh
   chmod +x /etc/openvpn/easy-rsa/gen-cliente.sh
   ```

4. Agregar script para revocar en `/etc/openvpn/easy-rsa/revocar-cliente.sh`:

   ```sh
   #!/bin/bash
   # =============================================================
   #  revocar-cliente.sh — Revoca el certificado de un cliente
   #  Uso: ./revocar-cliente.sh <nombre_cliente>
   # =============================================================

   # ── Configuración ─────────────────────────────────────────────
   EASYRSA_DIR="/etc/openvpn/easy-rsa"
   SERVER_CONF_DIR="/etc/openvpn/server"
   OUTPUT_DIR="/etc/openvpn/clientes"
   # ──────────────────────────────────────────────────────────────

   RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
   info()  { echo -e "${GREEN}[+]${NC} $1"; }
   warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
   error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

   # ── Validaciones ──────────────────────────────────────────────
   [[ $EUID -ne 0 ]] && error "Ejecutá el script como root."
   [[ -z "$1" ]]     && error "Uso: $0 <nombre_cliente>"

   CLIENT="$1"
   cd "$EASYRSA_DIR"

   # Verificar que el certificado existe
   [[ ! -f "pki/issued/${CLIENT}.crt" ]] && \
       error "No existe certificado para '${CLIENT}'."

   # Verificar que no esté ya revocado
   if grep -q "^R" pki/index.txt 2>/dev/null; then
       if openssl crl -in pki/crl.pem -noout -text 2>/dev/null | grep -q "CN=${CLIENT}"; then
           error "El cliente '${CLIENT}' ya fue revocado."
       fi
   fi

   # ── Confirmación ──────────────────────────────────────────────
   echo ""
   warn "Estás por revocar el certificado de: ${YELLOW}${CLIENT}${NC}"
   warn "Esta acción no se puede deshacer. El cliente perderá acceso inmediatamente."
   echo ""
   read -r -p "¿Confirmar revocación? [s/N]: " CONFIRM

   [[ ! "$CONFIRM" =~ ^[sS]$ ]] && { echo "Cancelado."; exit 0; }

   # ── Revocar ───────────────────────────────────────────────────
   echo ""
   info "Revocando certificado de '${CLIENT}'..."
   ./easyrsa revoke "$CLIENT"

   # ── Regenerar CRL ─────────────────────────────────────────────
   info "Regenerando CRL..."
   ./easyrsa gen-crl

   cp pki/crl.pem "${SERVER_CONF_DIR}/crl.pem"
   chmod 644 "${SERVER_CONF_DIR}/crl.pem"

   # Agregar crl-verify al server.conf si no está
   for CONF in "${SERVER_CONF_DIR}"/server*.conf; do
       if ! grep -q "crl-verify" "$CONF"; then
           echo "crl-verify ${SERVER_CONF_DIR}/crl.pem" >> "$CONF"
           warn "Se agregó crl-verify a $(basename $CONF)"
       fi
   done

   # ── Eliminar .ovpn ────────────────────────────────────────────
   OVPN_FILE="${OUTPUT_DIR}/${CLIENT}.ovpn"
   if [[ -f "$OVPN_FILE" ]]; then
       rm -f "$OVPN_FILE"
       info "Archivo .ovpn eliminado."
   fi

   # ── Reiniciar instancias OpenVPN ──────────────────────────────
   info "Reiniciando OpenVPN..."
   systemctl restart openvpn-server@server 2>/dev/null || \
   warn "No se pudo reiniciar automáticamente. Hacelo manualmente."

   systemctl restart openvpn-server@server-tcp 2>/dev/null || true

   # ── Resumen ───────────────────────────────────────────────────
   echo ""
   echo -e "${RED}══════════════════════════════════════════${NC}"
   info "Cliente revocado exitosamente."
   echo -e "  Cliente   : ${YELLOW}${CLIENT}${NC}"
   echo -e "  CRL activo: ${YELLOW}${SERVER_CONF_DIR}/crl.pem${NC}"
   echo -e "  .ovpn     : ${YELLOW}eliminado${NC}"
   echo -e "${RED}══════════════════════════════════════════${NC}"
   echo ""

   # ── Listar todos los revocados ────────────────────────────────
   info "Clientes revocados hasta ahora:"
   grep "^R" pki/index.txt | awk -F'/' '{print "  - " $NF}' | sed 's/CN=//'
   ```

   ```sh
   chmod +x /etc/openvpn/easy-rsa/revocar-cliente.sh
   ```

### Renovar Certificados

#### Certificado del Servidor

- Si vence, nadie puede conectarse

```sh
cd /etc/openvpn/easy-rsa
./easyrsa renew servidor nopass
cp pki/issued/servidor.crt /etc/openvpn/server/
cp pki/issued/servidor.key /etc/openvpn/server/
systemctl restart openvpn-server@server
```

#### Certificados de Clientes

- Se revoca y se vuelve a generar

```sh
cd /etc/openvpn/easy-rsa
./revocar-cliente.sh cliente
./gen-cliente.sh cliente email
systemctl restart openvpn-server@server
```
