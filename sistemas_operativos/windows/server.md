# Windows Server

## Active Directory

### ¿Qué es?

- Servicio de Microsoft Windows Server.
- Base de datos: usuarios, dispositivos, grupos, políticas, permisos, recursos.
- Sirve para gestionar los usuarios dados de alta en el **dominio**, darles permisos de acceso a recursos de red y asignarles políticas de seguridad.
  - **Dominio**: agrupación, vinculación de usuarios a ámbitos (empresas por ej) y los recursos de este.
- Almacena datos en forma de objetos (los usuarios, políticas y recursos).
  - Se divide en recurso (carpeta, dispositivo o impresora) o entidad de seguridad (usuario o grupo), el primero es usado por el segundo. Se vinculan por políticas de seguridad.
- Se le dice _Directorio_ porque categoriza y jerarquiza objetos.
- El servidor que tiene instalado y activado el **_Directorio Activo_** (AD) se convierte en un **_Controlador de Dominio_** (DC).

### Activación

1. Ver la versión del Windows Server con el comando `winver`.
2. Abrir el administrador del servidor.
3. Seleccionar _"Agregar roles yo características"_.
   1. Seleccionar en el wizard _"Instalación basada en características o en roles"_ y seleccionar el servidor.
      1. Marcar _"Servicios de dominio de Active Directory"_ y confirmar.
      2. Marcar _"Servidor DNS"_ y confirmar.
         - Si da error por IP estática, asignarle IP estática en propiedades del adaptador.
         - Hacer que el servidor DNS preferido sea la misma IP del server (el alternativo puede ser cualquiera).
   2. Darle siguiente hasta finalizar.
4. En la parte superior derecha del administrador del servidor, ir a la bandera y promover el servidor a controlador de dominio.
   1. Seleccionar la casilla _"Agregar un nuevo bosque"_ y registrar el nombre del dominio (ej: empresa.local, empresa.com, dominio.com, ad.dominio.com).
   2. Finalizar la promoción, asignar la contraseña de **DSRM**, darle todo siguiente y reiniciar.
5. Al iniciar ir al administrador del servidor, seleccionar _Herramientas_ > _"Usuarios y equipos de Active Directory"_
   1. Seleccionra el dominio, dar click derecho, elegir _Propiedades_ y aceptar.
6. Volver al administrador y seleccionar _Herramientas_ > _"DNS"_.
   1. Click derecho sobre _"Zona de búsqueda inversa"_ y seleccionar _"Zona Nueva"_.
   2. Dar siguiente y en _ID de red_ poner la red del servidor (192.168.0), finalizar.
7. Comprobar las propiedades del servidor desde _"Servidor Local"_.

### Crear Usuarios y Grupos

1. Ir a _Herramientas_ > _Usuarios y equipos de Active Directory_.
   1. Click derecho en el dominio, _nuevo_, **Unidad Organizativa** y nombrarla (ej: empresa).
      - Se pueden crear sub unidades para granular los permisos.
   2. Click derecho en la UR, _nuevo_, **Grupo** (nombre por ejemplo: GRUPO_RW. Ámbito global y tipo seguridad).
   3. Click derecho en la UR, _nuevo_, **Usuario** (darle nombre y contraseña).
   4. Doble click sobre el usuario, _Miembro de_, _Agregar_, escribir el nombre del grupo correspondiente (darle a comprobar nombres) y confirmar.

### Crear Carpetas Compartidas

1. Ir al disco de datos en el explorador de archivos:
   1. Crear una carpeta raíz con el nombre de la UO raíz (ej: empresa).
   2. Crear dentro de esta la carpeta a compartir.
   3. Propiedades de la nueva carpeta:
      1. _Compartir_, **Uso compartido avanzado** y marcar **Compartir esta carpeta**. Apretar también **Permisos** y darle _control total_ a **Todos**.
      2. _Seguridad_ , **Opciones avanzadas**, **Deshabilitar herencia**, **_"Convertir los permisos heredados en permisos explícitos de este objeto"_**.
      3. _Seguridad_, **Opciones avanzadas**, quitar los grupos que hay menos _"Administradores"_, _"SYSTEM"_ y _"CREATOR OWNER"_.
      4. _Seguridad_, **Editar**, **Agregar**, agregar el grupo correspondiente a la carpeta (ej: GRUPO_RW) y permitirle "Modificar".

