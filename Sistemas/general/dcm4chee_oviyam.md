# DCM4CHEE + Oviyam

> Nota: Oviyam es solo un visor dicom que toma las imagenes de un servidor dcm4chee.

## Contenido

- [DCM4CHEE + Oviyam](#dcm4chee--oviyam)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar D+O 2.8 en Alpine Linux usando docker](#instalar-do-28-en-alpine-linux-usando-docker)
    - [Instalar Oviyam 2.8.2 en Alpine Linux manualmente](#instalar-oviyam-282-en-alpine-linux-manualmente)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### Instalar D+O 2.8 en Alpine Linux usando docker

1. Instalar docker

    ```sh
    apk add docker docker-cli-compose
    ```

2. Crear requerimientos:

    ```sh
    addgroup -g 1021 slapd-dcm4chee && adduser -D -H -G slapd-dcm4chee -u 1021 slapd-dcm4chee
    addgroup -g 999 postgres-dcm4chee && adduser -D -H -G postgres-dcm4chee -u 999 postgres-dcm4chee
    addgroup -g 1023 dcm4chee-arc && adduser -D -H -G dcm4chee-arc -u 1023 dcm4chee-arc
    # docker network create dcm4chee_default
    ```

3. Crear compose:

    ```yml
    version: '3.7'
    services:
      ldap:
        image: dcm4che/slapd-dcm4chee:2.4.44-12.0
        networks:
          - dcm4chee_default
        ports:
          - "389:389"
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /var/local/dcm4chee-arc/ldap:/var/lib/ldap
          - /var/local/dcm4chee-arc/slapd.d:/etc/ldap/slapd.d
        restart: always

      db:
        image: dcm4che/postgres-dcm4chee:10.0-12
        networks:
          - dcm4chee_default
        ports:
          - "5432:5432"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: pacs
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /var/local/dcm4chee-arc/db:/var/lib/postgresql/data
        restart: always
        
      arc:
        image: dcm4che/dcm4chee-arc-psql:5.12.0
        networks:
          - dcm4chee_default
        ports:
          - "8080:8080"
          - "8443:8443"
          - "9990:9990"
          - "11112:11112"
          - "2575:2575"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: pacs
          WILDFLY_WAIT_FOR: "ldap:389 db:5432"
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /var/local/dcm4chee-arc/wildfly:/opt/wildfly/standalone
        restart: always
        depends_on:
          - ldap
          - db

      oviyam:
        image: informaticamedica/oviyam:2.8
        networks:
          - dcm4chee_default
        ports:
          - "80:8080"
          - "1025:1025"
        volumes:
          - /oviyam:/usr/local/tomcat/work
        restart: always

    networks:
      dcm4chee_default:
    ```

4. Entrar a "<http://ip:8080/dcm4chee-arc/ui2>" para arc.

5. Entrar a "<http://ip:80>" para oviyam:

   1. Loguearse como "admin" "adm1n".

      > Para modificar los usuarios locales de tomcat ejecutar:
      >
      > docker exec -it root-oviyam-1 /bin/bash
      >
      > Modificar /usr/local/tomcat/conf/tomcat-users.xml

   2. Agregar un servidor dicom: "DCM4CHEE", "DCM3CHEE", "arc", "11112", "WADO, "dcm4chee-arc/aets/DCM4CHEE/wado", "8080", "JPEG".

### Instalar Oviyam 2.8.2 en Alpine Linux manualmente

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
