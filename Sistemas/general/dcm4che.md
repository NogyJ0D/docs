# DCM4CHEE

> Nota: Oviyam es solo un visor dicom que toma las imagenes de un servidor dcm4chee.

## Contenido

- [DCM4CHEE](#dcm4chee)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar DCM4CHEE en Alpine Linux usando Docker - Sin seguridad](#instalar-dcm4chee-en-alpine-linux-usando-docker---sin-seguridad)
    - [\<= Instalar DCM4CHEE en Alpine Linux usando docker - Con seguridad](#-instalar-dcm4chee-en-alpine-linux-usando-docker---con-seguridad)
    - [A](#a)
    - [\<= Instalar Oviyam 2.8.2 en Alpine Linux manualmente](#-instalar-oviyam-282-en-alpine-linux-manualmente)
  - [Extras](#extras)
    - [\<= Agregar visor DICOM web como contenedor](#-agregar-visor-dicom-web-como-contenedor)
      - [Oviyam](#oviyam)
      - [OHIF](#ohif)
  - [Keycloak](#keycloak)
    - [\<= Habilitar self-registration](#-habilitar-self-registration)

---

## Documentación

---

## Instalación

### Instalar DCM4CHEE en Alpine Linux usando Docker - [Sin seguridad](https://github.com/dcm4che/dcm4chee-arc-light/wiki/Run-secured-archive-services-on-a-single-host)

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
        image: dcm4che/slapd-dcm4chee:2.6.5-31.2
        logging:
          driver: json-file
          options:
            max-size: "10m"
        ports:
          - "389:389"
        environment:
          STORAGE_DIR: /storage/fs1
        volumes:
          - /root/dcm4chee-arc/ldap:/var/lib/openldap/openldap-data
          - /root/dcm4chee-arc/slapd.d:/etc/openldap/slapd.d
        networks:
          - dcm4chee_default
        restart: always

      db:
        image: dcm4che/postgres-dcm4chee:15.4-31
        logging:
          driver: json-file
          options:
            max-size: "10m"
        ports:
        - "5432:5432"
        environment:
          POSTGRES_DB: pacsdb
          POSTGRES_USER: pacs
          POSTGRES_PASSWORD: <contraseña db>
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - /root/dcm4chee-arc/db:/var/lib/postgresql/data
        networks:
          - dcm4chee_default
        restart: always

      arc:
        image: dcm4che/dcm4chee-arc-psql:5.31.2
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
          POSTGRES_PASSWORD: <contraseña db>
          WILDFLY_CHOWN: /storage
          WILDFLY_WAIT_FOR: "ldap:389 db:5432"
        depends_on:
          - ldap
          - db
        volumes:
          - /etc/localtime:/etc/localtime:ro
          - /etc/timezone:/etc/timezone:ro
          - /root/dcm4chee-arc/wildfly:/opt/wildfly/standalone
          - /root/dcm4chee-arc/storage:/storage
        networks:
          - dcm4chee_default
        restart: always

    networks:
      dcm4chee_default:
   ```

    > Puertos:
    >
    > 8080/8443 = http/https web server
    >
    > 9990/9993 = http/https wildfly console
    >
    > 11112/2762 = DICOM/DICOM-TLS
    >
    > 2575/12575 = HL7/HL7-TLS

4. Entrar a "<https://ip:8443/dcm4chee-arc/ui2>" para arc.

### [<=](#contenido) Instalar DCM4CHEE en Alpine Linux usando docker - [Con seguridad](https://github.com/dcm4che/dcm4chee-arc-light/wiki/Run-secured-archive-services-on-a-single-host)

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
   version: "3.7"
   services:
     mariadb_s:
       image: mariadb:10.11.4
       container_name: mariadb_s
       restart: always
       networks:
         - dcm4chee_network_s
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
         - /root/dcm4chee-arc-s/mysql:/var/lib/mysql

     keycloak_s:
       image: dcm4che/keycloak:23.0.3
       container_name: keycloak_s
       restart: always
       networks:
         - dcm4chee_network_s
       ports:
         - "8843:8843"
       environment:
         KC_HTTPS_PORT: 8843
         KC_HOSTNAME: <docker-host>
         KEYCLOAK_ADMIN: admin
         KEYCLOAK_ADMIN_PASSWORD: changeit
         KC_DB: mariadb_s
         KC_DB_URL_DATABASE: keycloak_s
         KC_DB_URL_HOST: mariadb_s
         KC_DB_USERNAME: keycloak
         KC_DB_PASSWORD: keycloak
         KC_LOG: file
         ARCHIVE_HOST: <docker-host>
         KEYCLOAK_WAIT_FOR: "ldap_s:389 mariadb_s:3306"
       volumes:
         - /etc/localtime:/etc/localtime:ro
         - /etc/timezone:/etc/timezone:ro
         - /root/dcm4chee-arc-s/keycloak:/opt/keycloak/data

     arc_s:
       image: dcm4che/dcm4chee-arc-psql:5.31.2-secure
       container_name: arc_s
       restart: always
       networks:
         - dcm4chee_network_s
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
         AUTH_SERVER_URL: https://<docker-host>:8843
         UI_AUTH_SERVER_URL: https://<docker-host>:8843
         WILDFLY_WAIT_FOR: "ldap_s:389 db_s:5432 keycloak_s:8843"
       volumes:
         - /etc/localtime:/etc/localtime:ro
         - /etc/timezone:/etc/timezone:ro
         - /root/dcm4chee-arc-s/wildfly:/opt/wildfly/standalone

     ldap_s:
       image: dcm4che/slapd-dcm4chee:2.6.5-31.2
       container_name: ldap_s
       restart: always
       networks:
         - dcm4chee_network_s
       ports:
         - "389:389"
       volumes:
         - /root/dcm4chee-arc-s/ldap:/var/lib/openldap/openldap-data
         - /root/dcm4chee-arc-s/slapd.d:/etc/openldap/slapd.d

     db_s:
       image: dcm4che/postgres-dcm4chee:15.4-31
       container_name: db_s
       restart: always
       networks:
         - dcm4chee_network_s
       ports:
         - "5432:5432"
       environment:
         POSTGRES_DB: pacsdb
         POSTGRES_USER: pacs
         POSTGRES_PASSWORD: pacs
       volumes:
         - /etc/localtime:/etc/localtime:ro
         - /etc/timezone:/etc/timezone:ro
         - /root/dcm4chee-arc-s/db:/var/lib/postgresql/data

   networks:
     dcm4chee_network_s:
       name: dcm4chee_network_s
   ```

4. Entrar a <https://\<docker-host\>:8843/admin/dcm4che/console> como "root" y "changeit".

5. Entrar a <https://\<docker-host\>:8443/dcm4chee-arc/ui2 como "root" y "changeit".

### A

```yml
version: "3"
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.4.2
    environment:
      ES_JAVA_OPTS: -Xms1024m -Xmx1024m
      discovery.type: single-node
      xpack.security.enabled: "false"
    logging:
      driver: json-file
      options:
        max-size: "10m"
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /root/dcm4chee-arc-s-e/esdatadir:/usr/share/elasticsearch/data

  kibana:
    image: docker.elastic.co/kibana/kibana:8.4.2
    logging:
      driver: json-file
      options:
        max-size: "10m"
    depends_on:
      - elasticsearch
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro

  logstash:
    image: dcm4che/logstash-dcm4chee:8.4.2-15
    logging:
      driver: json-file
      options:
        max-size: "10m"
    ports:
      - "12201:12201/udp"
      - "8514:8514/udp"
      - "8514:8514"
    depends_on:
      - elasticsearch
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /root/dcm4chee-arc-s-e/logstash/filter-hashtree:/usr/share/logstash/data/filter-hashtree

  ldap:
    image: dcm4che/slapd-dcm4chee:2.6.5-31.2
    logging:
      driver: gelf
      options:
        gelf-address: "udp://<docker-host>:12201"
        tag: slapd
    ports:
      - "389:389"
      - "636:636"
    environment:
      SYSLOG_HOST: logstash
      SYSLOG_PORT: 8514
      SYSLOG_PROTOCOL: TLS
      STORAGE_DIR: /storage/fs1
    volumes:
      - /root/dcm4chee-arc-s-e/ldap:/var/lib/openldap/openldap-data
      - /root/dcm4chee-arc-s-e/slapd.d:/etc/openldap/slapd.d

  mariadb:
    image: mariadb:10.11.4
    logging:
      driver: gelf
      options:
        gelf-address: "udp://<docker-host>:12201"
        tag: mariadb
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
      - /root/dcm4chee-arc-s-e/mysql:/var/lib/mysql

  keycloak:
    image: dcm4che/keycloak:23.0.3
    logging:
      driver: gelf
      options:
        gelf-address: "udp://<docker-host>:12201"
        tag: keycloak
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
      KC_LOG: file,gelf
      KC_LOG_GELF_HOST: logstash
      ARCHIVE_HOST: <docker-host>
      KIBANA_CLIENT_ID: kibana
      KIBANA_CLIENT_SECRET: <kibana-client-secret>
      KIBANA_REDIRECT_URL: https://<docker-host>:8643/oauth2/callback/*
      KEYCLOAK_WAIT_FOR: ldap:389 mariadb:3306 logstash:8514
    depends_on:
      - ldap
      - mariadb
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /root/dcm4chee-arc-s-e/keycloak:/opt/keycloak/data

  oauth2-proxy:
    image: dcm4che/oauth2-proxy:7.5.1
    ports:
      - "8643:8643"
    restart: on-failure
    environment:
      OAUTH2_PROXY_HTTPS_ADDRESS: 0.0.0.0:8643
      OAUTH2_PROXY_PROVIDER: keycloak-oidc
      OAUTH2_PROXY_SKIP_PROVIDER_BUTTON: "true"
      OAUTH2_PROXY_UPSTREAMS: "http://kibana:5601"
      OAUTH2_PROXY_OIDC_ISSUER_URL: "https://<docker-host>:8843/realms/dcm4che"
      OAUTH2_PROXY_REDIRECT_URL: "https://<docker-host>:8643/oauth2/callback"
      OAUTH2_PROXY_ALLOWED_ROLES: auditlog
      OAUTH2_PROXY_CLIENT_ID: kibana
      OAUTH2_PROXY_CLIENT_SECRET: <kibana-client-secret>
      OAUTH2_PROXY_EMAIL_DOMAINS: "*"
      OAUTH2_PROXY_OIDC_EMAIL_CLAIM: "sub"
      OAUTH2_PROXY_INSECURE_OIDC_ALLOW_UNVERIFIED_EMAIL: "true"
      OAUTH2_PROXY_COOKIE_SECRET: T0F1dGhLaWJhbmFUZXN0cw==
      OAUTH2_PROXY_SSL_INSECURE_SKIP_VERIFY: "true"
      OAUTH2_PROXY_TLS_CERT_FILE: /etc/certs/cert.pem
      OAUTH2_PROXY_TLS_KEY_FILE: /etc/certs/key.pem
      OAUTH2_PROXY_CUSTOM_TEMPLATES_DIR: /templates
    depends_on:
      - keycloak

  db:
    image: dcm4che/postgres-dcm4chee:15.4-31
    logging:
      driver: gelf
      options:
        gelf-address: "udp://<docker-host>:12201"
        tag: postgres
    ports:
      - "5432:5432"
    environment:
      POSTGRES_DB: pacsdb
      POSTGRES_USER: pacs
      POSTGRES_PASSWORD: pacs
    depends_on:
      - logstash
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /root/dcm4chee-arc-s-e/db:/var/lib/postgresql/data

  arc:
    image: dcm4che/dcm4chee-arc-psql:5.31.2-secure
    logging:
      driver: gelf
      options:
        gelf-address: "udp://<docker-host>:12201"
        tag: dcm4chee-arc
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
      LOGSTASH_HOST: logstash
      POSTGRES_DB: pacsdb
      POSTGRES_USER: pacs
      POSTGRES_PASSWORD: pacs
      AUTH_SERVER_URL: https://keycloak:8843
      UI_AUTH_SERVER_URL: https://<docker-host>:8843
      WILDFLY_CHOWN: /storage
      WILDFLY_WAIT_FOR: ldap:389 db:5432 keycloak:8843 logstash:8514
    depends_on:
      - ldap
      - keycloak
      - db
      - logstash
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone:/etc/timezone:ro
      - /root/dcm4chee-arc-s-e/wildfly:/opt/wildfly/standalone
      - /root/dcm4chee-arc-s-e/storage:/storage
```

### [<=](#contenido) Instalar Oviyam 2.8.2 en Alpine Linux manualmente

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

### [<=](#contenido) Agregar visor DICOM web como contenedor

#### Oviyam

- Composer:

    ```yml
     oviyam:
        image: informaticamedica/oviyam:2.8
        networks:
          - dcm4chee_default
        ports:
          - "80:8080"
          - "1025:1025"
        volumes:
          - /root/dcm4chee-arc/oviyam:/usr/local/tomcat/work
        restart: always
    ```

- Entrar a "<http://ip:80>" para oviyam:

   1. Loguearse como "admin" "adm1n".

      > Para modificar los usuarios locales de tomcat ejecutar:
      >
      > docker exec -it root-oviyam-1 /bin/bash
      >
      > Modificar /usr/local/tomcat/conf/tomcat-users.xml

   2. Agregar un servidor dicom: "DCM4CHEE", "DCM4CHEE", "arc", "11112", "WADO, "dcm4chee-arc/aets/DCM4CHEE/wado", "8080", "JPEG".

#### OHIF

- Composer:

    ```yml
    ohif:
        image: ohif/app:latest
        networks:
          - dcm4chee_default
        ports:
          - "3000:80"
        volumes:
          - /root/dcm4chee-arc/ohif.js:/usr/share/nginx/html/app-config.js
        restart: always
    ```

- ***/root/dcm4chee-arc/ohif.js***:

    ```js
    window.config = {
      routerBasename: '/',
      extensions: [],
      modes: [],
      showStudyList: true,
      dataSources: [
        {
          namespace: '@ohif/extension-default.dataSourcesModule.dicomweb',
          sourceName: 'dicomweb',
          configuration: {
            friendlyName: 'dcmjs DICOMWeb Server',
            name: 'DCM4CHEE',
            wadoUriRoot: 'https://<ip>:8443/dcm4chee-arc/aets/DCM4CHEE/wado',
            qidoRoot: 'https://<ip>:8443/dcm4chee-arc/aets/DCM4CHEE/rs',
            wadoRoot: 'https://<ip>:8443/dcm4chee-arc/aets/DCM4CHEE/rs',
            qidoSupportsIncludeField: true,
            supportsReject: true,
            imageRendering: 'wadors',
            thumbnailRendering: 'wadors',
            enableStudyLazyLoad: true,
            supportsFuzzyMatching: true,
            supportsWildcard: true,
            omitQuotationForMultipartRequest: true,
          },
        },
      ],
      defaultDataSourceName: 'dicomweb',
    };
    ```

## Keycloak

### [<=](#contenido) Habilitar self-registration

1. Ir a Realm Settings.

