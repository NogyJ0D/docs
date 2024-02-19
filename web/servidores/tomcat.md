# Tomcat

---

## Contenido

- [Tomcat](#tomcat)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar tomcat en Debian 12](#instalar-tomcat-en-debian-12)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### [Instalar tomcat en Debian 12](https://linux.how2shout.com/install-apache-tomcat-10-on-debian-11-linux/)

1. Instalar java:

    ```sh
    apt install openjdk-17-jdk -y
    ```

2. Descargar tomcat:

   - Buscar útlima versión: <https://tomcat.apache.org/>.

    ```sh
    wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.18/bin/apache-tomcat-10.1.18.tar.gz && \
      mkdir -p /opt/tomcat && \
      tar xzvf apache-tomcat-10*tar.gz -C /opt/tomcat --strip-components=1
    ```

3. Agregar usuario:

    ```sh
    groupadd tomcat
    useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
    chown -R tomcat: /opt/tomcat
    sh -c 'chmod +x /opt/tomcat/bin/*.sh'
    ```

4. Crear servicio:

    ```sh
    update-java-alternatives -l # Ver ruta de java
    nano /etc/systemd/system/tomcat.service
    ```

    ```ini
    [Unit]
    Description=Tomcat webs servlet container
    After=network.target

    [Service]
    Type=forking

    User=tomcat
    Group=tomcat
    RestartSec=10
    Restart=always 
    Environment="JAVA_HOME=/usr/lib/jvm/java-1.17.0-openjdk-amd64"
    Environment="JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom"

    Environment="CATALINA_BASE=/opt/tomcat"
    Environment="CATALINA_HOME=/opt/tomcat"
    Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
    Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

    ExecStart=/opt/tomcat/bin/startup.sh
    ExecStop=/opt/tomcat/bin/shutdown.sh

    [Install]
    WantedBy=multi-user.target
    ```

    ```sh
    systemctl daemon-reload
    systemctl enable --now tomcat
    ```

5. Agregar roles:

    ```sh
    nano /opt/tomcat/conf/tomcat-users.xml
    ```

    ```xml
    <!-- Agregar antes de </tomcat-users> -->
    <role rolename="admin"/>
    <role rolename="admin-gui"/>
    <role rolename="manager"/>
    <role rolename="manager-gui"/>

    <user username="h2s" password="pwd" roles="admin,admin-gui,manager,manager-gui"/>
    ```
---

## Extras
