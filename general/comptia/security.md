# CompTIA Security+

SY0-701

- [CompTIA Security+](#comptia-security)
  - [Introducción](#introducción)
  - [1.0 - General, Security Concepts](#10---general-security-concepts)
    - [1.2 - Triángulo CIA/AIC](#12---triángulo-ciaaic)
    - [1.2 - Non-repudiation](#12---non-repudiation)
    - [1.2 - Authentication, Authorization, and Accounting](#12---authentication-authorization-and-accounting)
    - [1.2 - Gap Analysis](#12---gap-analysis)
    - [1.2 - Zero Trust](#12---zero-trust)

## Introducción

- Temas:

  | Dominio                                         | % del examen |
  | ----------------------------------------------- | ------------ |
  | 1.0 - General Security Concepts                 | 12%          |
  | 2.0 - Threats, Vulnerabilities and Mitigations  | 22%          |
  | 3.0 - Security Architecture                     | 18%          |
  | 4.0 - Security Operations                       | 28%          |
  | 5.0 - Security Program Management and Oversight | 20%          |
  | Total                                           | 100%         |

## 1.0 - General, Security Concepts

- **Controles de Seguridad**
  - Prevenir los eventos, minimizar el impacto y limitar el daño
  - _Categorías_:
    - Controles técnicos: controles por programas, del sistema operativo, firewall, antivirus
    - Controles gerenciales: seguridad en diseño e implementación, políticas, procedimientos estándar
    - Controles operacionales: implementado por personas (personal de seguridad, reuniones)
    - Controles físicos: vallas, cerraduras, lectores, guardias
  - _Tipos_:
    - Controles preventivos: limitar recursos o accesos
    - Controles disuasorios: no previene, hace pensar dos veces al atacante
    - Controles detectivos: identifica intrusiones
    - Controles correctivos: ocurre luego de detectado el evento y minimiza o neutraliza el ataque
    - Controles compensatorios: reducen el riesgo cuando la solución no puede aplicarse
    - Controles directivos: orientar el comportamiento de los usuarios
  - _Tipos por categoría_:

    | Categoría   | Preventivo                             | Disuasorio               | Detectivo                | Correctivo                      | Compensatorio                             | Directivos                              |
    | ----------- | -------------------------------------- | ------------------------ | ------------------------ | ------------------------------- | ----------------------------------------- | --------------------------------------- |
    | Técnico     | Firewall                               | Pantalla de credenciales | Logs de sistema          | Restaurar backups               | Bloqueo de firewall                       | Políticas de almacenamiento de archivos |
    | Gerencial   | Política de incorporación del personal | Descenso de categoría    | Ver intentos de logueo   | Políticas de reporte de eventos | Dividir responsabilidades                 | Políticas de cumplimiento               |
    | Operacional | Garita                                 | Mesa de recepción        | Patrullas                | Llamar a la policia             | Varios guardias haciendo tareas distintas | Instruir a los usuarios                 |
    | Físico      | Cerradura                              | Carteles de advertencia  | Detectores de movimiento | Usar un extintor                | Usar un generador                         | Carteles de prohibido el paso           |

  - No es una lista definitiva, se pueden mezclar los tipos o categorías

### 1.2 - Triángulo CIA/AIC

- Fundamentos de la seguridad:
  - **Confidencialidad**: prevenir que alguien acceda a datos privados
    - Encriptación: cifrar mensajes para que no todos puedan verlos
    - Control de acceso: restringir recursos
    - Autenticación de doble factor: doble confirmación antes de mostrar la información
  - **Integridad**: asegurarse que llegue la información tal cuál se envió
    - Hashing: firma que asegura que los datos no se manipularon
    - Firma digital: encripta el hash e identifica al mensajero
    - Certificados: vincula firmas con las entidades que las generan
    - No repudio: asegura que alguien no pueda negar haber enviado información o realizado una acción
  - **Disponibilidad**: asegurar el funcionamiento de la red y sistemas
    - Redundancia: los servicios siempre están disponibles
    - Tolerancia a fallos: los servicios siguen funcionando aunque estén fallando
    - Parches y actualizaciones: estabilidad

### 1.2 - Non-repudiation

- No se puede negar lo que se hizo
- Prueba de integridad: la información se mantiene precisa y consistente. Para eso se usa un hash, representa la información como una cadena corta. Esto no asocia la información con una persona.
- Prueba de origen: prueba que el mensaje no cambió (integridad) y da la fuente del mensaje. Asegura que la firma no es falsa. Firma la información con una clave privada que se verifica con una clave pública.

### 1.2 - Authentication, Authorization, and Accounting

- **AAA Framework**:
  - Identificación: yo digo que soy tal usuario (nombre de usuario).
  - (A) _Autenticación_: yo pruebo que soy tal usuario (contraseña).
  - (A) _Autorización_: según mi usuario y contraseña, a qué puedo acceder.
  - (A) _Registro (logging)_: recursos usados (tiempo de logeo, datos enviados y recibidos).
- Autenticando sistemas:
  - Un sistema no escribe contraseña, se usan certificados.
  - Una organización tiene un _"Certificate Authority" (CA)_, este firma los certificados de los demás dispositivos para aprobar la autenticación.
- Se usan **modelos de autorización** para relacionar usuarios a recursos. Se asignan recursos a grupos y usuarios a estos

### 1.2 - Gap Analysis

- Es el estudio de dónde estamos y dónde queremos estar, el espacio/gap entre ambos momentos.
- Se elige el objetivo o estandar a seguir primero.
  - Se pueden usar el NIST SP 800-171 o ISO/IEC 27001.
- Se eligen las personas responsables (por experiencia, entrenamiento, conocimiento).
- Se analizan los sistemas actuales y se identifican las debilidades.
- Se finaliza con un reporte de todo lo descubierto. Se enumeran los objetivos y qué soluciones aplicar para alcanzarlos.

### 1.2 - Zero Trust

- Hay que autenticarse cada vez que se solicita un recurso o sistema
- Todo está sujeto a verificaciones de seguridad
- Implica distintas medidas de seguridad según el acceso
