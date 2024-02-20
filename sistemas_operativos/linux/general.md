# General

---

## Contenido

- [General](#general)
  - [Contenido](#contenido)
  - [Documentación](#documentación)
  - [Comandos](#comandos)
    - [Habilitar ssh como root](#habilitar-ssh-como-root)
  - [Extras](#extras)

---

## Documentación

---

## Comandos

### Habilitar ssh como root

```sh
sed -i -e 's/#Port 22/Port 22/' -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && service sshd restart && ip a
```

---

## Extras
