# zypper

- Búsqueda:

  ```sh
  zypper search
  zypper se

  zypper se 'yast*' # Buscar paquetes que comiencen por yast
  zypper se -r repositorio # Listar paquetes en un repositorio
  zypper se -i paquete # Listar paquetes instalados que se llaman sqlite
  zypper se --provides --match-exact paquete # Dependencias
  ```

- Información:

  ```sh
  zypper info
  zypper if

  zypper if paquete
  ```

- Instalación:

  ```sh
  zypper install
  zypper in

  zypper in paquete # Instalar paquete
  ```

- Actualización:

  ```sh
  zypper list-patches # Listar parches
  zypper lp

  zypper patch # Aplicar parches

  zypper list-updates
  zypper lu

  zypper update # Actualizar paquetes
  zypper up

  zypper dist-upgrade # Actualizar sistema
  zypper dup
  ```

- Eliminación:

  ```sh
  zypper remove
  zypper rm

  zypper rm paquete
  ```

- Repositorios:

  ```sh
  zypper repos # Listar repositorios
  zypper lr

  zypper refresh # Actualizar repositorios
  zypper ref
  ```
