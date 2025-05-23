# ZSH

---

## Contenido

- [ZSH](#zsh)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Oh My ZSH](#oh-my-zsh)
    - [Instalar](#instalar)
  - [Plugins](#plugins)
    - [zsh-syntax-highlighting](#zsh-syntax-highlighting)
    - [ZSH-AutoSuggestion](#zsh-autosuggestion)
  - [Extras](#extras)
    - [Agregar completado](#agregar-completado)

---

## Documentación

---

## Oh My ZSH

### Instalar

```sh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

---

## Plugins

- Agregar a **_~/.zshrc_**

### zsh-syntax-highlighting

```sh
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### zsh-autosuggestions

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

---

## Extras

### Agregar completado

- Agregar a .zshrc:

  ```rc
  autoload -Uz compinit && compinit
  ```