### Mapear Carpetas Automáticamente

1. Crearp GPO **_(una vez)_**:
   1. Ejecutar `gpmc.msc` y desplegar el bosque y dominio.
   2. Buscar la UO raíz (empresa), hacer click derecho, seleccionar **"Crear un GPO en este dominio y vincularlo aqui..."** y darle de nombre _"GPO_Mapeo_Unidades"_.
2. Asignar mapeo **_(repetible)_**:
   1. Editar la GPO y navegar por la **Configuración de usuario** > Preferencias > Configuración de Windows > Asignaciones de unidades.
      1. En la pestaña en blanco a la derecha hacer click derecho > Nuevo > Unidad Asignada
         - Acción: **Actualizar**
         - Ubicación: \\\NombreDelServidor\Carpeta
         - Reconectar: **activada**
         - Letra: asignar
      2. En la misma ventana ir a **_"Comunes"_**:
         1. Marcar **Destinatarios de nivel de elemento** y abrir **Destinatarios**
         2. Nuevo elemento > Grupo de seguridad > En Grupo apretar **"..."** y buscar el grupo, marcar después "Usuario en grupo"
         3. Aceptar y cerrar todo
3. Ejecutar en un cmd `gpupdate /force`

### Extras

#### Cambiar Política de Contraseñas

1. Ejecutar `gpmc.msc` y desplegar el bosque y dominio.
2. Editar el objeto **"Default Domain Policy"**.
   1. Configuración del equipo > Directivas > Configuración de Windows > Configuración de seguridad > Directivas de cuenta > Directiva de contraseña
   2. Abrir y editar
3. Ejecutar en un cmd `gpupdate /force`

#### Borrar Unidad Organizativa

Si al borrar la UO dice que no se puede porque está protegida:

1. Seleccionar _Ver_ > _Caracteristicas Avanzadas_.
2. Propiedades de la UO > Objeto > Desmarcar "Proteger objeto...".

## Servidor de Impresión

### Activar Servidor de Impresión (una vez)

1. Abrir el administrador del servidor.
2. Seleccionar _"Agregar roles yo características"_.
   1. Seleccionar en el wizard _"Instalación basada en características o en roles"_ y seleccionar el servidor.
      1. Marcar _"Servicios de impresión y documentos"_ y confirmar.
   2. Darle siguiente hasta finalizar.

### Agregar Impresora (repetible)

1. Agregarla:
   1. Abrir el administrador del servidor.
   2. Ir a _Herramientas_ > _Administración de impresión_ y desplegar _Servidores de impresión_ para encontrar el nuestro e ir a _Impresoras_. Dar click derecho y _Agregar impresora_.
   3. Agregar por ip, ponerle el driver correspondiente, darle un nombre corto y marcar compartir impresora.
2. Compartirla por GPO:
   1. Ejecutar `gpmc.msc` y desplegar el bosque y dominio.
   2. Crear la GPO según quienes usan la impresora:
      - Si la usan todos, crearla en la raíz del dominio.
      - Si la usa el grupo "Ventas", crearla en la carpeta de "Ventas".
   3. Editarla e ir a: _Configuración de usuario_ > _Preferencias_ > _Configuración del panel de control_ > _Impresoras_.
   4. Click derecho en el panel, _Nuevo_ > _Impresora compartida_.
   5. En la ruta de acceso poner "\\\SERVER\nombre asignado a la impresora".
   6. Ir a _Configuración del equipo_ > _Directivas_ > _Plantillas administrativas_ > _Impresoras_.
   7. Editar **"Restricciones de apuntar e imprimir"**:
      1. Habilitarla.
      2. Marcar: "Los usuarios solo pueden apuntar e imprimir en estos servidores".
      3. Escribir el nombre del servidor (ej: empresa.local).
      4. En las dos opciones de abajo ("Al instalar controladores..."), selecciona **"No mostrar advertencia ni indicador de elevación"**.
   8. Habilitar la política **"Apuntar e imprimir paquetes - Servidores aprobados"** en la misma ruta y añadir el servidor ahí (ej: empresa.local).
3. Ejecutar en un cmd `gpupdate /force`.
