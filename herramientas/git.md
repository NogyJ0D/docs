# Git

- [Git](#git)

---

## Practicas a seguir

- Comandos y cosas a hacer. Para GitHub y GitLab.

### Hacer cambios

1. Al hacer cambios, debería crear una nueva rama y no pisar la main. Para esto:

   ```sh
   cd repositorio
   git checkout -b "nueva rama"
   # Nueva rama puede ser:
   #  feature/add-new-site
   #  bugfix/fix-new-site

   # Hacer modificaciones

   git add .
   git commit -m "descripción corta"
   # La descripción puede ser:
   #  feat: new site added
   #  fix: new site fixed

   git push -u "nombre remoto" "nueva rama remota"
   # El nombre remoto puede ser "origin", "github", "gitlab", etc.
   # La nueva rama remota se llama como la nueva rama local.
   ```

2. Una vez hecho el push, hay que crear una Pull/Merge Request en GitHub/GitLab y eliminar una vez aceptado la rama remota nueva.
3. Después de aceptar los cambios, hay que volver a main:

   ```sh
   git checkout main # cambiar a main
   git pull "nombre remoto" main
   git branch -d "nueva rama ya mergeada" # Borrarla

   # Si se subió una nueva versión (x.y.0 donde cambia x o y), hay que crear el tag. Se puede crear desde la UI o con comando
   git tag -a vx.y.0 -m "Release vx.y.0

   Features:
   - Se cambio tal
   - se Cambió cual

   Bug fixes:
   - Se arreglo tal"

   git push "nombre remoto" vx.y.0
   # Y luego se crea la release en GitHub/GitLab
   ```

- La idea es no trabajar sobre la rama main sinó crear una nueva para las modificaciones.
- Tratar de no crear muchas subramas (GitFlow), sino apegarse mas al CI/CD donde todo debe ser de rápida implementación.

---

## Comandos

- Eliminar rama local:

  ```sh
  git branch -d [nombre]
  ```

- Deshacer commit:

  ```sh
  git reset HEAD^
  ```

  - Para borrar los cambios agregar --hard
  - Para volver varios agregar el número de commits luego de ^

---

## Extras
