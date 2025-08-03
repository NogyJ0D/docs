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

- Información del repositorio:

  ```sh
  git status          # Estado actual
  git log --oneline   # Log Resumido
  git log --oneline 5 # Últimos 5
  git branch          # Ramas locales
  git branch -r       # Ramas remotas
  git branch -a       # Todas las ramas
  ```

- Navegación entre ramas:

  ```sh
  git checkout main           # Cambiar a main
  git checkout -b nueva-rama  # Crear y cambiar a rama
  git checkout release/v1.0.0 # Cambiar a rama existente
  ```

- Commits y Push:

  ```sh
  git add .               # Agregar todos los cambios
  git add archivo.js      # Agregar archivo específico
  git commit -m "mensaje" # Commit con mensaje
  git push                # Push a rama actual
  git push -u origin rama # Primera vez pushing rama
  git push origin rama    # Push a rama específica
  ```

- Merges:

  ```sh
  git merge feature/rama          # Mergear rama en rama actual
  git merge --no-ff feature/rama  # Merge sin fast-forward (mantiene historial)
  ```

- Tags:

  ```sh
  git tag                         # Listar tags
  git tag v1.0.0                  # Crear tag simple
  git tag -a v1.0.0 -m "mensaje"  # Crear tag anotado
  git push origin v1.0.0          # Pushear tag específico
  git push origin --tags          # Pushear todos los tags
  ```

- Limpieza:

  ```sh
  # Borrar ramas remotas
  git push origin --delete rama

  # Borrar ramas locales
  git branch -d rama                 # Solo si está mergeada
  git branch -D rama                 # Forzar borrado

  # Limpiar referencias remotas obsoletas
  git remote prune origin
  ```

- Ver diferencias entre ramas:

  ```sh
  git diff main..release/v2.3.0
  git log main..release/v2.3.0 --oneline
  ```

- Deshacer commit:

  ```sh
  git reset --soft HEAD~1 # Mantiene cambios staged
  git reset --hard HEAD~1 # CUIDADO: Borra cambios
  ```

---

## Convenciones de commits

- Formato: `tipo: descripción breve - Refs #issue`

- Tipos comunes:

  - `feat:` nueva funcionalidad
  - `fix:` corrección de bug
  - `hotfix:` corrección de urgente en prod.
  - `refactor:` refactoring de código
  - `docs:` cambios en documentación
  - `style:` cambios de formato/estilo
  - `test:` agregar o modificar tests
  - `chore:` tareas de mantenimiento

- Palabras claves para Issues:

  - En commits
    - `git commit -m "fix: resolve payment bug - Fixes #123"`
  - En merge request:
    - `Closes #XX`
    - `Fixes #XX`
    - `Resolves #XX`
    - `Implements #XX`

---

## Flujos

### Multiples features a un solo release

1. Crear rama de release:

   ```sh
   git checkout main
   git pull origin main
   git checkout -b release/v1.0.0
   git push -u origin release/v1.0.0
   ```

2. Trabajar las features (repetir por cada feature):

   ```sh
   # Crear rama
   git checkout release/v1.0.0
   git checkout -b feature/nombre-funcionalidad

   # Trabajar en la feature
   git add .
   git commit -m "feat: descripción de la funcionalidad - Refs #XX"

   # Primer push a la rama incluye -u
   git push -u origin feature/nombre-funcionalidad
   # Siguientes pushes
   git push

   # Merge a release cuando termine
   git checkout release/v1.0.0
   git merge feature/nombre-funcionalidad
   git push origin release/v1.0.0
   ```

3. Preparar release:

   ```sh
   # Verificar estado antes del release
   git log --oneline
   git status
   git branch
   ```

4. Merge Request para Release (UI):

   ```sh
   ## Release v1.0.0

   ### New Features
   - Descripción feature 1
   - Descripción feature 2

   ### Bug Fixes
   - Descripción fix 1

   ### Issues
   Closes #7
   Closes #12
   Closes #13
   Closes #14

   ### Breaking Changes
   None

   ### Migrations needed
   Use file x to sync variables
   None on database
   ```

5. Post-Merge, actualizar main:

   ```sh
   git checkout main
   git pull origin main
   ```

6. Crear Tag y Release:

   ```sh
   git tag -a v1.0.0 -m "Release v1.0.0

   Features:
   - Feature 1 (#7)
   - Feature 2 (#10)

   Fixes:
   - Fixes (#12)"

   git push origin v1.0.0
   ```

7. Limpiar ramas:

   ```sh
   # Borrar ramas remotas
   git push origin --delete release/v1.0.0
   git push origin --delete feature/feature-1
   git push origin --delete feature/feature-2

   # Borrar ramas locales
   git branch -d release/v1.0.0
   git branch -d feature/feature-1
   git branch -d feature/feature-2
   ```

---

## Extras
