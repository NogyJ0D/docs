# Spring Boot

- [Spring Boot](#spring-boot)

---

## Instalación

---

## Snippets

---

## Dependencias

### Swagger OpenAPI UI

- Agregar dependencia:

  ```xml
  <dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>2.5.0</version>
  </dependency>
  ```

- URL: <http://localhost:8080/swagger-ui/index.html>

- Agregar JWT header:

  1. Crear clase SwaggerConfiguration:

     ```java
     @Configuration
     @SecurityScheme(
       name = "Bearer Authentication",
       type = SecuritySchemeType.HTTP,
       bearerFormat = "JWT",
       scheme = "bearer"
     )
     public class SwaggerConfiguration {}
     ```

  2. Agregar en los endpoints:

     ```java
     @SecurityRequirement(name = "Bearer Authentication")
     ```

---

## Extras
