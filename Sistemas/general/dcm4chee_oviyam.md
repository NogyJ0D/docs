# DCM4CHEE + Oviyam

> Nota: Oviyam es solo un visor dicom que toma las imagenes de un servidor dcm4chee.

## Contenido

- [DCM4CHEE + Oviyam](#dcm4chee--oviyam)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar D+O en Alpine Linux usando Docker - Sin seguridad](#instalar-do-en-alpine-linux-usando-docker---sin-seguridad)
    - [Instalar D+O en Alpine Linux usando docker - Método 2](#instalar-do-en-alpine-linux-usando-docker---método-2)
    - [Instalar Oviyam 2.8.2 en Alpine Linux manualmente](#instalar-oviyam-282-en-alpine-linux-manualmente)
  - [Extras](#extras)

---

## Documentación

---

## Instalación

### Instalar D+O en Alpine Linux usando Docker - [Sin seguridad](https://github.com/dcm4che/dcm4chee-arc-light/wiki/Run-secured-archive-services-on-a-single-host)

- [Instalar docker](../../herramientas/docker.md#instalar-docker-en-alpine).

1. Agregar zona horaria:

    ```sh
    echo "America/Argentina/Buenos_Aires" >> /etc/timezone
    ```

2. Crear usuarios:

    ```sh
    addgroup -g 1021 slapd-dcm4chee && adduser -D -H -G slapd-dcm4chee -u 1021 slapd-dcm4chee
    addgroup -g 999 postgres-dcm4chee && adduser -D -H -G postgres-dcm4chee -u 999 postgres-dcm4chee
    addgroup -g 1023 dcm4chee-arc && adduser -D -H -G dcm4chee-arc -u 1023 dcm4chee-arc
    ```

3. Crear y arrancar el stack reemplazando las contraseñas:

    ```yml
    version: "3"
    services:
      ldap:
        image: dcm4che/slapd-dcm4chee:2.6.6-32.0
        networks:
          - dcm4chee_default
        logging:
          driver: json-file
          options:
            max-size: "10m"
        ports:
          - "389:389"
        environment:
          STORAGE_DIR: /storage/fs1
        volumes:
          - storage:/var/lib/openldap/openldap-data
          - storage:/etc/openldap/slapd.d
        restart: always

      db:
        image: dcm4che/postgres-dcm4chee:16.1-32
        networks:
          - dcm4chee_default
        logging:
          driver: json-file
          options:
            max-size: "10m"
        ports:
        - "5432:5432"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: pacs
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - db_data:/var/lib/postgresql/data
        restart: always

      dcm4chee:
        image: dcm4che/dcm4chee-arc-psql:5.32.0
        networks:
          - dcm4chee_default
        logging:
          driver: json-file
          options:
            max-size: "10m"
        ports:
          - "8080:8080"
          - "8443:8443"
          - "9990:9990"
          - "9993:9993"
          - "11112:11112"
          - "2762:2762"
          - "2575:2575"
          - "12575:12575"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: pacs
          WILDFLY_CHOWN: /storage
          WILDFLY_WAIT_FOR: ldap:389 db:5432
        depends_on:
          - ldap
          - db
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - storage:/opt/wildfly/standalone
          - storage:/storage
        restart: always

      oviyam:
        image: informaticamedica/oviyam:2.8
        networks:
          - dcm4chee_default
        ports:
          - "80:8080"
          - "1025:1025"
        volumes:
          - oviyam:/usr/local/tomcat/work
        restart: always

    volumes:
      db_data:
      storage:
      oviyam:

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

   2. Agregar un servidor dicom: "DCM4CHEE", "DCM4CHEE", "arc", "11112", "WADO, "dcm4chee-arc/aets/DCM4CHEE/wado", "8080", "JPEG".

### Instalar D+O en Alpine Linux usando docker - Método 2

- [Instalar docker](../../herramientas/docker.md#instalar-docker-en-alpine).

1. Agregar zona horaria:

    ```sh
    echo "America/Argentina/Buenos_Aires" >> /etc/timezone
    ```

2. Crear requerimientos:

    ```sh
    addgroup -g 1021 slapd-dcm4chee && adduser -D -H -G slapd-dcm4chee -u 1021 slapd-dcm4chee
    addgroup -g 999 postgres-dcm4chee && adduser -D -H -G postgres-dcm4chee -u 999 postgres-dcm4chee
    addgroup -g 1023 dcm4chee-arc && adduser -D -H -G dcm4chee-arc -u 1023 dcm4chee-arc
    addgroup -g 1029 keycloak-dcm4chee && adduser -D -H -G keycloak-dcm4chee -u 1029 keycloak-dcm4chee
    ```

3. Crear compose:

    ```yml
    version: '3.7'
    services:
      mariadb:
        image: mariadb:10.11.4
        container_name: mariadb
        restart: always
        networks:
          - dcm4chee_network
        ports:
          - "3306:3306"
        environment:
          MYSQL_ROOT_PASSWORD: secret
          MYSQL_DATABASE: keycloak
          MYSQL_USER: keycloak
          MYSQL_PASSWORD: keycloak
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - /root/dcm4chee-arc/mysql:/var/lib/mysql

      keycloak:
        image: dcm4che/keycloak:23.0.3
        container_name: keycloak
        restart: always
        networks:
          - dcm4chee_network
        ports:
          - "8843:8843"
        environment:
          KC_HTTPS_PORT: 8843
          KC_HOSTNAME: <docker-host>
          KEYCLOAK_ADMIN: admin
          KEYCLOAK_ADMIN_PASSWORD: changeit
          KC_DB: mariadb
          KC_DB_URL_DATABASE: keycloak
          KC_DB_URL_HOST: mariadb
          KC_DB_USERNAME: keycloak
          KC_DB_PASSWORD: keycloak
          KC_LOG: file
          ARCHIVE_HOST: <docker-host>
          KEYCLOAK_WAIT_FOR: "ldap:389 mariadb:3306"
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - /root/dcm4chee-arc/keycloak:/opt/keycloak/data

      arc:
        image: dcm4che/dcm4chee-arc-psql:5.31.2-secure
        container_name: arc
        restart: always
        networks:
          - dcm4chee_network
        ports:
          - "8080:8080"
          - "8443:8443"
          - "9990:9990"
          - "9993:9993"
          - "11112:11112"
          - "2762:2762"
          - "2575:2575"
          - "12575:12575"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: pacs
          AUTH_SERVER_URL: https://keycloak:8843
          UI_AUTH_SERVER_URL: https://<docker-host>:8843
          WILDFLY_WAIT_FOR: "ldap:389 db:5432 keycloak:8843"
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - /root/dcm4chee-arc/wildfly:/opt/wildfly/standalone

      ldap:
        image: dcm4che/slapd-dcm4chee:2.6.5-31.2
        container_name: ldap
        restart: always
        networks:
          - dcm4chee_network
        ports:
          - "389:389"
        volumes:
          - /root/dcm4chee-arc/ldap:/var/lib/openldap/openldap-data
          - /root/dcm4chee-arc/slapd.d:/etc/openldap/slapd.d

      db:
        image: dcm4che/postgres-dcm4chee:15.4-31
        container_name: db
        restart: always
        networks:
          - dcm4chee_network
        ports:
          - "5432:5432"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: pacs
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - /root/dcm4chee-arc/db:/var/lib/postgresql/data

    networks:
      dcm4chee_network:
        name: dcm4chee_network
    ```

4. Entrar a <https://\<docker-host\>:8843/admin/dcm4che/console> como "root" y "changeit".

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
