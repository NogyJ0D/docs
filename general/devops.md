# DevOps

- [DevOps](#devops)
  - [Getting Started with DevOps on AWS (Spanish)](#getting-started-with-devops-on-aws-spanish)
    - [Módulos](#módulos)

---

## Getting Started with DevOps on AWS (Spanish)

### Módulos

- DevOps = Development Operations (Desarrollo y Operaciones)
  - Desarrollo: procesos y personas que crean software.
  - Operaciones: equipos y procesos que entregan y monitorean el software.
  - Es una metodología o filosofía, no un producto.
- Beneficios del DevOps:
  - Agilidad
  - Entrega rápida
  - Fiabilidad
  - Escala
  - Colaboración mejorada
  - Seguridad
- Principios de la cultura DevOps:
  - Crear un entorno altamente colaborativo: todos trabajan por el mismo objetivo, optimizar la productividad de los desarrolladores y la fiabilidad de las operaciones.
  - Automatizar cuando sea posible: las tareas repetibles se automatizan y los equipos se centran en la innovación.
  - Foco en las necesidades del cliente: todo el proceso se enfoca en entregarle software de calidad al cliente.
  - Desarrollar poco y presentar a menudo: agilidad para responder a las necesidades y objetivos.
  - Incluir seguridad en cada fase: encontrar y resolver vulnerabilidades en cada etapa del proceso.
  - Experimentar y aprender continuamente: tomar los fracasos como oportunidades de aprendizaje.
  - Mejorar continuamente: aprovechar las métricas y el monitoreo para mejorar.
- Prácticas de DevOps:
  - Comunicación y colaboración: establecer normas culturales en equipos multifuncionales para garantizar las necesidades del proyecto.
  - Monitoreo y observabilidad: evaluar la efectividad de los cambios en la aplicación y la infraestructura y cómo afectan el rendimiento y la experiencia general del usuario.
  - Integración contínua (CI): combinar cambios en el código de forma periódica para reducir el tiempo que lleva validar y lanzar nuevas actualizaciones.
  - Entrega/Implementación contínua (CD): cada cambio de código se construye, prueba y luego se implementa automáticamente en un entorno que no sea producción para enviarlo una vez se tenga la aprobación. La implementación se salta el paso de aprobación y sube las modificaciones a producción directamente.
  - Arquitectura de microservicios: dividir el software en pequeños componentes aislados y especializados para intercomunicarlos con APIs bien definidas.
  - Infraestructura como código: la infraestructura se aproviciona y administra a través de técnicas de desarrollo de código y software.
- Etapas del DevOps:

  1. Código: programar y subir los cambios.
  2. Compilación: validar dependencias, ejecutar pruebas y compilar código (imagen, ejecutable, dist, etc).
  3. Prueba: evaluar si la aplicación cumple los requisitos (funcionales, rendimiento, diseño, implementación).
  4. Lanzamiento: preparar y empaquetar la nueva versión.
  5. Implementar: subir la versión al entorno objetivo (prueba, beta, producción).
  6. Monitoreo: monitorear la aplicación en producción para detectar errores o actividades inusuales.

  ![etapas](./etapas_devops.png 'etapas')

  - Una canalización de CI/CD garantiza la calidad del código, la seguridad y las iplementaciones rápidas y consistentes.

- Herramientas de DevOps:
  - Nube: aprovisionar entornos en la nube bajo demanda en lugar de servidores físicos.
  - Desarrollo.
  - CI/CD.
  - Automatización de la infraestructura: definir la infraestructura mediante programación (IaaS) para aprovisionar fácilmente los entornos.
  - Contenedores e informática sin servidor.
  - Monitoreo y observabilidad
