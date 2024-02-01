# Samba

---

## Contenido

- [Samba](#samba)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
    - [Habilitar/deshabilitar usuario](#habilitardeshabilitar-usuario)
    - [Desbloquear usuario](#desbloquear-usuario)
    - [Cambiar contraseña de usuario](#cambiar-contraseña-de-usuario)
    - [Listar usuarios](#listar-usuarios)
    - [Ver información del usuario](#ver-información-del-usuario)
  - [Extras](#extras)

---

## Documentación

---

## Comandos

### Habilitar/deshabilitar usuario

```sh
samba-tool user enable/disable usuario
```

### Desbloquear usuario

```sh
samba-tool user unlock usuario
```

### Cambiar contraseña de usuario

```sh
samba-tool user setpassword usuario --option="check password script"="" --newpassword="contraseña"
```

### Listar usuarios

```sh
samba-tool user list

pdbedit -L
```

### Ver información del usuario

```sh
# Todos
pdbedit -L -v

# Uno
pdbedit -u usuario -v
samba-tool user show usuario
```

---

## Extras