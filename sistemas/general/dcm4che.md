# DCM4CHEE

> Nota: Oviyam es solo un visor dicom que toma las imagenes de un servidor dcm4chee.

## Contenido

- [DCM4CHEE](#dcm4chee)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
    - [Instalar dcm4chee-arc-light manualmente en debian 12](#instalar-dcm4chee-arc-light-manualmente-en-debian-12)
    - [Instalar DCM4CHEE en Alpine Linux usando Docker - Sin seguridad](#instalar-dcm4chee-en-alpine-linux-usando-docker---sin-seguridad)
    - [\<= Instalar DCM4CHEE en Alpine Linux usando docker - Con seguridad](#-instalar-dcm4chee-en-alpine-linux-usando-docker---con-seguridad)
    - [A](#a)
    - [\<= Instalar Oviyam 2.8.2 en Alpine Linux manualmente](#-instalar-oviyam-282-en-alpine-linux-manualmente)
  - [Extras](#extras)
    - [Modifcar UI](#modifcar-ui)
    - [Migrar estudios de un servidor a otro](#migrar-estudios-de-un-servidor-a-otro)
    - [Mover instalación a nueva particion](#mover-instalación-a-nueva-particion)
    - [Agregar visor DICOM web como contenedor](#agregar-visor-dicom-web-como-contenedor)
      - [Oviyam](#oviyam)
      - [OHIF](#ohif)
  - [Keycloak](#keycloak)
    - [\<= Habilitar self-registration](#-habilitar-self-registration)

---

## Documentación

---

## Instalación

### [Instalar dcm4chee-arc-light manualmente](https://github.com/dcm4che/dcm4chee-arc-light/wiki/Installation) en debian 12

1. Requisitos:

   - Java SE 11 o superior
   - Wildfly 32.0.1
   - [PostgreSQL 15](../../database/sql/postgres.md#instalar-postgresql-en-debian-12)
   - OpenLDAP 2.5.11

    ```sh
    apt install postgresql-15 openjdk-17-jre openjdk-17-jdk slapd ldap-utils maven unzip
    # Recordar contraseña del administrador de ldap
    wget https://github.com/wildfly/wildfly/releases/download/32.0.1.Final/wildfly-32.0.1.Final.zip
    ```

2. Descargar el [archcive](https://sourceforge.net/projects/dcm4che/files/dcm4chee-arc-light5/):

    ```sh
    wget https://sourceforge.net/projects/dcm4che/files/dcm4chee-arc-light5/5.32.0/dcm4chee-arc-5.32.0-psql.zip/download -O dcm4chee-arc-5.32.0-psql.zip
    unzip dcm4chee-arc-5.32.0-psql.zip
    ```

3. Crear base de datos:

    ```sh
    su postgres -c "createuser -U postgres -P -d dcm4chee"
    su postgres -c "createdb -h localhost -U dcm4chee dcm4chee"

    psql -h localhost dcm4chee dcm4chee < $DCM4CHEE_ARC/sql/psql/create-psql.sql
    psql -h localhost dcm4chee dcm4chee < $DCM4CHEE_ARC/sql/psql/create-fk-index.sql
    psql -h localhost dcm4chee dcm4chee < $DCM4CHEE_ARC/sql/psql/create-case-insensitive-index.sql
    ```

4. Configurar ldap:

    ```sh
    ldapadd -Y EXTERNAL -H ldapi:/// -f $DCM4CHEE_ARC/ldap/slapd/dicom.ldif
    ldapadd -Y EXTERNAL -H ldapi:/// -f $DCM4CHEE_ARC/ldap/slapd/dcm4che.ldif
    tr -d \\r < $DCM4CHEE_ARC/ldap/slapd/dcm4chee-archive.ldif | ldapadd -Y EXTERNAL -H ldapi:///
    ldapadd -Y EXTERNAL -H ldapi:/// -f $DCM4CHEE_ARC/ldap/slapd/dcm4chee-archive-ui.ldif

    slappasswd # Copiar resultado para dcm4che
    ```

   - Crear el archivo **_modify-baseDN.ldif_**:

      ```ldif
      dn: olcDatabase={1}mdb,cn=config
      changetype: modify
      replace: olcSuffix
      olcSuffix: dc=dcm4che,dc=org
      -
      replace: olcRootDN
      olcRootDN: cn=admin,dc=dcm4che,dc=org
      -
      replace: olcRootPW
      olcRootPW: [Resultado slappasswd]
      ```

   - Crear el archivo **_slapd_setup_basic.ldif_**:

      ```ldif
      dn: dc=dcm4che,dc=org
      changetype: add
      objectClass: top
      objectClass: dcObject
      objectClass: organization
      o: Example org name
      dc: dcm4che

      dn: cn=admin,dc=dcm4che,dc=org
      changetype: add
      objectClass: simpleSecurityObject
      objectClass: organizationalRole
      cn: admin
      description: LDAP administrator
      userPassword: [Contraseña usada al instalar slapd]
      ```

      ```sh
      ldapmodify -Y EXTERNAL -H ldapi:/// -f modify-baseDN.ldif
      ldapmodify -x -W -D "cn=admin,dc=dcm4che,dc=org" -H ldapi:/// -f slapd_setup_basic.ldif

      ldapadd -x -W -D "cn=admin,dc=dcm4che,dc=org" -f $DCM4CHEE_ARC/ldap/init-baseDN.ldif
      ldapadd -x -W -D "cn=admin,dc=dcm4che,dc=org" -f $DCM4CHEE_ARC/ldap/init-config.ldif
      ldapadd -x -W -D "cn=admin,dc=dcm4che,dc=org" -f $DCM4CHEE_ARC/ldap/default-config.ldif
      ldapadd -x -W -D "cn=admin,dc=dcm4che,dc=org" -f $DCM4CHEE_ARC/ldap/default-ui-config.ldif

      cd $DCM4CHEE_ARC/ldap
      ldapadd -x -W -Dcn=admin,dc=dcm4che,dc=org -f add-vendor-data.ldif

      # Verificar configuración. Tiene que devolver dicomVendotData:: Texto largo
      ldapsearch -LLLsbase -x -W -Dcn=admin,dc=dcm4che,dc=org -b "dicomDeviceName=dcm4chee-arc,cn=Devices,cn=DICOM Configuration,dc=dcm4che,dc=org" dicomVendorData | head
      ```

5. Configurar wildfly:

    ```sh
    cp -r $DCM4CHEE_ARC/configuration /root/wildfly-x.x.x.Final/standalone
    cd /root/wildfly-x.x.x.Final/standalone/configuration/
    cp standalone.xml dcm4chee-arc.xml
    editor dcm4chee-arc/ldap.properties # Cambiar contraseña de ldap por la de dcm4chee

    cd /root/wildfly-x.x.x.Final
    unzip $DCM4CHEE_ARC/jboss-modules/dcm4che-jboss-modules-5.x.x.zip
    unzip $DCM4CHEE_ARC/jboss-modules/jai_imageio-jboss-modules-1.2-pre-dr-b04.zip
    unzip $DCM4CHEE_ARC/jboss-modules/jclouds-jboss-modules-2.2.1-noguava.zip
    unzip $DCM4CHEE_ARC/jboss-modules/jdbc-jboss-modules-mysql-8.0.20.zip

    cd /root
    wget https://github.com/dcm4che/ecs-object-client-jboss-modules/archive/refs/heads/master.zip
    unzip master.zip
    cd ecs-object-client-jboss-modules-master
    mvn install
    unzip target/ecs-object-client-jboss-modules-3.0.0.zip -d /root/wildfly-...
    ```

   - Correr wildfly en una terminal:

      ```sh
      $WILDFLY_HOME/bin/standalone.sh -c dcm4chee-arc.xml -b 0.0.0.0
      # Si da error, revisar que en /etc/hosts esté el nombre de la maquina como local
      ```

   - En otra terminal en simultaneo:

      ```sh
      $WILDFLY_HOME/bin/jboss-cli.sh -c
      /subsystem=datasources/jdbc-driver=psql:add(driver-name=psql,driver-module-name=org.postgresql)

      data-source add --name=PacsDS \
        --driver-name=psql \
        --connection-url=jdbc:postgresql://127.0.0.1:5432/dcm4chee \
        --jndi-name=java:/PacsDS \
        --user-name=dcm4chee \
        --password=[contraseña]

      exit

      $WILDFLY_HOME/bin/jboss-cli.sh -c --file=$DCM4CHEE_ARC/cli/adjust-managed-executor.cli

      $WILDFLY_HOME/bin/jboss-cli.sh -c
      reload
      /subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=max-post-size,value=10000000000)
      /subsystem=undertow/server=default-server/https-listener=https:write-attribute(name=max-post-size,value=10000000000)
      reload

      deploy /root/dcm4chee-arc-5.32.0-psql/deploy/dcm4chee-arc-ear-5.32.0-psql.ear
      deploy /root/dcm4chee-arc-5.32.0-psql/deploy/dcm4chee-arc-ui2-5.32.0.war
      ```

   - Probar que funcione <http://ip:8080/dcm4chee-arc/ui2>
   - Apagar wildfly.

6. Crear archivo **_/etc/systemd/system/wildfly.service_**:

    ```service
    [Unit]
    Description=Wildfly Application Server
    After=network.target

    [Service]
    Type=simple
    User=root
    Group=root
    ExecStart=/root/wildfly-32.0.1.Final/bin/standalone.sh -b 0.0.0.0 -c dcm4chee-arc.xml
    ExecStop=/root/wildfly-32.0.1.Final/bin/jboss-cli.sh --connect command=:shutdown
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    ```

    ```sh
    systemctl enable --now wildfly.service
    ```

- Extra:

  - Aumentar la ram para la jvm de wildfly:
    - Modificar esta linea en el archivo **_$WILDFLY/bin/standalone.conf_**: JBOSS_JAVA_SIZING="-Xms2G -Xmx3G -XX:MetaspaceSize=128M -XX:MaxMetaspaceSize=512m".

<!--
If configured Directory Base DN is other thandc=dcm4che,dc=org, replace all occurrences of dc=dcm4che,dc=org in LDIF files

$DCM4CHEE_ARC/ldap/init-baseDN.ldif
$DCM4CHEE_ARC/ldap/init-config.ldif
$DCM4CHEE_ARC/ldap/default-config.ldif
$DCM4CHEE_ARC/ldap/default-ui-config.ldif
$DCM4CHEE_ARC/ldap/add-vendor-data.ldif

by your Directory Base DN, e.g.:

> cd $DCM4CHEE_ARC/ldap
> sed -i s/dc=dcm4che,dc=org/dc=my-domain,dc=com/ init-baseDN.ldif
> sed -i s/dc=dcm4che,dc=org/dc=my-domain,dc=com/ init-config.ldif
> sed -i s/dc=dcm4che,dc=org/dc=my-domain,dc=com/ default-config.ldif
> sed -i s/dc=dcm4che,dc=org/dc=my-domain,dc=com/ default-ui-config.ldif
> sed -i s/dc=dcm4che,dc=org/dc=my-domain,dc=com/ add-vendor-data.ldif
 -->

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

### Modifcar UI

- Ir a Configuration > Devices > dcm4chee-arc > Extensions > Device Extension > Child Objects > UI Configuration.
  - Child Objects:
    - Modificar Language Config y agregar es y en.
  - Attributes:
    - Background URL: ruta a archivo
    - Logo URL: ruta a archivo
    - Hide Clock
    - Page Title
    - Default Widget AETs > DCM4CHEE

### Migrar estudios de un servidor a otro

- Descargar [dcm4chee completo](https://sourceforge.net/projects/dcm4che/files/dcm4che3/) para las tools:

    ```sh
    wget version.tar.gz -O dcm.tar.gz
    tar xvzf dcm.tar.gz

    cd dcm4chee.../bin/
    ./storescu -c [aet]@[ip]:[puerto] [storage]
    ```

  - aet: AET destino. DCM4CHEE u ORTHANC son default.
  - ip: ip del servidor destino.
  - puerto: puerto del servidor destino. 11112 para DCM4CHEE o 4242 para Orthanc.
  - storage: ruta de los estudios. Puede ser /storage/fs1 para dcm en docker, /root/wildfly/standalone/data/fs1 para la instalación manual.

### Mover instalación a nueva particion

1. Crear y agregar disco en proxmox.
2. Formatear disco:

    ```sh
    fdisk /dev/sdx
    g
    n
    Enter
    Enter
    w
    mkfs.ext4 /dev/sdx1
    ```

3. Crear montado:

    ```sh
    mkdir /mnt/dcm4chee
    blkid # Copiar uuid de la partición
    editor /etc/fstab
    # Agregar la entrada:
    # UUID=copiado  /mnt/dcm4chee  ext4 defaults  0  2
    systemctl daemon-reload
    mount -a
    ```

4. Cambiar storage en la interfaz:
   1.

### Agregar visor DICOM web como contenedor

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

- _**/root/dcm4chee-arc/ohif.js**_:

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
