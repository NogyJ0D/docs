# Oviyam

## Contenido

- [Oviyam](#oviyam)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar Oviyam 2.8.2 en Alpine Linux](#instalar-oviyam-282-en-alpine-linux)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### Instalar Oviyam 2.8.2 en Alpine Linux

1. Instalar requisitos:

    ```sh
    apk add wget openjdk8
    ```

2. Descargar Oviyam 2.8.2:

    ```sh
    wget --no-check-certificate https://sourceforge.net/projects/dcm4che/files/Oviyam/2.8.2/Oviyam-2.8.2-bin.zip/download -O oviyam.zip && unzip oviyam.zip
    ```

3. Descargar Tomcat 8:

    ```sh
    wget wget https://dlcdn.apache.org/tomcat/tomcat-8/v8.5.98/bin/apache-tomcat-8.5.98.tar.gz && tar -xvzf apache-tomcat-8.5.98.tar.gz

    mv apache-tomcat-8.5.98 /usr/local/tomcat
    ```

4. Instalar Oviyam:

    ```sh
    rm -R /usr/local/tomcat/ROOT
    cp Oviyam-2.8.2-bin/Oviyam-2.8.2-bin/oviyam2.war /usr/local/tomcat/webapps/ROOT.war
    cp Oviyam-2.8.2-bin/tomcat/*.jar /usr/local/tomcat/lib
    ```

5. Crear usuarios:

    ```sh
    nano /usr/local/tomcat/conf/tomcat-users.xml
    ```

    ```xml
    <?xml version='1.0' encoding='utf-8'?>

    <tomcat-users>
    <role rolename="tomcat"/>
    <role rolename="admin"/>
    <role rolename="manager-gui"/>
    <user username="tomcat" password="cattom" roles="manager-gui, manager-script, manager-status, manager-jmx"/>
    <user username="admin" password="adm1n" roles="admin"/>
    </tomcat-users>
    ```

6. Crear servicio:

    ```sh
    nano /etc/init.d/tomcat
    ```

    ```sh
    #!/sbin/openrc-run

    JAVA_HOME=/usr/lib/jvm/java-8-openjdk
    CATALINA_HOME=/usr/local/tomcat

    name="Tomcat"
    description="Apache Tomcat Server"

    start() {
      ebegin "Starting Tomcat"
      start-stop-daemon --start --exec $CATALINA_HOME/bin/startup.sh
      eend $?
    }

    stop() {
      ebegin "Stopping Tomcat"
      start-stop-daemon --start --exec $CATALINA_HOME/bin/shutdown.sh
      eend $?
    }
    ```

    ```sh
    chmod +x /etc/init.d/tomcat
    rc-update add tomcat default
    rc-service tomcat start
    ```

7. Entrar a la página: <http://ip:8080>.

---

## Extras
