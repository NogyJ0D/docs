# MediaWiki

---

## Contenido

- [MediaWiki](#mediawiki)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Instalación](#instalación)
  - [Extras](#extras)
    - [Si el editor rompe las categorías](#si-el-editor-rompe-las-categorías)

---

## Documentación

- [Configuración Nginx recomendada](https://www.nginx.com/resources/wiki/start/topics/recipes/mediawiki/)

---

## Instalación

---

## Extras

### Si el editor rompe las categorías

1. Tener la configuración de Nginx como la [recomendada](#documentación).

2. Agregar en el LocalSettings.php el parámetro "$wgUsePathInfo = true;".
