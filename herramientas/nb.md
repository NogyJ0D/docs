# nb

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

### Agregar nota

- Raiz:

    ```sh
    nb add [nombre].md 
    ```

- En carpeta:

    ```sh
    nb add [carpeta]/[nombre].md
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
