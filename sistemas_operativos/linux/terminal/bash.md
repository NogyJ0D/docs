# Bash

- [Bash](#bash)
  - [Configuración](#configuración)
  - [Oh My Bash](#oh-my-bash)
  - [Extras](#extras)
    - [Agregar completado](#agregar-completado)

---

## Configuración

- Ubicar en **_/root/.profile_** para root y **_$HOME/.bashrc_** para usuario:

    ```ini
    # Sugerir con tab
    bind 'TAB:menu-complete'
    # Mostrar sugerencias
    bind 'set show-all-if-ambiguous on'
    ```

---

## Oh My Bash

- Instalar:

    ```sh
    bash -c "$(curl -fsSL <https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh>)"
    ```

---

## Extras

### Agregar completado

1. Instalar bash-completion:

   ```sh
   pacman -S bash-completion # Arch
   ```

2. Agregar a **_~/.bashrc_**.

   ```rc
   source /usr/share/bash-completion/bash_completion
   ```

3. Recargar terminal.
