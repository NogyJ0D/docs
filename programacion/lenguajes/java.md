# Java

- [Java](#java)
  - [Instalación](#instalación)
  - [Snippets](#snippets)

---

## Instalación

## Snippets

- Buscar si una lista contiene un objeto con un valor x en un atributo:

  - anyMatch es reemplazable por noneMatch para negarlo.

  ```java
  // Línea
  list.stream().anyMatch(o -> o.getProperty().equals(value));

  // Función
  public boolean containsName(final List<MyObject> list, final String name){
      return list.stream().anyMatch(o -> name.equals(o.getName()));
  }
  ```
