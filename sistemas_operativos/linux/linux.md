# Linux

---

## Contenido

---

## Documentación

---

## Extras

### Crontab

- Formato de regla cron:

    ```text
    m h dom mon dow user command
    ```

  - m: minuto (0-59).
  - h: hora (0-23).
  - dom: día del mes.
  - mon: mes (0-12).
  - dow: día de la semana (0-7).
  - user: usuario que ejecuta el comando.
  - command: comando a ejecutar.

  - Ejemplo:
  
      ```cron
      15 10 * * * usuario /home/usuario/scripts/actualizar.sh
      ```

      El usuario ejecuta el comando todos los dias a las 10:15 am.

- Modificar el crontab:

    ```sh
    crontab -e # Default root
    crontab -u usuario -e
    ```

  - El archivo está en ***/var/spool/cron/crontabs/usuario***. Es mejor modificarlo con el comando.

  - Si da error al seleccionar editor:

      ```sh
      export EDITOR=nano
      crontab -e
      ```
