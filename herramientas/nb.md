# nb

- [WIKI](https://xwmx.github.io/nb/#home)

- [nb](#nb)

---

## Instalación

### Instalar nb en arch

- Instalar [yay](../sistemas_operativos/linux/arch/arch.md#instalar-yay)

```sh
yay -S nb
```

---

## Comandos

### Listar

- Raiz:

    ```sh
    nb list
    ```

- Carpeta:

    ```sh
    nb list [id]/
    ```

### Agregar nota

```sh
nb add [id_carpeta]/[nombre].md
```

- Parámetros:
  - --encryption: agrega protección con contraseña.

### Editar nota

- Normal:

    ```sh
    nb edit [id_carpeta]/[id_nota]
    ```

---

## Extras

### Agregar tab completion

- zsh:

    ```sh
    mkdir -p ~/.zsh/completion
    curl -L https://raw.githubusercontent.com/xwmx/nb/master/etc/nb-completion.zsh > ~/.zsh/completion/_nb
    echo "fpath=(~/.zsh/completion $fpath)" >> ~/.zshrc
    autoload -Uz compinit && compinit -i
    exec $SHELL -l
    ```
